import { describe, expect, it } from "vitest";
import { demoRides } from "../src/data/demo";
import { localRideReview } from "../src/lib/localReview";

describe("localRideReview", () => {
  it("returns a structured snapshot for a ride", () => {
    const ride = demoRides[0];
    expect(ride).toBeDefined();
    if (!ride) return;

    const snapshot = localRideReview(ride);
    expect(snapshot.headline.length).toBeGreaterThan(0);
    expect(snapshot.summary.length).toBeGreaterThan(0);
    expect(snapshot.score).toBe(ride.score);
    expect(snapshot.riskMoments.length).toBeLessThanOrEqual(3);
    expect(snapshot.coachingTip.length).toBeGreaterThan(0);
  });

  it("handles a clean ride", () => {
    const ride = demoRides[2];
    expect(ride).toBeDefined();
    if (!ride) return;

    const snapshot = localRideReview(ride);
    expect(snapshot.riskMoments).toHaveLength(0);
    expect(snapshot.summary).toContain("No safety moments");
  });
});
