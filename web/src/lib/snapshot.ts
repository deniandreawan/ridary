import type { RideEvent, RideSnapshot } from "../types";

export function parseSnapshot(text: string): RideSnapshot | null {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start < 0 || end <= start) {
    return null;
  }
  try {
    const parsed: unknown = JSON.parse(text.slice(start, end + 1));
    if (!isRecord(parsed)) return null;
    if (typeof parsed.headline !== "string") return null;
    if (typeof parsed.summary !== "string") return null;
    if (typeof parsed.score !== "number") return null;
    if (typeof parsed.scoreRationale !== "string") return null;
    if (typeof parsed.coachingTip !== "string") return null;
    if (!Array.isArray(parsed.riskMoments)) return null;

    const riskMoments = parsed.riskMoments.flatMap((item) => {
      if (!isRecord(item)) return [];
      if (typeof item.type !== "string") return [];
      if (typeof item.atSeconds !== "number") return [];
      if (typeof item.severity !== "number") return [];
      if (typeof item.explanation !== "string") return [];
      return [
        {
          type: item.type as RideEvent["type"],
          atSeconds: Math.max(0, Math.round(item.atSeconds)),
          severity: Math.min(5, Math.max(1, Math.round(item.severity))),
          explanation: item.explanation
        }
      ];
    });

    return {
      headline: parsed.headline.slice(0, 80),
      summary: parsed.summary.slice(0, 600),
      riskMoments: riskMoments.slice(0, 5),
      score: Math.min(100, Math.max(0, Math.round(parsed.score))),
      scoreRationale: parsed.scoreRationale.slice(0, 300),
      coachingTip: parsed.coachingTip.slice(0, 200)
    };
  } catch {
    return null;
  }
}


function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
