import { describe, expect, it } from "vitest";
import { encodeGeohash, isValidGeohash } from "../src/geohash";

describe("geohash", () => {
  it("encodes the origin to s00000 at precision 6", () => {
    expect(encodeGeohash(0, 0, 6)).toBe("s00000");
  });

  it("encodes Jakarta at precision 6 deterministically", () => {
    const hash = encodeGeohash(-6.2088, 106.8456, 6);
    expect(hash).toHaveLength(6);
    expect(hash).toBe("qqguxm");
  });

  it("matches known geohashes", () => {
    expect(encodeGeohash(37.7749, -122.4194, 6)).toBe("9q8yyk");
    expect(encodeGeohash(51.5074, -0.1278, 6)).toBe("gcpvj0");
  });

  it("supports precision 7", () => {
    expect(encodeGeohash(-6.2088, 106.8456, 7)).toHaveLength(7);
  });

  it("validates geohash shape", () => {
    expect(isValidGeohash("qqgx4x")).toBe(true);
    expect(isValidGeohash("QQGX4X")).toBe(false);
    expect(isValidGeohash("abc")).toBe(false);
  });

  it("rejects invalid coordinates", () => {
    expect(() => encodeGeohash(91, 0)).toThrow();
    expect(() => encodeGeohash(0, 181)).toThrow();
  });
});
