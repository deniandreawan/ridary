#!/usr/bin/env node
import { generateKeyPairSync } from "node:crypto";

const { privateKey, publicKey } = generateKeyPairSync("ed25519");
const privatePem = privateKey.export({ type: "pkcs8", format: "pem" }).toString();
const publicPem = publicKey.export({ type: "spki", format: "pem" }).toString();

const escape = (value) => value.replace(/\n/g, "\\n");

console.log("# Add these values to functions/.env or your secret manager.");
console.log(`CREDENTIAL_PRIVATE_KEY_PEM="${escape(privatePem)}"`);
console.log(`CREDENTIAL_PUBLIC_KEY_PEM="${escape(publicPem)}"`);
console.log('CREDENTIAL_ISSUER="Ridary"');
console.log('PUBLIC_KEY_ID="ridary-dev-1"');
console.log('WEB_BASE_URL="http://localhost:5173"');
