import { initializeAppCheck, ReCaptchaEnterpriseProvider } from "firebase/app-check";
import { getAI, GoogleAIBackend, type AI } from "firebase/ai";
import { getApps, initializeApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { getFirestore, type Firestore } from "firebase/firestore";
import { getFunctions, type Functions } from "firebase/functions";

const env = import.meta.env as ImportMetaEnv & Record<string, string | undefined>;

const firebaseConfig = {
  apiKey: env.VITE_FIREBASE_API_KEY ?? "",
  authDomain: env.VITE_FIREBASE_AUTH_DOMAIN ?? "",
  projectId: env.VITE_FIREBASE_PROJECT_ID ?? "",
  storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET ?? "",
  messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID ?? "",
  appId: env.VITE_FIREBASE_APP_ID ?? ""
};

export const isFirebaseConfigured =
  Boolean(firebaseConfig.apiKey) &&
  Boolean(firebaseConfig.projectId) &&
  Boolean(firebaseConfig.appId) &&
  firebaseConfig.apiKey !== "REPLACE_ME" &&
  firebaseConfig.appId !== "REPLACE_ME";

export const functionsRegion = env.VITE_FUNCTIONS_REGION ?? "us-central1";

let firebaseApp: FirebaseApp | null = null;
let firebaseAuth: Auth | null = null;
let firebaseDb: Firestore | null = null;
let firebaseFunctions: Functions | null = null;
let firebaseAi: AI | null = null;
let appCheckReady = false;

if (isFirebaseConfigured) {
  firebaseApp = getApps()[0] ?? initializeApp(firebaseConfig);
  firebaseAuth = getAuth(firebaseApp);
  firebaseDb = getFirestore(firebaseApp);
  firebaseFunctions = getFunctions(firebaseApp, functionsRegion);
  firebaseAi = getAI(firebaseApp, { backend: new GoogleAIBackend() });

  const siteKey = env.VITE_APP_CHECK_SITE_KEY;
  const debugToken = env.VITE_APP_CHECK_DEBUG_TOKEN;

  if (debugToken) {
    (
      globalThis as typeof globalThis & {
        FIREBASE_APPCHECK_DEBUG_TOKEN?: string | boolean;
      }
    ).FIREBASE_APPCHECK_DEBUG_TOKEN = debugToken;
  }

  if (siteKey) {
    initializeAppCheck(firebaseApp, {
      provider: new ReCaptchaEnterpriseProvider(siteKey),
      isTokenAutoRefreshEnabled: true
    });
    appCheckReady = true;
  }
}

export {
  firebaseAi as ai,
  firebaseApp as app,
  firebaseAuth as auth,
  firebaseDb as db,
  firebaseFunctions as functions,
  appCheckReady
};
