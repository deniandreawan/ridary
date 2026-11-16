export const RIDE_MODES = [
  "motorcycle",
  "bicycle",
  "car",
  "running",
  "transit"
] as const;

export type RideMode = (typeof RIDE_MODES)[number];

export const EVENT_TYPES = [
  "hard_brake",
  "sharp_swerve",
  "impact",
  "crash_candidate",
  "long_stop",
  "route_deviation",
  "manual"
] as const;

export type EventType = (typeof EVENT_TYPES)[number];

export const INFERENCE_SOURCES = [
  "on_device",
  "in_cloud",
  "fallback",
  "deterministic"
] as const;

export type InferenceSource = (typeof INFERENCE_SOURCES)[number];

export interface RideInput {
  id: string;
  mode: RideMode;
  startedAtMs: number;
  distanceM: number;
  durationS: number;
}

export interface EventInput {
  rideId: string;
  mode: RideMode;
  type: EventType;
  severity: number;
  confidence: number;
  occurredAtMs: number;
}

export interface CredentialPayload {
  credentialId: string;
  uid: string;
  periodStart: string;
  periodEnd: string;
  mode: RideMode;
  score: number;
  rideCount: number;
  eventCount: number;
  issuedAt: string;
  expiresAt: string;
  issuer: string;
  publicKeyId: string;
}

export interface SignedCredential extends CredentialPayload {
  payloadHash: string;
  signature: string;
}

export interface RiskCellState {
  count: number;
  severitySum: number;
  confidenceSum: number;
  topTypes: Record<string, number>;
}

export interface RiskCellDocument extends RiskCellState {
  mode: RideMode;
  geohash: string;
  lastUpdated: unknown;
}
