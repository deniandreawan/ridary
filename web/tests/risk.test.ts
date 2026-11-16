import { describe, expect, it } from "vitest";
import { demoRiskCells } from "../src/data/demo";
import {
  riskFeatureCollection,
  riskPoints,
  severityColor,
  topRiskCell
} from "../src/lib/risk";

describe("risk", () => {
  it("converts cells into map points", () => {
    const points = riskPoints(demoRiskCells);
    expect(points.length).toBe(demoRiskCells.length);
    expect(points[0]?.color).toMatch(/^#/);
    expect(points[0]?.radius).toBeGreaterThan(0);
  });

  it("builds a valid GeoJSON feature collection", () => {
    const collection = riskFeatureCollection(demoRiskCells);
    expect(collection.type).toBe("FeatureCollection");
    expect(collection.features.length).toBe(demoRiskCells.length);
    expect(collection.features[0]?.geometry.type).toBe("Point");
  });

  it("maps severity to color", () => {
    expect(severityColor(4.5)).toBe("#ff6b6b");
    expect(severityColor(3.2)).toBe("#ff9f5a");
    expect(severityColor(2.1)).toBe("#ffb84d");
    expect(severityColor(1)).toBe("#5be3c0");
  });

  it("finds the hottest cell", () => {
    const hottest = topRiskCell(demoRiskCells);
    expect(hottest).not.toBeNull();
    expect(hottest?.count).toBeGreaterThan(0);
  });
});
