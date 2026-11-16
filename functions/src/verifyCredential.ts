import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { REGION } from "./config";
import {
  isCredentialExpired,
  payloadFromUnknown,
  signedCredentialSchema
} from "./credential";
import { payloadHash, loadSignerFromEnv } from "./signing";
import { credentialIdSchema } from "./validation";
import type { SignedCredential } from "./types";

const db = getFirestore();

export interface VerifyCredentialResponse {
  valid: boolean;
  credential: SignedCredential | null;
  reason?: string;
}

export const verifyCredential = onCall(
  { region: REGION },
  async (request): Promise<VerifyCredentialResponse> => {
    const input = credentialIdSchema.parse(request.data ?? {});
    const snapshot = await db.doc(`credentials/${input.credentialId}`).get();

    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Credential not found.");
    }

    const raw: unknown = snapshot.data();
    const parsed = signedCredentialSchema.safeParse(raw);
    if (!parsed.success) {
      return {
        valid: false,
        credential: null,
        reason: "malformed-credential"
      };
    }

    const credential = parsed.data as SignedCredential;
    const payload = payloadFromUnknown(credential);

    let signer;
    try {
      signer = loadSignerFromEnv();
    } catch {
      throw new HttpsError(
        "failed-precondition",
        "Credential verification is not configured on the server."
      );
    }

    if (isCredentialExpired(payload.expiresAt)) {
      return {
        valid: false,
        credential: null,
        reason: "credential-expired"
      };
    }

    const hashMatches = payloadHash(payload) === credential.payloadHash;
    const signatureMatches = signer.verify(payload, credential.signature);

    if (!hashMatches || !signatureMatches) {
      return {
        valid: false,
        credential: null,
        reason: "signature-or-hash-mismatch"
      };
    }

    return {
      valid: true,
      credential
    };
  }
);
