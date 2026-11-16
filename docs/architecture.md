# Architecture

Ridary is three clients over one privacy-preserving contract:

```
[iPhone — field capture]
CoreLocation + CoreMotion (background location session)
  → deterministic event candidates
  → SwiftData/file-backed local store (protected)
  → foreground only:
      Firebase AI Logic / Apple Foundation Models
        - event interpreter
        - ride snapshot
        - incident interview + statement
  → evidence packet (local hash + SHA-256)
        │ opt-in: derived summary + coarse event points only
        ▼
[Firebase]
Firestore: rides, events, incidents, riskCells, credentials, feedback
Cloud Functions: aggregateRisk, issueCredential, verifyCredential,
                 createInsurerView, getWeeklyStats
Cloud AI / Gemini: cross-rider risk, weekly feedback (credential narrative: roadmap)
        ▲
[Web — React + MapLibre + Chrome Nano]
Dashboard, community risk map, credential, insurer view
```

## iOS

- **Capture**: `RideCaptureService` runs a foreground service/location session
  with `CLLocationManager` and `CMMotionManager`. It records location, speed,
  altitude, user acceleration, and rotation rate at 10 Hz motion / adaptive GPS.
- **Detection**: `EventDetector` is deterministic and testable. It emits
  candidate events, never automatic emergency calls. A candidate is evidence
  for the AI, not a confirmed incident.
- **Local store**: `LocalRideStore` is an actor writing JSON files with atomic
  writes and file protection. Raw samples never enter Firestore.
- **Evidence**: `EvidenceVault` creates a canonical evidence packet and a
  SHA-256 hash. The packet is stored locally; the incident record syncs only
  when the user chooses to share.
- **AI**: `FirebaseAIService` is the only production implementation of
  `AIService`. It wraps Firebase AI Logic `GenerativeModelSession` and exposes
  the model version so the UI can show `ON_DEVICE` vs `IN_CLOUD`.
- **UI**: SwiftUI, Observation/Combine view models, a dark night-ride theme,
  explicit privacy affordances, and source badges for every AI output.

## Web

- Vite + React + TypeScript.
- Firebase Auth/Firestore/Functions/App Check/AI Logic.
- MapLibre GL with CARTO dark raster tiles; risk cells are rendered as a
  GeoJSON circle layer, route previews as a line layer.
- Chrome Nano is used through `firebase/ai` with `InferenceMode.PREFER_ON_DEVICE`.
- The dashboard has a local demo mode when Firebase env values are absent.

## Functions

| Function | Trigger | Responsibility |
|---|---|---|
| `aggregateRisk` | Firestore create on `events/{id}` | Transactionally update `riskCells/{mode_geohash}` |
| `issueCredential` | Callable, auth + App Check | Check eligibility, score, sign Ed25519, store |
| `verifyCredential` | Callable | Recompute hash and verify Ed25519 signature |
| `createInsurerView` | Callable, auth + App Check | Create a short-lived redacted public view |
| `getWeeklyStats` | Callable, auth + App Check | Return bounded ride/event aggregates for cloud AI |

Cloud Functions do **not** call Gemini. The client calls Firebase AI Logic
directly, so the AI inference path stays on the supported SDK and App Check is
enforced end-to-end.

## Firestore shape

- `users/{uid}` — local profile and consent flags.
- `rides/{rideId}` — derived summary, score, inference source, coarse geohash,
  optional route preview.
- `events/{eventId}` — type, severity, confidence, geohash, summary, source.
- `incidents/{incidentId}` — hash, summary, status. Evidence stays local.
- `riskCells/{mode_geohash}` — public aggregate: count, severity sum, confidence
  sum, top types, last update.
- `credentials/{credentialId}` — owner-only signed credential.
- `feedback/{uid}/weeks/{weekId}` — owner-only weekly feedback.
- `insurerViews/{token}` — public, token-addressed redacted credential.

## Failure behavior

- Missing Firebase config → local demo mode; no crash.
- Missing on-device model → `PREFER_ON_DEVICE` cloud fallback where allowed.
- Sensitive incident flow with no on-device model → local deterministic
  statement, **not** a silent cloud upload.
- AI returns malformed JSON → deterministic local snapshot with `Rules` badge.
- Network loss during capture → local assets continue; Firestore writes are
  opt-in and retried manually through refresh.
- Interrupted app session → active-session marker is cleared on next launch and
  the rider is told the previous ride was interrupted.

## Testing

- iOS: 24 XCTest cases for geohash, event detection, stats, scoring, evidence
  hashing, JSON extraction, and local store round-trips.
- Web: 23 Vitest cases for geohash, formatting, risk aggregation, snapshot
  parsing, and local review fallback.
- Functions: 33 Vitest cases for scoring, canonical JSON, Ed25519 signing,
  geohash, risk merging, and credential contracts.
- Swift build uses `SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`.
- Web build uses strict TypeScript, ESLint, and a production Vite build.
