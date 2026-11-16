import type { Credential, Ride, RiskCell } from "../types";
import { encodeGeohash } from "../lib/geohash";

const hour = 60 * 60 * 1000;
const day = 24 * hour;
const now = Date.now();

const jakarta = { lat: -6.2088, lon: 106.8456 };
const jakartaSouth = { lat: -6.2297, lon: 106.8166 };

const rideOneStart = now - 2 * hour;
const rideOneRoute: Array<[number, number]> = [
  [jakarta.lat, jakarta.lon],
  [-6.2141, 106.8389],
  [-6.2198, 106.8301],
  [-6.2257, 106.8224],
  [jakartaSouth.lat, jakartaSouth.lon]
];

const rideTwoStart = now - 2 * day;
const rideTwoRoute: Array<[number, number]> = [
  [jakarta.lat, jakarta.lon],
  [-6.2012, 106.8541],
  [-6.1965, 106.8654],
  [-6.1902, 106.8742]
];

const rideThreeStart = now - 4 * day;
const rideThreeRoute: Array<[number, number]> = [
  [jakartaSouth.lat, jakartaSouth.lon],
  [-6.2338, 106.8091],
  [-6.2401, 106.8002]
];

export const demoRides: Ride[] = [
  {
    id: "demo-ride-1",
    uid: "demo-user",
    mode: "motorcycle",
    startedAtMs: rideOneStart,
    endedAtMs: rideOneStart + 48 * 60 * 1000,
    distanceM: 12400,
    durationS: 48 * 60,
    avgSpeedKph: 15.5,
    maxSpeedKph: 54,
    score: 84,
    summary:
      "A steady evening commute with one hard brake near a wet junction and one sharp swerve around a stopped car.",
    inferenceSource: "on_device",
    geohash: encodeGeohash(jakarta.lat, jakarta.lon),
    routePreview: rideOneRoute,
    events: [
      {
        id: "demo-event-1",
        rideId: "demo-ride-1",
        mode: "motorcycle",
        type: "hard_brake",
        severity: 3,
        confidence: 0.86,
        geohash: encodeGeohash(-6.2198, 106.8301),
        occurredAtMs: rideOneStart + 22 * 60 * 1000,
        summary: "Hard braking detected near a wet junction.",
        source: "on_device"
      },
      {
        id: "demo-event-2",
        rideId: "demo-ride-1",
        mode: "motorcycle",
        type: "sharp_swerve",
        severity: 3,
        confidence: 0.72,
        geohash: encodeGeohash(-6.2257, 106.8224),
        occurredAtMs: rideOneStart + 31 * 60 * 1000,
        summary: "Sharp lateral movement around a stopped car.",
        source: "on_device"
      }
    ]
  },
  {
    id: "demo-ride-2",
    uid: "demo-user",
    mode: "motorcycle",
    startedAtMs: rideTwoStart,
    endedAtMs: rideTwoStart + 36 * 60 * 1000,
    distanceM: 9800,
    durationS: 36 * 60,
    avgSpeedKph: 16.3,
    maxSpeedKph: 48,
    score: 72,
    summary:
      "Two risk moments in a short trip. One hard brake was followed by a long stop at a railway crossing.",
    inferenceSource: "on_device",
    geohash: encodeGeohash(-6.2012, 106.8541),
    routePreview: rideTwoRoute,
    events: [
      {
        id: "demo-event-3",
        rideId: "demo-ride-2",
        mode: "motorcycle",
        type: "hard_brake",
        severity: 4,
        confidence: 0.9,
        geohash: encodeGeohash(-6.2012, 106.8541),
        occurredAtMs: rideTwoStart + 12 * 60 * 1000,
        summary: "Hard braking detected before the crossing.",
        source: "deterministic"
      },
      {
        id: "demo-event-4",
        rideId: "demo-ride-2",
        mode: "motorcycle",
        type: "long_stop",
        severity: 1,
        confidence: 0.95,
        geohash: encodeGeohash(-6.1965, 106.8654),
        occurredAtMs: rideTwoStart + 26 * 60 * 1000,
        summary: "A long stationary period was recorded.",
        source: "deterministic"
      }
    ]
  },
  {
    id: "demo-ride-3",
    uid: "demo-user",
    mode: "bicycle",
    startedAtMs: rideThreeStart,
    endedAtMs: rideThreeStart + 26 * 60 * 1000,
    distanceM: 5600,
    durationS: 26 * 60,
    avgSpeedKph: 12.9,
    maxSpeedKph: 26,
    score: 96,
    summary: "A smooth bicycle ride with no flagged moments.",
    inferenceSource: "in_cloud",
    geohash: encodeGeohash(jakartaSouth.lat, jakartaSouth.lon),
    routePreview: rideThreeRoute,
    events: []
  }
];

function cell(
  lat: number,
  lon: number,
  count: number,
  severitySum: number,
  confidenceSum: number,
  topTypes: Record<string, number>
): RiskCell {
  return {
    id: `motorcycle_${encodeGeohash(lat, lon)}`,
    mode: "motorcycle",
    geohash: encodeGeohash(lat, lon),
    count,
    severitySum,
    confidenceSum,
    topTypes,
    lastUpdatedMs: now - hour
  };
}

export const demoRiskCells: RiskCell[] = [
  cell(-6.2198, 106.8301, 7, 22, 5.6, { hard_brake: 5, sharp_swerve: 2 }),
  cell(-6.2257, 106.8224, 4, 11, 3.1, { sharp_swerve: 3, hard_brake: 1 }),
  cell(-6.2012, 106.8541, 11, 38, 9.2, { hard_brake: 8, impact: 1, long_stop: 2 }),
  cell(-6.1965, 106.8654, 3, 6, 2.4, { long_stop: 2, hard_brake: 1 }),
  cell(-6.1902, 106.8742, 6, 20, 4.8, { hard_brake: 4, sharp_swerve: 2 }),
  cell(-6.2338, 106.8091, 2, 3, 1.6, { hard_brake: 2 }),
  cell(-6.2401, 106.8002, 5, 14, 3.7, { sharp_swerve: 3, hard_brake: 2 }),
  cell(-6.2141, 106.8389, 9, 27, 7.3, { hard_brake: 6, sharp_swerve: 2, impact: 1 })
];

export const demoCredential: Credential = {
  credentialId: "demo-credential-001",
  uid: "demo-user",
  periodStart: new Date(now - 30 * day).toISOString(),
  periodEnd: new Date(now).toISOString(),
  mode: "motorcycle",
  score: 86,
  rideCount: 6,
  eventCount: 4,
  issuedAt: new Date(now).toISOString(),
  expiresAt: new Date(now + 90 * day).toISOString(),
  issuer: "Ridary demo",
  publicKeyId: "demo-key",
  payloadHash: "a".repeat(64),
  signature: "ZGVtby1zaWduYXR1cmU="
};
