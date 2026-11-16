import type { EventInput, EventType, RideInput } from "./types";

const EVENT_WEIGHTS: Record<EventType, number> = {
  hard_brake: 1.0,
  sharp_swerve: 1.2,
  impact: 4.0,
  crash_candidate: 5.0,
  long_stop: 0.2,
  route_deviation: 0.5,
  manual: 0.5
};

const MIN_RIDES_FOR_CREDENTIAL = 3;
const PENALTY_MULTIPLIER = 3;

export interface ScoreResult {
  score: number;
  totalPenalty: number;
  avgPenalty: number;
  rideCount: number;
  eventCount: number;
}

export function computeCredentialScore(
  rides: RideInput[],
  events: EventInput[]
): ScoreResult {
  const rideIds = new Set(rides.map((ride) => ride.id));
  const relevantEvents = events.filter((event) => rideIds.has(event.rideId));

  const totalPenalty = relevantEvents.reduce((sum, event) => {
    const weight = EVENT_WEIGHTS[event.type];
    const severity = clamp(event.severity, 1, 5);
    const confidence = clamp(event.confidence, 0, 1);
    return sum + severity * confidence * weight;
  }, 0);

  const avgPenalty = totalPenalty / Math.max(1, rides.length);
  const score = clamp(Math.round(100 - avgPenalty * PENALTY_MULTIPLIER), 0, 100);

  return {
    score,
    totalPenalty: round(totalPenalty),
    avgPenalty: round(avgPenalty),
    rideCount: rides.length,
    eventCount: relevantEvents.length
  };
}

export function isCredentialEligible(rideCount: number): boolean {
  return rideCount >= MIN_RIDES_FOR_CREDENTIAL;
}

export function scoreBand(score: number): "A" | "B" | "C" | "D" {
  if (score >= 90) {
    return "A";
  }
  if (score >= 75) {
    return "B";
  }
  if (score >= 60) {
    return "C";
  }
  return "D";
}

export function periodBounds(
  nowMs: number,
  days: number
): { startMs: number; endMs: number } {
  const safeDays = Math.max(1, Math.min(365, Math.floor(days)));
  return {
    startMs: nowMs - safeDays * 24 * 60 * 60 * 1000,
    endMs: nowMs
  };
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

function round(value: number): number {
  return Math.round(value * 100) / 100;
}
