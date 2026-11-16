# Three-minute demo script

Record in English, or include English subtitles. The first 30 seconds must explain
the idea and the hybrid AI reason. Show real functionality, not a slide deck.

## Pre-flight

- Firebase configured on iOS and web; App Check debug token registered.
- iPhone with iOS 26+ and Apple Intelligence enabled.
- Desktop Chrome 139+ with the Nano flag enabled and the model downloaded.
- At least three rides synced, or use the clearly labelled demo dashboard for
  the aggregate screens.
- Screen recording at 1080p; phone and laptop audio muted unless intentional.
- Have a second take ready for the on-device fallback path; never hide it.

## 0:00–0:20 — The problem and the promise

**Visual:** iPhone home screen, Ridary logo, then the Home screen.

**Narration:**
“A rider’s most important data is also the most sensitive: where they were,
how they moved, and what happened. Ridary records that privately on the phone.
On-device AI explains it offline; the cloud only sees what the rider chooses to
share.”

## 0:20–1:10 — A real ride

**Visual:** Start motorcycle ride, lock the phone, put it in a pocket, ride
briefly, stop. Show the Active Ride screen with elapsed time and one flagged
moment.

**Narration:**
“The phone stays in the pocket. No camera, no screen. GPS and motion are
captured locally. The deterministic detector flags a hard brake; it does not
call emergency services and it does not upload anything.”

Tap **Lock last 30 seconds** and open the incident sheet.

## 1:10–1:50 — On-device AI, including the sensitive path

**Visual:** End the ride, open the ride summary. Point at the `On device` badge.
Then open the incident, answer two questions, and tap **Draft statement**.

**Narration:**
“When the app opens, Apple Foundation Models run through Firebase AI Logic.
The summary, risk explanation, and incident statement stay on this iPhone.
The incident flow is pinned to on-device only. If the model is unavailable,
Ridary uses local rules instead of silently sending evidence to the cloud.”

Show the inference badge and the local SHA-256 hash. Do not claim court-grade
evidence.

## 1:50–2:30 — The cloud side: collective map and credential

**Visual:** Switch to the web dashboard. Show the community risk map, the latest
ride, then the Credential page. Create an insurer view and open
`/insurer/demo` (or the real token).

**Narration:**
“The cloud gets a different job. It aggregates anonymized event points into a
community risk map, and it issues a signed Ridary Proof. The insurer sees a
score, a period, and a signature — not the route, not the raw sensors, and not
the rider’s identity.”

If using live data, click **Verify signature** and show “Signature and hash
match”. If using the demo credential, say it is a demo.

## 2:30–3:00 — The hybrid split and the impact

**Visual:** Split screen: iOS `On device` badge, web `On device` / `In cloud`
badges, and the code architecture (or the README diagram).

**Narration:**
“This is hybrid inference as the product’s trust boundary: private at the edge,
collective in the cloud. Riders own the record; cities and insurers get proofs
instead of surveillance. The same data contracts are ready for Android next.”

End on the repo URL and the app name.

## Do not do

- Do not show a camera feed; the product is explicitly camera-free.
- Do not claim automatic crash detection or automatic emergency dispatch.
- Do not claim the credential is legal proof or an insurance guarantee.
- Do not present demo data as live data.
- Do not hide a cloud fallback; the source badge is part of the story.
