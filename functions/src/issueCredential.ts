import { randomUUID } from "node:crypto";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { error as logError, warn } from "firebase-functions/logger";
import {
  CREDENTIAL_VALID_DAYS,
  MAX_CREDENTIAL_EVENTS,
  MAX_CREDENTIAL_RIDES,
  MIN_RIDES_FOR_CREDENTIAL,
  REGION,
  credentialIssuer
} from "./config";
import { computeCredentialScore, isCredentialEligible, periodBounds } from "./scoring";
import { loadSignerFromEnv } from "./signing";
import { eventDocSchema, credentialRequestSchema, rideDocSchema } from "./validation";
import type {
  CredentialPayload,
  EventInput,
  RideInput,
  SignedCredential
} from "./types";

const db = getFirestore();

export const issueCredential = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request): Promise<SignedCredential> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to issue a credential.");
    }

    const input = credentialRequestSchema.parse(request.data ?? {});
    const uid = request.auth.uid;
    const now = Date.now();
    const { startMs, endMs } = periodBounds(now, input.days);

    const ridesSnapshot = await db
      .collection("rides")
      .where("uid", "==", uid)
      .where("mode", "==", input.mode)
      .where("startedAt", ">=", Timestamp.fromMillis(startMs))
      .orderBy("startedAt", "desc")
      .limit(MAX_CREDENTIAL_RIDES)
      .get();

    const rides: RideInput[] = [];
    for (const document of ridesSnapshot.docs) {
      const raw: unknown = document.data();
      const parsed = rideDocSchema.safeParse(raw);
      if (!parsed.success) {
        warn("Skipping invalid ride while issuing credential", {
          rideId: document.id,
          issues: parsed.error.issues
        });
        continue;
      }
      rides.push({
        id: document.id,
        mode: parsed.data.mode,
        startedAtMs: parsed.data.startedAt.toMillis(),
        distanceM: parsed.data.distanceM,
        durationS: parsed.data.durationS
      });
    }

    if (!isCredentialEligible(rides.length)) {
      throw new HttpsError(
        "failed-precondition",
        `At least ${String(MIN_RIDES_FOR_CREDENTIAL)} rides are required in this period.`,
        { rideCount: rides.length, required: MIN_RIDES_FOR_CREDENTIAL }
      );
    }

    const rideIds = new Set(rides.map((ride) => ride.id));
    const eventsSnapshot = await db
      .collection("events")
      .where("uid", "==", uid)
      .where("occurredAt", ">=", Timestamp.fromMillis(startMs))
      .orderBy("occurredAt", "desc")
      .limit(MAX_CREDENTIAL_EVENTS)
      .get();

    const events: EventInput[] = [];
    for (const document of eventsSnapshot.docs) {
      const raw: unknown = document.data();
      const parsed = eventDocSchema.safeParse(raw);
      if (!parsed.success) {
        continue;
      }
      if (!rideIds.has(parsed.data.rideId)) {
        continue;
      }
      events.push({
        rideId: parsed.data.rideId,
        mode: parsed.data.mode,
        type: parsed.data.type,
        severity: parsed.data.severity,
        confidence: parsed.data.confidence,
        occurredAtMs: parsed.data.occurredAt.toMillis()
      });
    }

    const score = computeCredentialScore(rides, events);

    let signer;
    try {
      signer = loadSignerFromEnv();
    } catch (error) {
      logError("Credential signer is not configured", {
        message: error instanceof Error ? error.message : "unknown"
      });
      throw new HttpsError(
        "failed-precondition",
        "Credential signing is not configured on the server."
      );
    }

    const credentialId = randomUUID();
    const payload: CredentialPayload = {
      credentialId,
      uid,
      periodStart: new Date(startMs).toISOString(),
      periodEnd: new Date(endMs).toISOString(),
      mode: input.mode,
      score: score.score,
      rideCount: score.rideCount,
      eventCount: score.eventCount,
      issuedAt: new Date(endMs).toISOString(),
      expiresAt: new Date(
        endMs + CREDENTIAL_VALID_DAYS * 24 * 60 * 60 * 1000
      ).toISOString(),
      issuer: credentialIssuer(),
      publicKeyId: signer.publicKeyId
    };

    const signed = signer.sign(payload);
    const credential: SignedCredential = {
      ...payload,
      payloadHash: signed.payloadHash,
      signature: signed.signature
    };

    await db.doc(`credentials/${credentialId}`).set({
      ...credential,
      createdAt: FieldValue.serverTimestamp()
    });

    return credential;
  }
);
