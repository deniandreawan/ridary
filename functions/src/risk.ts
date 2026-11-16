import type { EventInput, RiskCellState } from "./types";

export function mergeRiskCell(
  previous: RiskCellState | undefined,
  event: EventInput
): RiskCellState {
  const base: RiskCellState = previous ?? {
    count: 0,
    severitySum: 0,
    confidenceSum: 0,
    topTypes: {}
  };

  const topTypes: Record<string, number> = { ...base.topTypes };
  topTypes[event.type] = (topTypes[event.type] ?? 0) + 1;

  return {
    count: base.count + 1,
    severitySum: round(base.severitySum + event.severity),
    confidenceSum: round(base.confidenceSum + event.confidence),
    topTypes
  };
}

export function riskCellId(mode: string, geohash: string): string {
  return `${mode}_${geohash}`;
}

export function normalizeRiskCell(value: unknown): RiskCellState | undefined {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return undefined;
  }
  const record = value as Record<string, unknown>;
  const topTypes: Record<string, number> = {};
  if (
    typeof record.topTypes === "object" &&
    record.topTypes !== null &&
    !Array.isArray(record.topTypes)
  ) {
    for (const [key, count] of Object.entries(
      record.topTypes as Record<string, unknown>
    )) {
      if (typeof count === "number" && Number.isFinite(count) && count >= 0) {
        topTypes[key] = count;
      }
    }
  }

  return {
    count:
      typeof record.count === "number" && Number.isFinite(record.count)
        ? Math.max(0, record.count)
        : 0,
    severitySum:
      typeof record.severitySum === "number" &&
      Number.isFinite(record.severitySum)
        ? Math.max(0, record.severitySum)
        : 0,
    confidenceSum:
      typeof record.confidenceSum === "number" &&
      Number.isFinite(record.confidenceSum)
        ? Math.max(0, record.confidenceSum)
        : 0,
    topTypes
  };
}

function round(value: number): number {
  return Math.round(value * 1000) / 1000;
}
