import { describe, expect, it } from "vitest";
import { mergeRiskCell, normalizeRiskCell, riskCellId } from "../src/risk";
import type { EventInput } from "../src/types";

const event: EventInput = {
  rideId: "r1",
  mode: "motorcycle",
  type: "hard_brake",
  severity: 3,
  confidence: 0.8,
  occurredAtMs: 1
};

describe("risk aggregation", () => {
  it("builds a cell id from mode and geohash", () => {
    expect(riskCellId("motorcycle", "qqgx4x")).toBe("motorcycle_qqgx4x");
  });

  it("merges the first event", () => {
    const cell = mergeRiskCell(undefined, event);
    expect(cell.count).toBe(1);
    expect(cell.severitySum).toBe(3);
    expect(cell.confidenceSum).toBe(0.8);
    expect(cell.topTypes).toEqual({ hard_brake: 1 });
  });

  it("merges a second event without mutating the previous cell", () => {
    const previous = {
      count: 1,
      severitySum: 3,
      confidenceSum: 0.8,
      topTypes: { hard_brake: 1 }
    };
    const next = mergeRiskCell(previous, {
      ...event,
      type: "impact",
      severity: 5,
      confidence: 0.9
    });

    expect(next.count).toBe(2);
    expect(next.severitySum).toBe(8);
    expect(next.confidenceSum).toBe(1.7);
    expect(next.topTypes).toEqual({ hard_brake: 1, impact: 1 });
    expect(previous.count).toBe(1);
    expect(previous.topTypes).toEqual({ hard_brake: 1 });
  });
});


describe("normalizeRiskCell", () => {
  it("rejects non-objects", () => {
    expect(normalizeRiskCell(null)).toBeUndefined();
    expect(normalizeRiskCell([])).toBeUndefined();
    expect(normalizeRiskCell("bad")).toBeUndefined();
  });

  it("normalizes malformed numeric fields", () => {
    const cell = normalizeRiskCell({
      count: "3",
      severitySum: Number.NaN,
      confidenceSum: 2,
      topTypes: { hard_brake: 2, broken: "x" }
    });
    expect(cell).toEqual({
      count: 0,
      severitySum: 0,
      confidenceSum: 2,
      topTypes: { hard_brake: 2 }
    });
  });
});
