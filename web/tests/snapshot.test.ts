import { describe, expect, it } from "vitest";
import { parseSnapshot } from "../src/lib/snapshot";

const valid = {
  headline: "Clean commute",
  summary: "A steady ride with one moment.",
  riskMoments: [
    {
      type: "hard_brake",
      atSeconds: 42,
      severity: 3,
      explanation: "Hard braking near a wet junction."
    }
  ],
  score: 84,
  scoreRationale: "One moderate moment.",
  coachingTip: "Leave more following distance."
};

describe("parseSnapshot", () => {
  it("parses a plain JSON object", () => {
    const parsed = parseSnapshot(JSON.stringify(valid));
    expect(parsed?.headline).toBe("Clean commute");
    expect(parsed?.riskMoments).toHaveLength(1);
    expect(parsed?.score).toBe(84);
  });

  it("parses JSON inside a code fence", () => {
    const parsed = parseSnapshot(`\`\`\`json\n${JSON.stringify(valid)}\n\`\`\``);
    expect(parsed?.summary).toContain("steady ride");
  });

  it("returns null for malformed output", () => {
    expect(parseSnapshot("not json")).toBeNull();
    expect(parseSnapshot(JSON.stringify({ headline: "only a headline" }))).toBeNull();
  });

  it("clamps score and severity", () => {
    const parsed = parseSnapshot(
      JSON.stringify({
        ...valid,
        score: 140,
        riskMoments: [{ ...valid.riskMoments[0], severity: 9 }]
      })
    );
    expect(parsed?.score).toBe(100);
    expect(parsed?.riskMoments[0]?.severity).toBe(5);
  });
});
