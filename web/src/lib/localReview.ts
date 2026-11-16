import type { Ride, RideSnapshot } from "../types";
import { formatDistance, formatDuration, scoreBand } from "./format";

export function localRideReview(ride: Ride): RideSnapshot {
  const moments = [...ride.events]
    .sort((a, b) => b.severity - a.severity)
    .slice(0, 3)
    .map((event) => ({
      type: event.type,
      atSeconds: Math.max(
        0,
        Math.round((event.occurredAtMs - ride.startedAtMs) / 1000)
      ),
      severity: Math.min(5, Math.max(1, event.severity)),
      explanation: event.summary
    }));

  const eventText =
    ride.events.length === 0
      ? "No safety moments were flagged."
      : `${ride.events.length} safety moment${
          ride.events.length === 1 ? "" : "s"
        } were flagged.`;

  const mostCommon = mostCommonEventType(ride);

  return {
    headline: `${scoreBand(ride.score)} ride · ${formatDistance(ride.distanceM)}`,
    summary: `You rode ${formatDistance(ride.distanceM)} in ${formatDuration(
      ride.durationS
    )}. ${eventText}`,
    riskMoments: moments,
    score: ride.score,
    scoreRationale:
      "This local review uses the deterministic event candidates because a browser model was not available.",
    coachingTip: tipFor(mostCommon)
  };
}

function mostCommonEventType(ride: Ride): Ride["events"][number]["type"] | null {
  const counts = new Map<Ride["events"][number]["type"], number>();
  for (const event of ride.events) {
    counts.set(event.type, (counts.get(event.type) ?? 0) + 1);
  }
  let best: Ride["events"][number]["type"] | null = null;
  let bestCount = 0;
  for (const [type, count] of counts) {
    if (count > bestCount) {
      best = type;
      bestCount = count;
    }
  }
  return best;
}

function tipFor(type: Ride["events"][number]["type"] | null): string {
  switch (type) {
    case "hard_brake":
      return "Leave a little more following distance so you can brake earlier.";
    case "sharp_swerve":
      return "Scan further ahead and make smaller, earlier direction changes.";
    case "impact":
    case "crash_candidate":
      return "Review the locked evidence and check the road surface before riding again.";
    case "long_stop":
      return "Plan a shorter route or a safer rest stop next time.";
    case "route_deviation":
      return "Set your route before you leave and keep the phone untouched.";
    case "manual":
      return "Lock evidence when it matters, then add a short note while it is fresh.";
    default:
      return "Keep the same smooth, predictable habits on your next ride.";
  }
}
