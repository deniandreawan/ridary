# Setup

## Prerequisites

- macOS Tahoe 26.3 or later on Apple silicon
- Xcode 26.6 (iOS 26.5 simulator SDK)
- `xcodegen` (`brew install xcodegen`)
- Node.js 24 for local builds; Functions deploy on Node 22
- Firebase CLI (`npm install -g firebase-tools`)
- Java 17+ if you want to run the Firestore emulator
- An iPhone with iOS 26+ and Apple Intelligence for on-device iOS inference
- Desktop Chrome 139+ for Chrome Nano
- A Firebase project with AI Logic enabled

The iOS app and web dashboard run in demo mode without any Firebase
configuration. That is the fastest way to inspect the UI.

## Firebase

1. Create a project in the Firebase console.
2. Enable **AI Logic** and select the **Gemini Developer API** provider.
3. Enable **App Check** and enforce it for AI Logic.
4. Enable **Authentication** providers:
   - Email/Password
   - Anonymous
5. Create a **Firestore** database.
6. Enable **Cloud Functions** and **Hosting**.
7. Register an iOS app with bundle id `app.ridary.ios`.
8. Register a web app.

Deploy the security rules and indexes before testing live data:

```bash
firebase use --add
firebase deploy --only firestore:rules,firestore:indexes
```

## iOS

```bash
cd ios
xcodegen generate
open Ridary.xcodeproj
```

1. Download `GoogleService-Info.plist` from the Firebase iOS app settings.
2. Replace `ios/Config/GoogleService-Info.plist` with it.
3. Select your development team in Xcode.
4. Run on an iPhone or the simulator.

If `GoogleService-Info.plist` still contains `REPLACE_ME`, the app deliberately
runs in local demo mode and shows that state on the Home and Settings screens.

### App Check debug provider

The hackathon build uses the App Check debug provider:

1. Launch the app and open the Xcode console.
2. Copy the line that contains `App Check debug token`.
3. Register that token in **Firebase console → App Check → Apps → Manage debug
   tokens**.
4. Confirm App Check is enforced for AI Logic.

The debug token is not committed. Do not ship a debug build or token in
production.

### Apple Intelligence

- Use an iPhone 15 Pro or later with iOS 26+.
- Enable **Apple Intelligence & Siri** in Settings.
- On-device inference runs only while the app is in the foreground.
- The simulator does not provide Apple Foundation Models; expect a cloud or
  deterministic fallback there.

The Settings screen shows the current on-device availability and the exact
reason when it is unavailable.

### Background capture

The app declares the `location` background mode. It shows the system location
indicator while a ride is active. This is a user-visible ride-tracking feature,
not a hidden background sensor session. The App Store review rationale is the
same: the rider is recording a route and expects a visible record.

## Web

```bash
cd web
cp .env.example .env.local
npm install
npm run dev
```

Fill the Firebase web app values in `.env.local`:

```
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_STORAGE_BUCKET=
VITE_FIREBASE_MESSAGING_SENDER_ID=
VITE_FIREBASE_APP_ID=
VITE_FUNCTIONS_REGION=us-central1
VITE_APP_CHECK_SITE_KEY=
VITE_APP_CHECK_DEBUG_TOKEN=
```

- **App Check site key**: create a reCAPTCHA Enterprise provider for the web app
  in Firebase App Check and paste the site key.
- **Debug token**: for local development you can set
  `VITE_APP_CHECK_DEBUG_TOKEN` to the debug token registered in the console. The
  SDK uses it instead of a live attestation.
- If the site key is missing, the dashboard still loads in demo mode, but
  App-Check-enforced callable functions and AI Logic calls will fail.

### Chrome Nano

1. Use desktop Chrome 139+.
2. Open `chrome://flags/#prompt-api-for-gemini-nano-multimodal-input` and enable
   the flag.
3. Restart Chrome.
4. Open DevTools → Console and run:

```js
await LanguageModel.availability();
```

If it says `downloadable`, run `await LanguageModel.create()` and let the model
download. The first on-device request can also trigger the download, but that
makes the first request slow.

Without Chrome Nano, Firebase AI Logic automatically falls back to cloud
Gemini. The review card shows the actual source.

## Functions

```bash
cd functions
npm install
npm run generate:keys
```

Paste the generated PEM values into `functions/.env`:

```
CREDENTIAL_PRIVATE_KEY_PEM="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
CREDENTIAL_PUBLIC_KEY_PEM="-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----\n"
CREDENTIAL_ISSUER="Ridary"
PUBLIC_KEY_ID="ridary-dev-1"
WEB_BASE_URL="http://localhost:5173"
```

Do not commit `functions/.env` or the keys. For the hackathon, the `.env` file
is enough to deploy the prototype. For production, move the PEM values to a
secret manager and wire them into the function environment.

Build and deploy:

```bash
npm run build
cd ..
firebase deploy --only functions
```

If you want to test the Firestore rules and Functions locally, install Java and
run:

```bash
firebase emulators:start
```

AI Logic is a client SDK and is not emulated. Use a real Firebase project for
AI behavior.

## Hosting

```bash
npm --prefix web run build
firebase deploy --only hosting
```

`firebase.json` rewrites every path to `index.html`, so the public
`/insurer/:token` route works after a direct load.

## Troubleshooting

| Symptom | Fix |
|---|---|
| iOS says “Local demo mode” | Replace `ios/Config/GoogleService-Info.plist` and rebuild |
| Web says “Demo mode” | Fill `web/.env.local` and restart Vite |
| AI Logic returns 403 | Register the App Check debug token / set the web site key; enforce AI Logic |
| On-device review says fallback | Check Apple Intelligence / Chrome Nano; the UI is reporting the truth |
| Firestore “index required” | Deploy `firestore.indexes.json` or click the console link |
| Functions fail to sign | `functions/.env` keys are missing or malformed |
| Map is blank | MapLibre needs WebGL and network access for CARTO tiles; the risk list still works |
| Emulator will not start | Install a JDK (Firestore emulator needs Java) |
