import { generateKeyPairSync } from "node:crypto";
import { describe, expect, it } from "vitest";
import { createSigner } from "../src/signing";
import type { CredentialPayload } from "../src/types";

function makeKeys(): { privatePem: string; publicPem: string } {
  const { privateKey, publicKey } = generateKeyPairSync("ed25519");
  return {
    privatePem: privateKey.export({ type: "pkcs8", format: "pem" }).toString(),
    publicPem: publicKey.export({ type: "spki", format: "pem" }).toString()
  };
}

const payload: CredentialPayload = {
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

describe("signer", () => {
  it("signs and verifies a payload", () => {
    const keys = makeKeys();
    const signer = createSigner(keys.privatePem, keys.publicPem, "ridary-test-1");
    const signed = signer.sign(payload);

    expect(signed.payloadHash).toMatch(/^[a-f0-9]{64}$/);
    expect(signed.signature.length).toBeGreaterThan(20);
    expect(signer.verify(payload, signed.signature)).toBe(true);
  });

  it("rejects a tampered payload", () => {
    const keys = makeKeys();
    const signer = createSigner(keys.privatePem, keys.publicPem, "ridary-test-1");
    const signed = signer.sign(payload);

    expect(
      signer.verify({ ...payload, score: payload.score - 1 }, signed.signature)
    ).toBe(false);
  });

  it("rejects a malformed signature", () => {
    const keys = makeKeys();
    const signer = createSigner(keys.privatePem, keys.publicPem, "ridary-test-1");
    expect(signer.verify(payload, "not-a-signature")).toBe(false);
  });

  it("derives a key id when none is provided", () => {
    const keys = makeKeys();
    const signer = createSigner(keys.privatePem, keys.publicPem, "");
    expect(signer.publicKeyId).toMatch(/^[a-f0-9]{16}$/);
  });
});
