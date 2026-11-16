# Privacy and security model

## Data classification

| Data | Where it lives | Who can read it |
|---|---|---|
| Raw GPS route, speed, altitude | iPhone local store | Rider, on-device app |
| Raw accelerometer / gyroscope windows | iPhone local store / evidence file | Rider, on-device app |
| Incident statement and evidence PDF | iPhone local store | Rider; exported only by rider |
| Ride summary, score, inference source | Firestore `rides/{id}` | Owner |
| Event type, severity, confidence, coarse geohash | Firestore `events/{id}` and `riskCells` aggregate | Owner for events; public for aggregate cells |
| Signed credential | Firestore `credentials/{id}` | Owner; verification endpoint |
| Insurer view | Firestore `insurerViews/{token}` | Anyone with the unguessable token, for 7 days |
| Cyclic weekly feedback | Firestore `feedback/{uid}/weeks/{id}` | Owner |

Raw GPS and IMU data are never written to Firestore by the client. The app does
not upload evidence automatically. The optional route preview is a separate
consent flag and is capped at 128 points.

## Threat model

The design assumes:

- A rider may be retaliated against for keeping a record.
- A lost or seized phone should not become a full location history for an
  attacker.
- A malicious client may try to write extra fields, forge provenance, or read
  another rider’s rides.
- A cloud provider or insurer should not need raw route data to answer the
  product question.
- The AI may be wrong or unavailable, and the UI must say so.

## Controls

- **Local file protection**: local files are written atomically with
  `FileProtectionType.complete` on iOS. Evidence is kept in the app sandbox.
- **Hashing**: evidence packets are canonical JSON hashed with SHA-256. The hash
  is stored in the incident record; the file is local.
- **Firestore rules**: owner-only reads/writes for rides, events, incidents,
  feedback, and credentials; public read only for aggregate `riskCells` and
  token-addressed `insurerViews`; client writes to aggregate/credential
  collections are denied.
- **Field allow-lists**: rules reject unknown fields, missing provenance,
  invalid geohashes, invalid event types, and out-of-range severity/confidence.
- **App Check**: enforced for AI Logic and credential callables. The iOS build
  uses a registered debug token for the hackathon; production should switch to
  App Attest. The web build uses reCAPTCHA Enterprise or a registered debug
  token.
- **Credential signing**: Ed25519 in a Cloud Function. The private key is loaded
  from the Functions environment; it is never in the app or the repo. The
  credential contains a payload hash and signature. `verifyCredential`
  recomputes the canonical payload and checks the signature.
- **Insurer views**: short-lived token documents with no `uid`, no route, no
  sensor data, and no evidence file. They expose only the credential fields.
- **No automatic emergency behavior**: the app does not call emergency services,
  auto-dial, or promise that help is coming.
- **AI provenance**: on-device / cloud / fallback / rules are visible. Sensitive
  incident flow never silently falls back to cloud.

## Residual risks

- A compromised or unlocked phone can expose local data. Ridary does not claim
  hardware-grade forensic resistance.
- iCloud device backups may include app data depending on the user’s settings;
  the app does not control Apple’s backup policy.
- Screenshots, screen recording, and sharing a PDF are outside the app’s control.
- Small aggregate cells can leak patterns. Risk cells use precision-6 geohashes,
  public cells are aggregates, and a single event never becomes a public map
  point by itself in the product narrative. Production should enforce a minimum
  contributor threshold in the aggregation function.
- The insurer integration is a mock. It is not a carrier contract and the
  credential is not a legal or insurance determination.
- AI can be wrong. Event explanations are screening signals, not certified
  mechanical, medical, or legal findings.
- Background capture can be interrupted by the OS. The app detects an
  interrupted session, clears the marker, and tells the rider.
- The demo credential is static sample data and is labelled as such.

## Operational practices

- Do not commit `GoogleService-Info.plist`, `functions/.env`, App Check debug
  tokens, or signing keys.
- Rotate the Ed25519 key and the public key id if a key is exposed.
- Deploy Firestore rules and indexes together with Functions.
- Treat `insurerViews` tokens as bearer secrets; they expire after seven days.
- Keep the app’s App Check enforcement on for AI Logic and callables.
- For production, replace the debug provider with App Attest and move the signing
  keys to a secret manager.
