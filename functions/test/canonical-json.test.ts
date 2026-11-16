import { describe, expect, it } from "vitest";
import { canonicalJson } from "../src/canonical-json";

describe("canonicalJson", () => {
  it("sorts object keys recursively", () => {
    expect(canonicalJson({ b: 2, a: 1, nested: { z: true, y: false } })).toBe(
      '{"a":1,"b":2,"nested":{"y":false,"z":true}}'
    );
  });

  it("preserves array order", () => {
    expect(canonicalJson([3, 1, 2])).toBe("[3,1,2]");
  });

  it("rejects undefined values", () => {
    expect(() => canonicalJson({ a: undefined })).toThrow(/undefined/);
  });

  it("rejects non-finite numbers", () => {
    expect(() => canonicalJson({ a: Number.NaN })).toThrow(/non-finite/);
  });
});
