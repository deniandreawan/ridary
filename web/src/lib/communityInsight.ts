import type { CommunityInsight, RiskCell } from "../types";
import { decodeGeohash } from "./geohash";

export function parseCommunityInsight(text: string): CommunityInsight | null {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start < 0 || end <= start) return null;
  try {
    const parsed: unknown = JSON.parse(text.slice(start, end + 1));
    if (!isRecord(parsed)) return null;
    if (typeof parsed.headline !== "string") return null;
    if (typeof parsed.summary !== "string") return null;
    if (typeof parsed.action !== "string") return null;
    if (!Array.isArray(parsed.hotspots)) return null;

    const hotspots = parsed.hotspots.flatMap((item) => {
      if (!isRecord(item)) return [];
      if (typeof item.geohash !== "string") return [];
      if (typeof item.explanation !== "string") return [];
      return [{ geohash: item.geohash, explanation: item.explanation }];
    });

    return {
      headline: parsed.headline.slice(0, 100),
      summary: parsed.summary.slice(0, 700),
      hotspots: hotspots.slice(0, 4),
      action: parsed.action.slice(0, 240)
    };
  } catch {
    return null;
  }
}

export function localCommunityInsight(cells: RiskCell[]): CommunityInsight {
  if (cells.length === 0) {
    return {
      headline: "No community cells yet",
      summary: "Risk cells appear after riders opt in to share anonymized event points.",
      hotspots: [],
      action: "Share anonymized event points from a ride to seed the map."
    };
  }

  const sorted = [...cells].sort(
    (a, b) => b.severitySum / b.count - a.severitySum / a.count
  );
  const top = sorted.slice(0, 2);
  const total = cells.reduce((sum, cell) => sum + cell.count, 0);
  const average =
    cells.reduce((sum, cell) => sum + cell.severitySum, 0) /
    Math.max(1, total);

  return {
    headline: "Community risk pattern",
    summary: `${cells.length} cells contain ${total} reported event points. The average severity is ${average.toFixed(
      1
    )}. The hottest cells deserve a closer look before the next ride.`,
    hotspots: top.map((cell) => ({
      geohash: cell.geohash,
      explanation: `${cell.count} events · avg severity ${(
        cell.severitySum / Math.max(1, cell.count)
      ).toFixed(1)} · ${cell.mode}`
    })),
    action:
      "Review the two hottest cells and choose a route or time that avoids the worst surface and traffic."
  };
}

export function cellCenter(cell: RiskCell): { lat: number; lon: number } | null {
  try {
    return decodeGeohash(cell.geohash);
  } catch {
    return null;
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
