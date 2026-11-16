import { describe, expect, it } from "vitest";
import { demoRiskCells } from "../src/data/demo";
import {
  localCommunityInsight,
  parseCommunityInsight
} from "../src/lib/communityInsight";

describe("community insight", () => {
  it("parses a valid insight", () => {
    const parsed = parseCommunityInsight(
      JSON.stringify({
        headline: "Wet junction cluster",
        summary: "Several hard brakes cluster near one junction.",
        hotspots: [
          {
            geohash: "qqguxm",
            explanation: "Hard brakes cluster here."
          }
        ],
        action: "Approach the junction slower."
      })
    );
    expect(parsed?.headline).toBe("Wet junction cluster");
    expect(parsed?.hotspots).toHaveLength(1);
  });

  it("returns null for malformed output", () => {
    expect(parseCommunityInsight("not json")).toBeNull();
    expect(parseCommunityInsight(JSON.stringify({ headline: "x" }))).toBeNull();
  });

  it("builds a local fallback from cells", () => {
    const insight = localCommunityInsight(demoRiskCells);
    expect(insight.headline.length).toBeGreaterThan(0);
    expect(insight.summary.length).toBeGreaterThan(0);
    expect(insight.hotspots.length).toBeGreaterThan(0);
    expect(insight.action.length).toBeGreaterThan(0);
  });
});
