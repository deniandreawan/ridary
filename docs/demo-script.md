# Demo video

Final cut: **2:42**. Watch the published video: <https://youtu.be/-5rdIeQ5ssE>. The contest allows up to 3 minutes; the first 3 minutes are
evaluated if a video is longer. The first 30 seconds explain the idea, the
rider, the problem, and the Firebase AI Logic hybrid reason.

The rendered source lives in `video/`. The voiceover guide is
[`video/scripts/voiceover.md`](../video/scripts/voiceover.md), the caption track
is [`captions.srt`](../video/captions.srt), and the local export is
`video/out/ridary-demo-1080p.mp4` (ignored by git).

## Pre-flight

- Web: <https://ridary-demo.web.app>; open the demo dashboard without login.
- iOS: choose **Explore local demo** from the sign-in screen.
- Use labelled sample rides only. Do not put real rider data or credentials in
  the repository or the demo.
- Show the source badge honestly: `On device`, `In cloud`, `Fallback`, or
  `Rules`.
- The current cut uses a local Kokoro `af_heart` voice and burned-in English
  captions. No face is required.
- The iOS simulator cannot provide realistic motion speed; the timer and live
  map are clearly labelled as simulator/sample footage.

## 0:00–0:12 — The idea

**Visual:** Ridary mark, route line, “Every ride. On record.” and the private
route card.

**Narration:** “Your ride knows where you were, how you moved, and what almost
happened. Ridary keeps that private, then uses hybrid AI through Firebase AI
Logic to turn it into proof.”

## 0:12–0:28 — The trust boundary

**Visual:** “Your route is the most sensitive data you own.” Old upload-first
model versus Ridary’s local reasoning.

**Narration:** “Most safety apps upload the ride first. Ridary flips the trust
boundary: hybrid AI starts on the phone. Raw GPS, motion, and incident windows
stay on the iPhone. Only a derived summary can leave.”

## 0:28–0:50 — Private ride, timer, and lock

**Visual:** iOS Home, live map, active timer, tap-to-lock, then the evidence
sheet with the SHA-256 hash.

**Narration:** “Start a ride, then put the phone away. No camera, no audio. GPS
and motion are captured locally. The last 30 seconds can be locked on device,
and nothing is uploaded. The evidence stays on this iPhone. This is sample
ride data. The last thirty seconds are locked on this iPhone. Nothing leaves
the device.”

## 0:50–1:06 — On-device reasoning

**Visual:** Ride recap with the `On device` badge, score, risk moments, and
source pills.

**Narration:** “Back on screen, the recap is generated with Apple Foundation
Models. The badge reads On device because the sensitive reasoning stays here.
If the model is unavailable, local rules take over — not the cloud.”

## 1:06–1:20 — Ask Ridary

**Visual:** Ask Ridary composer; the UI states “On-device first · cloud sees
summaries only” and shows the source legend.

**Narration:** “Ask Ridary uses the same boundary. It answers from a compact
local context, and labels every answer: On device, In cloud, or Rules.”

## 1:20–1:44 — The cloud side

**Visual:** Web dashboard on the community risk map, with the `Risk` layer and
the sample-data banner.

**Narration:** “The cloud gets a different job. Anonymized events become a
community risk map. Riders compare their week, risk cells, and the moments that
need attention. Patterns, not raw routes. Collective insight without
surveillance.”

## 1:44–1:58 — Proof, not surveillance

**Visual:** Ridary Proof and the insurer view; verified credential fields.

**Narration:** “Then a signed safety band. An insurer verifies the score, the
period, and the Ed25519 signature. They see proof, not your route, your sensors,
or your identity.”

## 1:58–2:20 — The hybrid split

**Visual:** Split diagram: private record on the iPhone, derived signal in the
cloud, blocked raw route, App Check.

**Narration:** “This is the hybrid split. Private reasoning at the edge.
Collective insight in the cloud. Raw GPS and sensor windows never cross this
line. Only a derived summary and a signature do. Firebase App Check protects
every call, and the same data contracts are ready for Android next.”

## 2:20–2:33 — The impact

**Visual:** Riders / cities / insurers columns; no camera, no audio, no automatic
dispatch.

**Narration:** “Ridary gives riders a voice, cities a signal, and insurers a
proof. No camera. No audio. No automatic dispatch. Just a private witness.”

## 2:33–2:42 — Outro

**Visual:** Ridary mark, “Every ride. On record.”, live URL.

**Narration:** “Every ride. On record. Ridary. Private by design. Proof on
demand.”

## Do not do

- Do not show a camera feed; the product is camera-free.
- Do not claim crash detection, automatic emergency dispatch, court-grade
  evidence, or an insurance guarantee.
- Do not present sample data as live rider data.
- Do not expose demo credentials, raw routes, or rider identity.
- Do not hide a fallback; the source badge is part of the story.

## Upload checklist

- Upload the final MP4 to YouTube as **public**.
- Upload `video/out/ridary-demo-captions.srt` as English subtitles.
- Use `video/out/thumbnail.png` as the custom thumbnail.
- Add the public repository and live demo URLs to the description.
- Verify the first 30 seconds, 2:42 duration, and audio after processing.
