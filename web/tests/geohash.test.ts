import { describe, expect, it } from "vitest";
import { decodeGeohash, encodeGeohash, geohashCell } from "../src/lib/geohash";

describe("geohash", () => {
  it("encodes the origin", () => {
    expect(encodeGeohash(0, 0)).toBe("s00000");
  });

  it("encodes known coordinates", () => {
    expect(encodeGeohash(-6.2088, 106.8456)).toBe("qqguxm");
    expect(encodeGeohash(37.7749, -122.4194)).toBe("9q8yyk");
    expect(encodeGeohash(51.5074, -0.1278)).toBe("gcpvj0");
  });

  it("round-trips the center of a cell", () => {
    const hash = encodeGeohash(-6.2088, 106.8456);
    const decoded = decodeGeohash(hash);
    expect(decoded.lat).toBeCloseTo(-6.2088, 2);
    expect(decoded.lon).toBeCloseTo(106.8456, 2);
  });

  it("returns cell bounds", () => {
    const [latMin, lonMin, latMax, lonMax] = geohashCell("qqguxm");
    expect(latMin).toBeLessThan(latMax);
    expect(lonMin).toBeLessThan(lonMax);
  });

  it("rejects invalid input", () => {
    expect(() => encodeGeohash(91, 0)).toThrow();
    expect(() => decodeGeohash("!")).toThrow();
  });
});
