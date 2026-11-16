import { z } from "zod";
import { RIDE_MODES } from "./types";
import type { CredentialPayload, SignedCredential } from "./types";

const isoDate = z.string().datetime({ offset: true });

export const credentialPayloadSchema = z
  .object({
    credentialId: z.string().min(8).max(128),
    uid: z.string().min(1).max(128),
    periodStart: isoDate,
    periodEnd: isoDate,
    mode: z.enum(RIDE_MODES),
    score: z.number().int().min(0).max(100),
    rideCount: z.number().int().nonnegative(),
    eventCount: z.number().int().nonnegative(),
    issuedAt: isoDate,
    expiresAt: isoDate,
    issuer: z.string().min(1).max(120),
    publicKeyId: z.string().min(1).max(64)
  })
  .passthrough();

export const credentialDocSchema = credentialPayloadSchema.extend({
  payloadHash: z.string().regex(/^[a-f0-9]{64}$/),
  signature: z.string().min(1)
});

export const signedCredentialSchema = credentialDocSchema;

export function payloadFromUnknown(data: unknown): CredentialPayload {
  const parsed = credentialPayloadSchema.parse(data);
  return {
    credentialId: parsed.credentialId,
    uid: parsed.uid,
    periodStart: parsed.periodStart,
    periodEnd: parsed.periodEnd,
    mode: parsed.mode,
    score: parsed.score,
    rideCount: parsed.rideCount,
    eventCount: parsed.eventCount,
    issuedAt: parsed.issuedAt,
    expiresAt: parsed.expiresAt,
    issuer: parsed.issuer,
    publicKeyId: parsed.publicKeyId
  };
}

export function signedCredentialFromUnknown(data: unknown): SignedCredential {
  const parsed = signedCredentialSchema.parse(data);
  return {
    ...payloadFromUnknown(parsed),
    payloadHash: parsed.payloadHash,
    signature: parsed.signature
  };
}


export function isCredentialExpired(
  expiresAt: string,
  nowMs: number = Date.now()
): boolean {
  const parsed = Date.parse(expiresAt);
  return !Number.isFinite(parsed) || parsed <= nowMs;
}
