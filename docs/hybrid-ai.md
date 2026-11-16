# Hybrid AI reasoning

Firebase AI Logic's value here is not "small model vs big model". It is a
deliberate trust boundary:

- **On-device**: sensitive data, offline moments, immediate explanation.
- **Cloud**: cross-rider context, larger reasoning, signed aggregate artifacts.

## Platform matrix

| Platform | On-device model | Cloud fallback |
|---|---|---|
| iOS 26+ | Apple Foundation Models via Firebase AI Logic (`firebase-ios-sdk` 12.13.0, `FirebaseAI`) | Gemini Developer API |
| Chrome desktop 139+ | Gemini Nano via the Chrome Prompt API, wrapped by `firebase/ai` | Gemini Developer API |
| Android (roadmap) | Gemini Nano 4 via `firebase-ai-ondevice` | Gemini Developer API |

The project intentionally uses **native SwiftUI + Web** instead of Flutter.
Firebase AI Logic's hybrid on-device path is a native platform integration for
Apple, Android, and Chrome; the Flutter plugin does not expose the same
on-device hybrid modes. A Flutter implementation would need platform channels
into Swift/Kotlin and would still not be a single cross-platform on-device
story.

## Feature routing

| Feature | Mode | Rationale |
|---|---|---|
| Ride snapshot | `PREFER_ON_DEVICE` | Sensitive, useful offline, fallback keeps old devices working |
| Event interpreter | `PREFER_ON_DEVICE` | Sensor windows are private and latency-sensitive |
| Incident interview | `ONLY_ON_DEVICE` | Evidence must not leave the phone silently |
| Weekly feedback | `PREFER_IN_CLOUD` | Cross-ride context |
| Cross-rider analyst | `ONLY_IN_CLOUD` | It needs aggregates the device cannot see |
| Credential narrative (roadmap) | `ONLY_IN_CLOUD` | Issued from aggregate data |
| Insurer report (roadmap) | `PREFER_IN_CLOUD` | Final document generation |

## Why each side exists

Remove the on-device path:

- No offline snapshot.
- No private incident statement.
- No evidence preservation in a dead zone.
- The product's privacy promise disappears.

Remove the cloud path:

- No community risk map.
- No weekly pattern across rides.
- No signed credential or insurer view.
- The product loses its collective and economic value.

Both paths are required, for different jobs. That is the hybrid test the
judges should be able to repeat in one sentence.

## What is deterministic and what is AI

This distinction is deliberate and disclosed:

- **Deterministic**: GPS/IMU capture, candidate event detection, safety score
  weighting, geohash, evidence hash, credential signing.
- **AI**: plain-language event interpretation, ride snapshot, incident
  interview/statement, weekly narrative, community insight. Credential explanation is roadmap.

The deterministic layer is the reliable backbone. The AI layer turns raw signal
candidates into something a human can use. The UI never pretends a deterministic
fallback is a model result.

## Visible provenance

Every AI output is labelled:

- `On device` — Apple Foundation Models or Chrome Nano.
- `In cloud` — Gemini via Firebase AI Logic.
- `Fallback` — the preferred path failed and the SDK used the other path.
- `Rules` — the local deterministic fallback.

The iOS implementation reads `response.rawResponse.modelVersion`; the web
implementation reads `response.inferenceSource`.

## Platform limits (honest)

- iOS on-device inference works only while the app is in the foreground.
- iOS 26 Apple Foundation Models are text-only; image input arrives with iOS 27.
- Chrome Nano requires desktop Chrome 139+, a flag, and a one-time model
  download.
- On-device models have a smaller context and sometimes reject a request shape;
  the SDK fallback is visible, never hidden.
- Server prompt templates, Live API, and count-token calls are not used in the
  hybrid path.

## No-cheat rules used in this repository

- No hardcoded "AI-looking" output: every demo badge says `Demo`.
- The credential is actually signed with Ed25519; verification recomputes the
  canonical payload hash.
- The deterministic detector drives real captured samples; the AI does not
  invent events.
- Firestore rules reject extra fields and missing provenance.
- The insurer view never receives raw route or sensor data.
