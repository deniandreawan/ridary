import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { warn } from "firebase-functions/logger";
import { REGION } from "./config";
import { mergeRiskCell, normalizeRiskCell, riskCellId } from "./risk";
import { eventPayloadSchema } from "./validation";
import type { EventInput } from "./types";

const db = getFirestore();

export const aggregateRisk = onDocumentCreated(
  { document: "events/{eventId}", region: REGION },
  async (event): Promise<void> => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const raw: unknown = snapshot.data();
    const parsed = eventPayloadSchema.safeParse(raw);
    if (!parsed.success) {
      warn("Skipping invalid event document", {
        eventId: event.params.eventId,
        issues: parsed.error.issues
      });
      return;
    }

    const data = parsed.data;
    const cellId = riskCellId(data.mode, data.geohash);
    const cellRef = db.doc(`riskCells/${cellId}`);

    await db.runTransaction(async (transaction) => {
      const existing = await transaction.get(cellRef);
      const previous = existing.exists
        ? normalizeRiskCell(existing.data())
        : undefined;

      const input: EventInput = {
        rideId: data.rideId,
        mode: data.mode,
        type: data.type,
        severity: data.severity,
        confidence: data.confidence,
        occurredAtMs: Date.now()
      };

      const next = mergeRiskCell(previous, input);
      transaction.set(
        cellRef,
        {
          mode: data.mode,
          geohash: data.geohash,
          count: next.count,
          severitySum: next.severitySum,
          confidenceSum: next.confidenceSum,
          topTypes: next.topTypes,
          lastUpdated: FieldValue.serverTimestamp()
        },
        { merge: true }
      );
    });
  }
);
