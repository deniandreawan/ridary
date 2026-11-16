import { randomBytes } from "node:crypto";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { INSURER_VIEW_VALID_DAYS, REGION, webBaseUrl } from "./config";
import {
  isCredentialExpired,
  signedCredentialFromUnknown
} from "./credential";
import { credentialIdSchema } from "./validation";

const db = getFirestore();

export interface InsurerViewResponse {
  token: string;
  url: string;
}

export const createInsurerView = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request): Promise<InsurerViewResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to create an insurer view.");
    }

    const input = credentialIdSchema.parse(request.data ?? {});
    const snapshot = await db.doc(`credentials/${input.credentialId}`).get();

    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Credential not found.");
    }

    const raw: unknown = snapshot.data();
    const credential = signedCredentialFromUnknown(raw);

    if (credential.uid !== request.auth.uid) {
      throw new HttpsError("permission-denied", "This credential belongs to another user.");
    }

    if (isCredentialExpired(credential.expiresAt)) {
      throw new HttpsError("failed-precondition", "This credential has expired.");
    }

    const token = randomBytes(24).toString("base64url");
    const expiresAt = new Date(
      Date.now() + INSURER_VIEW_VALID_DAYS * 24 * 60 * 60 * 1000
    ).toISOString();

    await db.doc(`insurerViews/${token}`).set({
      credentialId: credential.credentialId,
      periodStart: credential.periodStart,
      periodEnd: credential.periodEnd,
      mode: credential.mode,
      score: credential.score,
      rideCount: credential.rideCount,
      eventCount: credential.eventCount,
      issuedAt: credential.issuedAt,
      expiresAt,
      issuer: credential.issuer,
      publicKeyId: credential.publicKeyId,
      payloadHash: credential.payloadHash,
      signature: credential.signature,
      createdAt: FieldValue.serverTimestamp(),
      expiresAtTimestamp: Timestamp.fromMillis(Date.parse(expiresAt))
    });

    return {
      token,
      url: `${webBaseUrl()}/insurer/${token}`
    };
  }
);
