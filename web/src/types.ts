export type RideMode = "motorcycle" | "bicycle" | "car" | "running" | "transit";

export type RideEventType =
  | "hard_brake"
  | "sharp_swerve"
  | "impact"
  | "crash_candidate"
  | "long_stop"
  | "route_deviation"
  | "manual";

export type InferenceSource = "on_device" | "in_cloud" | "fallback" | "deterministic";

export type AIMode =
  | "prefer_on_device"
  | "only_on_device"
  | "prefer_in_cloud"
  | "only_in_cloud";

export interface RideEvent {
  id: string;
  rideId: string;
  mode: RideMode;
  type: RideEventType;
  severity: number;
  confidence: number;
  geohash: string;
  occurredAtMs: number;
  summary: string;
  source: Exclude<InferenceSource, "fallback">;
}

export interface Ride {
  id: string;
  uid: string;
  mode: RideMode;
  startedAtMs: number;
  endedAtMs: number;
  distanceM: number;
  durationS: number;
  avgSpeedKph: number;
  maxSpeedKph: number;
  score: number;
  summary: string;
  inferenceSource: InferenceSource;
  geohash: string;
  routePreview: Array<[number, number]>;
  events: RideEvent[];
}

export interface RiskCell {
  id: string;
  mode: RideMode;
  geohash: string;
  count: number;
  severitySum: number;
  confidenceSum: number;
  topTypes: Record<string, number>;
  lastUpdatedMs: number;
}

export interface Credential {
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
  payloadHash: string;
  signature: string;
}

export interface InsurerShareLink {
  token: string;
  url: string;
}

export interface InsurerView {
  credentialId: string;
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
  payloadHash: string;
  signature: string;
}

export interface CredentialVerification {
  valid: boolean;
  credential: Credential | null;
  reason?: string;
}

export interface RideSnapshot {
  headline: string;
  summary: string;
  riskMoments: Array<{
    type: RideEventType;
    atSeconds: number;
    severity: number;
    explanation: string;
  }>;
  score: number;
  scoreRationale: string;
  coachingTip: string;
}

export const MODE_LABELS: Record<RideMode, string> = {
  motorcycle: "Motorcycle",
  bicycle: "Bicycle",
  car: "Car",
  running: "Running",
  transit: "Transit"
};

export const EVENT_LABELS: Record<RideEventType, string> = {
  hard_brake: "Hard brake",
  sharp_swerve: "Sharp swerve",
  impact: "Impact",
  crash_candidate: "Crash candidate",
  long_stop: "Long stop",
  route_deviation: "Route deviation",
  manual: "Manual lock"
};


export interface CommunityInsight {
  headline: string;
  summary: string;
  hotspots: Array<{
    geohash: string;
    explanation: string;
  }>;
  action: string;
}
