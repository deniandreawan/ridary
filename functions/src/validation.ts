import { Timestamp } from "firebase-admin/firestore";
import { z } from "zod";
import {
  EVENT_TYPES,
  INFERENCE_SOURCES,
  RIDE_MODES
} from "./types";

export const rideModeSchema = z.enum(RIDE_MODES);
export const eventTypeSchema = z.enum(EVENT_TYPES);
export const inferenceSourceSchema = z.enum(INFERENCE_SOURCES);
export const geohashSchema = z.string().regex(/^[0-9a-z]{6,8}$/);

export const eventPayloadSchema = z
  .object({
    uid: z.string().min(1).max(128),
    rideId: z.string().min(1).max(128),
    mode: rideModeSchema,
    type: eventTypeSchema,
    severity: z.number().int().min(1).max(5),
    confidence: z.number().min(0).max(1),
    geohash: geohashSchema,
    summary: z.string().min(1).max(2000),
    source: z.enum(["deterministic", "on_device", "in_cloud"]),
    schemaVersion: z.literal(1)
  })
  .passthrough();

export const eventDocSchema = eventPayloadSchema.extend({
  occurredAt: z.instanceof(Timestamp),
  createdAt: z.instanceof(Timestamp)
});

export const rideDocSchema = z
  .object({
    uid: z.string().min(1).max(128),
    mode: rideModeSchema,
    startedAt: z.instanceof(Timestamp),
    endedAt: z.instanceof(Timestamp),
    distanceM: z.number().nonnegative(),
    durationS: z.number().nonnegative(),
    avgSpeedKph: z.number().nonnegative(),
    maxSpeedKph: z.number().nonnegative(),
    score: z.number().int().min(0).max(100),
    summary: z.string().max(4000),
    inferenceSource: inferenceSourceSchema,
    geohash: geohashSchema,
    createdAt: z.instanceof(Timestamp),
    schemaVersion: z.literal(1)
  })
  .passthrough();

export const credentialRequestSchema = z.object({
  mode: rideModeSchema.default("motorcycle"),
  days: z.number().int().min(7).max(90).default(30)
});

export const credentialIdSchema = z.object({
  credentialId: z.string().min(8).max(128)
});

export const weeklyStatsRequestSchema = z.object({
  mode: rideModeSchema.default("motorcycle"),
  days: z.number().int().min(1).max(90).default(7)
});
