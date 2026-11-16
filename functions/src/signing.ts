import {
  createHash,
  createPrivateKey,
  createPublicKey,
  sign,
  verify
} from "node:crypto";
import { canonicalJson } from "./canonical-json";
import type { CredentialPayload } from "./types";

export interface Signer {
  publicKeyId: string;
  publicKeyPem: string;
  sign(payload: CredentialPayload): { signature: string; payloadHash: string };
  verify(payload: CredentialPayload, signatureBase64: string): boolean;
}

export function payloadHash(payload: CredentialPayload): string {
  return createHash("sha256").update(canonicalJson(payload), "utf8").digest("hex");
}

function normalizePem(value: string): string {
  return value.replace(/\\n/g, "\n").trim();
}

export function createSigner(
  privateKeyPem: string,
  publicKeyPem: string,
  publicKeyId: string
): Signer {
  const normalizedPrivate = normalizePem(privateKeyPem);
  const normalizedPublic = normalizePem(publicKeyPem);
  const privateKey = createPrivateKey(normalizedPrivate);
  const publicKey = createPublicKey(normalizedPublic);
  const resolvedKeyId =
    publicKeyId.trim().length > 0
      ? publicKeyId.trim()
      : createHash("sha256")
          .update(normalizedPublic, "utf8")
          .digest("hex")
          .slice(0, 16);

  return {
    publicKeyId: resolvedKeyId,
    publicKeyPem: normalizedPublic,
    sign(payload: CredentialPayload): {
      signature: string;
      payloadHash: string;
    } {
      const bytes = Buffer.from(canonicalJson(payload), "utf8");
      return {
        payloadHash: createHash("sha256").update(bytes).digest("hex"),
        signature: sign(null, bytes, privateKey).toString("base64")
      };
    },
    verify(payload: CredentialPayload, signatureBase64: string): boolean {
      try {
        return verify(
          null,
          Buffer.from(canonicalJson(payload), "utf8"),
          publicKey,
          Buffer.from(signatureBase64, "base64")
        );
      } catch {
        return false;
      }
    }
  };
}

export function loadSignerFromEnv(): Signer {
  const privateKeyPem = process.env.CREDENTIAL_PRIVATE_KEY_PEM;
  const publicKeyPem = process.env.CREDENTIAL_PUBLIC_KEY_PEM;
  const publicKeyId = process.env.PUBLIC_KEY_ID ?? "";

  if (!privateKeyPem || !publicKeyPem) {
    throw new Error(
      "Credential signing keys are missing. Set CREDENTIAL_PRIVATE_KEY_PEM and CREDENTIAL_PUBLIC_KEY_PEM."
    );
  }

  return createSigner(privateKeyPem, publicKeyPem, publicKeyId);
}
