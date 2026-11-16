# Roadmap

## Now (hackathon build)

- iOS capture, local evidence, on-device snapshot and incident statement.
- Web dashboard, community risk map, credential, insurer view.
- Firebase AI Logic hybrid routing with visible provenance.
- Deterministic fallback for every AI path.
- 80 automated tests across iOS, web, and Functions.

## Next

### Android

- Kotlin + Jetpack Compose capture app.
- `firebase-ai-ondevice` with `PREFER_ON_DEVICE` / `ONLY_ON_DEVICE`.
- Foreground service with a visible recording notification.
- Shared JSON contracts and Firestore schema; no backend rewrite.
- Same credential and insurer view.

### iOS 27

- On-device image input for incident photos.
- On-device Vision OCR/barcode tools for evidence capture.
- Keep text-only path for iOS 26.

### Product

- Live hazard alerts from cached risk cells.
- Minimum-contributor threshold for public risk cells.
- Route-risk explanations grounded in city open data.
- Rider-owned data cooperative with opt-in licensing back to riders.
- Carrier/fleet integrations using the signed credential, not raw telemetry.
- Multi-language UI (English first; Indonesian next).

### Reliability

- Battery-aware sampling profiles and ride-length budgets.
- Low-power ring buffer with explicit session recovery.
- Offline map tile packs for the web dashboard and iOS.
- App Attest in production and secret-manager-backed signing keys.
- Firestore emulator rule tests in CI.
