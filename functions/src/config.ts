export const REGION = "us-central1";

export const CREDENTIAL_VALID_DAYS = 90;
export const INSURER_VIEW_VALID_DAYS = 7;
export const MAX_CREDENTIAL_RIDES = 100;
export const MAX_CREDENTIAL_EVENTS = 500;
export const MIN_RIDES_FOR_CREDENTIAL = 3;

export function credentialIssuer(): string {
  const value = process.env.CREDENTIAL_ISSUER?.trim();
  return value && value.length > 0 ? value : "Ridary";
}

export function webBaseUrl(): string {
  const value = process.env.WEB_BASE_URL?.trim();
  const base = value && value.length > 0 ? value : "http://localhost:5173";
  return base.replace(/\/+$/, "");
}
