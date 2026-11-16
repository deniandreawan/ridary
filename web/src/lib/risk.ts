import type { RiskCell } from "../types";
import { decodeGeohash } from "./geohash";

export interface RiskPoint {
  cell: RiskCell;
  lat: number;
  lon: number;
  averageSeverity: number;
  color: string;
  radius: number;
}

export interface RiskFeatureCollection {
  type: "FeatureCollection";
  features: Array<{
    type: "Feature";
    geometry: { type: "Point"; coordinates: [number, number] };
    properties: {
      geohash: string;
      count: number;
      severity: number;
      color: string;
      radius: number;
    };
  }>;
}

export function riskPoints(cells: RiskCell[]): RiskPoint[] {
  return cells.flatMap((cell) => {
    if (!/^[0-9b-hjkmnp-z]{1,12}$/.test(cell.geohash)) {
      return [];
    }
    try {
      const point = decodeGeohash(cell.geohash);
      const averageSeverity =
        cell.count > 0 ? cell.severitySum / cell.count : 0;
      return [
        {
          cell,
          lat: point.lat,
          lon: point.lon,
          averageSeverity,
          color: severityColor(averageSeverity),
          radius: Math.min(26, 5 + cell.count * 1.8)
        }
      ];
    } catch {
      return [];
    }
  });
}

export function riskFeatureCollection(
  cells: RiskCell[]
): RiskFeatureCollection {
  return {
    type: "FeatureCollection",
    features: riskPoints(cells).map((point) => ({
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: [point.lon, point.lat]
      },
      properties: {
        geohash: point.cell.geohash,
        count: point.cell.count,
        severity: point.averageSeverity,
        color: point.color,
        radius: point.radius
      }
    }))
  };
}

export function severityColor(averageSeverity: number): string {
  if (averageSeverity >= 4) return "#ff6b6b";
  if (averageSeverity >= 3) return "#ff9f5a";
  if (averageSeverity >= 2) return "#ffb84d";
  return "#5be3c0";
}

export function topRiskCell(cells: RiskCell[]): RiskCell | null {
  return (
    [...cells].sort((a, b) => b.severitySum / b.count - a.severitySum / a.count)[0] ??
    null
  );
}
