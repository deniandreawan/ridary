import { describe, expect, it } from "vitest";
import {
  credentialPayloadSchema,
  isCredentialExpired,
  payloadFromUnknown,
  signedCredentialSchema
} from "../src/credential";

const payload = {
  credentialId: "cred_test_0001",
  uid: "user_123",
  periodStart: "2026-11-01T00:00:00.000Z",
  periodEnd: "2026-11-30T00:00:00.000Z",
  mode: "motorcycle",
  score: 92,
  rideCount: 8,
  eventCount: 3,
  issuedAt: "2026-11-30T00:00:00.000Z",
  expiresAt: "2027-02-28T00:00:00.000Z",
  issuer: "Ridary",
  publicKeyId: "ridary-test-1"
};

describe("credential contracts", () => {
  it("accepts a valid payload", () => {
    expect(credentialPayloadSchema.parse(payload)).toMatchObject(payload);
  });

  it("strips extra fields when building the signed payload", () => {
    const result = payloadFromUnknown({ ...payload, extra: "ignored" });
    expect(result).toEqual(payload);
  });

  it("accepts a signed credential", () => {
    const result = signedCredentialSchema.parse({
      ...payload,
      payloadHash: "a".repeat(64),
      signature: "c2lnbmF0dXJl"
    });
    expect(result.payloadHash).toHaveLength(64);
  });

  it("rejects an invalid score", () => {
    expect(() =>
      credentialPayloadSchema.parse({ ...payload, score: 101 })
    ).toThrow();
  });
});


describe("credential expiry", () => {
  it("accepts a future expiry", () => {
    expect(
      isCredentialExpired("2027-02-28T00:00:00.000Z", Date.UTC(2026, 10, 30))
    ).toBe(false);
  });

  it("rejects a past expiry", () => {
    expect(
      isCredentialExpired("2026-01-01T00:00:00.000Z", Date.UTC(2026, 10, 30))
    ).toBe(true);
  });

  it("rejects an unreadable expiry", () => {
    expect(isCredentialExpired("not-a-date", Date.UTC(2026, 10, 30))).toBe(true);
  });
});
