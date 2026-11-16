import { describe, expect, it } from "vitest";
import {
  formatDistance,
  formatDuration,
  formatPeriod,
  scoreBand,
  scoreColor
} from "../src/lib/format";

describe("format", () => {
  it("formats distance", () => {
    expect(formatDistance(850)).toBe("850 m");
    expect(formatDistance(1240)).toBe("1.2 km");
  });

  it("formats duration", () => {
    expect(formatDuration(65)).toBe("1:05");
    expect(formatDuration(3665)).toBe("1:01:05");
  });

  it("maps score bands", () => {
    expect(scoreBand(95)).toBe("A");
    expect(scoreBand(80)).toBe("B");
    expect(scoreBand(65)).toBe("C");
    expect(scoreBand(20)).toBe("D");
  });

  it("maps score colors", () => {
    expect(scoreColor(95)).toBe("#5be3c0");
    expect(scoreColor(20)).toBe("#ff6b6b");
  });

  it("formats a credential period", () => {
    expect(
      formatPeriod("2026-11-01T00:00:00.000Z", "2026-11-30T00:00:00.000Z")
    ).toContain("2026");
  });
});
