import { describe, expect, it } from "vitest";
import {
  computeCredentialScore,
  isCredentialEligible,
  periodBounds,
  scoreBand
} from "../src/scoring";
import type { EventInput, RideInput } from "../src/types";

const rides: RideInput[] = [
  { id: "r1", mode: "motorcycle", startedAtMs: 1, distanceM: 1000, durationS: 600 },
  { id: "r2", mode: "motorcycle", startedAtMs: 2, distanceM: 1200, durationS: 700 },
  { id: "r3", mode: "motorcycle", startedAtMs: 3, distanceM: 900, durationS: 500 }
];

describe("scoring", () => {
  it("gives 100 for three clean rides", () => {
    const result = computeCredentialScore(rides, []);
    expect(result.score).toBe(100);
    expect(result.rideCount).toBe(3);
    expect(result.eventCount).toBe(0);
  });

  it("penalizes a hard brake modestly", () => {
    const events: EventInput[] = [
      {
        rideId: "r1",
        mode: "motorcycle",
        type: "hard_brake",
        severity: 3,
        confidence: 0.85,
        occurredAtMs: 10
      }
    ];
    const result = computeCredentialScore(rides, events);
    expect(result.score).toBe(97);
    expect(result.eventCount).toBe(1);
  });

  it("penalizes a crash candidate strongly", () => {
    const events: EventInput[] = [
      {
        rideId: "r1",
        mode: "motorcycle",
        type: "crash_candidate",
        severity: 5,
        confidence: 0.8,
        occurredAtMs: 10
      }
    ];
    const result = computeCredentialScore(rides, events);
    expect(result.score).toBe(80);
  });

  it("ignores events from rides outside the period", () => {
    const events: EventInput[] = [
      {
        rideId: "outside",
        mode: "motorcycle",
        type: "impact",
        severity: 5,
        confidence: 1,
        occurredAtMs: 10
      }
    ];
    expect(computeCredentialScore(rides, events).score).toBe(100);
  });

  it("requires at least three rides", () => {
    expect(isCredentialEligible(2)).toBe(false);
    expect(isCredentialEligible(3)).toBe(true);
  });

  it("maps score bands", () => {
    expect(scoreBand(95)).toBe("A");
    expect(scoreBand(80)).toBe("B");
    expect(scoreBand(65)).toBe("C");
    expect(scoreBand(20)).toBe("D");
  });

  it("computes period bounds", () => {
    const now = Date.UTC(2026, 10, 30);
    const { startMs, endMs } = periodBounds(now, 30);
    expect(endMs).toBe(now);
    expect(now - startMs).toBe(30 * 24 * 60 * 60 * 1000);
  });
});
