import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { REGION } from "./config";
import { periodBounds } from "./scoring";
import {
  eventDocSchema,
  rideDocSchema,
  weeklyStatsRequestSchema
} from "./validation";
import type { EventType, InferenceSource, RideMode } from "./types";

const db = getFirestore();

export interface WeeklyRideStat {
  id: string;
  startedAtMs: number;
  distanceM: number;
  durationS: number;
  score: number;
  summary: string;
  inferenceSource: InferenceSource;
  geohash: string;
}

export interface WeeklyEventStat {
  rideId: string;
  type: EventType;
  severity: number;
  confidence: number;
  occurredAtMs: number;
  summary: string;
  source: "deterministic" | "on_device" | "in_cloud";
}

export interface WeeklyStatsResponse {
  mode: RideMode;
  periodStart: string;
  periodEnd: string;
  rides: WeeklyRideStat[];
  events: WeeklyEventStat[];
}

export const getWeeklyStats = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request): Promise<WeeklyStatsResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to load weekly stats.");
    }

    const input = weeklyStatsRequestSchema.parse(request.data ?? {});
    const uid = request.auth.uid;
    const now = Date.now();
    const { startMs, endMs } = periodBounds(now, input.days);

    const ridesSnapshot = await db
      .collection("rides")
      .where("uid", "==", uid)
      .where("mode", "==", input.mode)
      .where("startedAt", ">=", Timestamp.fromMillis(startMs))
      .orderBy("startedAt", "desc")
      .limit(20)
      .get();

    const rides: WeeklyRideStat[] = [];
    for (const document of ridesSnapshot.docs) {
      const raw: unknown = document.data();
      const parsed = rideDocSchema.safeParse(raw);
      if (!parsed.success) {
        continue;
      }
      rides.push({
        id: document.id,
        startedAtMs: parsed.data.startedAt.toMillis(),
        distanceM: parsed.data.distanceM,
        durationS: parsed.data.durationS,
        score: parsed.data.score,
        summary: parsed.data.summary,
        inferenceSource: parsed.data.inferenceSource,
        geohash: parsed.data.geohash
      });
    }

    const rideIds = new Set(rides.map((ride) => ride.id));
    const eventsSnapshot = await db
      .collection("events")
      .where("uid", "==", uid)
      .where("occurredAt", ">=", Timestamp.fromMillis(startMs))
      .orderBy("occurredAt", "desc")
      .limit(200)
      .get();

    const events: WeeklyEventStat[] = [];
    for (const document of eventsSnapshot.docs) {
      const raw: unknown = document.data();
      const parsed = eventDocSchema.safeParse(raw);
      if (!parsed.success || !rideIds.has(parsed.data.rideId)) {
        continue;
      }
      events.push({
        rideId: parsed.data.rideId,
        type: parsed.data.type,
        severity: parsed.data.severity,
        confidence: parsed.data.confidence,
        occurredAtMs: parsed.data.occurredAt.toMillis(),
        summary: parsed.data.summary,
        source: parsed.data.source
      });
    }

    return {
      mode: input.mode,
      periodStart: new Date(startMs).toISOString(),
      periodEnd: new Date(endMs).toISOString(),
      rides,
      events
    };
  }
);
