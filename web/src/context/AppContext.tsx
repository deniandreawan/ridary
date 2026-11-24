import {
  createUserWithEmailAndPassword,
  onAuthStateChanged,
  signInAnonymously as firebaseSignInAnonymously,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  type User
} from "firebase/auth";
import {
  collection,
  getDocs,
  limit,
  orderBy,
  query,
  where
} from "firebase/firestore";
import { httpsCallable } from "firebase/functions";
import {
  createContext,
  type ReactNode,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState
} from "react";
import {
  auth,
  db,
  functions as firebaseFunctions,
  isFirebaseConfigured
} from "../firebase";
import {
  demoCredential,
  demoRides,
  demoRiskCells
} from "../data/demo";
import type {
  Credential,
  CredentialVerification,
  InsurerShareLink,
  Ride,
  RideEvent,
  RideMode,
  RiskCell
} from "../types";

interface AppContextValue {
  user: User | null;
  demoMode: boolean;
  loading: boolean;
  authBusy: boolean;
  error: string | null;
  rides: Ride[];
  riskCells: RiskCell[];
  credentials: Credential[];
  signIn: (email: string, password: string) => Promise<boolean>;
  signUp: (email: string, password: string) => Promise<boolean>;
  signInAnonymously: () => Promise<boolean>;
  signOut: () => Promise<void>;
  enterDemo: () => void;
  refresh: () => Promise<void>;
  issueCredential: () => Promise<Credential | null>;
  verifyCredential: (credentialId: string) => Promise<CredentialVerification>;
  createInsurerView: (credentialId: string) => Promise<InsurerShareLink | null>;
}

const AppContext = createContext<AppContextValue | null>(null);

interface DocumentLike {
  id: string;
  data: () => Record<string, unknown>;
}

function timestampToMs(value: unknown): number {
  if (value && typeof value === "object" && "toMillis" in value) {
    const candidate = value as { toMillis?: () => number };
    if (typeof candidate.toMillis === "function") {
      return candidate.toMillis();
    }
  }
  if (typeof value === "number") return value;
  return 0;
}

function normalizeRoute(value: unknown): Array<[number, number]> {
  if (!Array.isArray(value)) return [];
  return value.flatMap((point) => {
    if (
      Array.isArray(point) &&
      point.length === 2 &&
      typeof point[0] === "number" &&
      typeof point[1] === "number"
    ) {
      return [[point[0], point[1]] as [number, number]];
    }
    return [];
  });
}

function toEvent(doc: DocumentLike): RideEvent {
  const data = doc.data();
  return {
    id: doc.id,
    rideId: String(data.rideId ?? ""),
    mode: (data.mode as RideMode) ?? "motorcycle",
    type: data.type as RideEvent["type"],
    severity: Number(data.severity ?? 1),
    confidence: Number(data.confidence ?? 0),
    geohash: String(data.geohash ?? ""),
    occurredAtMs: timestampToMs(data.occurredAt),
    summary: String(data.summary ?? ""),
    source: data.source as RideEvent["source"]
  };
}

function toRide(doc: DocumentLike, events: RideEvent[]): Ride {
  const data = doc.data();
  return {
    id: doc.id,
    uid: String(data.uid ?? ""),
    mode: (data.mode as RideMode) ?? "motorcycle",
    startedAtMs: timestampToMs(data.startedAt),
    endedAtMs: timestampToMs(data.endedAt),
    distanceM: Number(data.distanceM ?? 0),
    durationS: Number(data.durationS ?? 0),
    avgSpeedKph: Number(data.avgSpeedKph ?? 0),
    maxSpeedKph: Number(data.maxSpeedKph ?? 0),
    score: Number(data.score ?? 0),
    summary: String(data.summary ?? ""),
    inferenceSource: (data.inferenceSource as Ride["inferenceSource"]) ?? "deterministic",
    geohash: String(data.geohash ?? ""),
    routePreview: normalizeRoute(data.routePreview),
    events
  };
}

function toRiskCell(doc: DocumentLike): RiskCell {
  const data = doc.data();
  return {
    id: doc.id,
    mode: (data.mode as RideMode) ?? "motorcycle",
    geohash: String(data.geohash ?? ""),
    count: Number(data.count ?? 0),
    severitySum: Number(data.severitySum ?? 0),
    confidenceSum: Number(data.confidenceSum ?? 0),
    topTypes: (data.topTypes as Record<string, number>) ?? {},
    lastUpdatedMs: timestampToMs(data.lastUpdated)
  };
}

function toCredential(doc: DocumentLike): Credential {
  const data = doc.data();
  return {
    credentialId: String(data.credentialId ?? doc.id),
    uid: String(data.uid ?? ""),
    periodStart: String(data.periodStart ?? ""),
    periodEnd: String(data.periodEnd ?? ""),
    mode: (data.mode as RideMode) ?? "motorcycle",
    score: Number(data.score ?? 0),
    rideCount: Number(data.rideCount ?? 0),
    eventCount: Number(data.eventCount ?? 0),
    issuedAt: String(data.issuedAt ?? ""),
    expiresAt: String(data.expiresAt ?? ""),
    issuer: String(data.issuer ?? "Ridary"),
    publicKeyId: String(data.publicKeyId ?? ""),
    payloadHash: String(data.payloadHash ?? ""),
    signature: String(data.signature ?? "")
  };
}

function demoData(): {
  rides: Ride[];
  riskCells: RiskCell[];
  credentials: Credential[];
} {
  return {
    rides: [...demoRides],
    riskCells: [...demoRiskCells],
    credentials: [demoCredential]
  };
}

function isUrlDemoRequested(): boolean {
  if (typeof window === "undefined") return false;
  return new URLSearchParams(window.location.search).get("demo") === "1";
}

export function AppProvider({ children }: { children: ReactNode }) {
  const initialDemo = !isFirebaseConfigured || isUrlDemoRequested();
  const [user, setUser] = useState<User | null>(null);
  const [demoMode, setDemoMode] = useState(initialDemo);
  const [loading, setLoading] = useState(!initialDemo && isFirebaseConfigured);
  const [authBusy, setAuthBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [rides, setRides] = useState<Ride[]>(() =>
    initialDemo ? [...demoRides] : []
  );
  const [riskCells, setRiskCells] = useState<RiskCell[]>(() =>
    initialDemo ? [...demoRiskCells] : []
  );
  const [credentials, setCredentials] = useState<Credential[]>(() =>
    initialDemo ? [demoCredential] : []
  );

  const loadData = useCallback(async (uid: string) => {
    if (!db) return;
    setLoading(true);
    try {
      const ridesQuery = query(
        collection(db, "rides"),
        where("uid", "==", uid),
        orderBy("startedAt", "desc"),
        limit(20)
      );
      const eventsQuery = query(
        collection(db, "events"),
        where("uid", "==", uid),
        orderBy("occurredAt", "desc"),
        limit(200)
      );
      const riskQuery = query(
        collection(db, "riskCells"),
        orderBy("lastUpdated", "desc"),
        limit(500)
      );
      const credentialQuery = query(
        collection(db, "credentials"),
        where("uid", "==", uid),
        orderBy("issuedAt", "desc"),
        limit(10)
      );

      const [ridesSnapshot, eventsSnapshot, riskSnapshot, credentialSnapshot] =
        await Promise.all([
          getDocs(ridesQuery),
          getDocs(eventsQuery),
          getDocs(riskQuery),
          getDocs(credentialQuery)
        ]);

      const events = eventsSnapshot.docs.map((document) =>
        toEvent({ id: document.id, data: () => document.data() })
      );
      const eventsByRide = new Map<string, RideEvent[]>();
      for (const event of events) {
        const list = eventsByRide.get(event.rideId) ?? [];
        list.push(event);
        eventsByRide.set(event.rideId, list);
      }

      setRides(
        ridesSnapshot.docs.map((document) =>
          toRide(
            { id: document.id, data: () => document.data() },
            eventsByRide.get(document.id) ?? []
          )
        )
      );
      setRiskCells(
        riskSnapshot.docs.map((document) =>
          toRiskCell({ id: document.id, data: () => document.data() })
        )
      );
      setCredentials(
        credentialSnapshot.docs.map((document) =>
          toCredential({ id: document.id, data: () => document.data() })
        )
      );
      setError(null);
    } catch (caught) {
      setError(
        caught instanceof Error ? caught.message : "Could not load dashboard data."
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (!isFirebaseConfigured || !auth) {
      return;
    }

    const unsubscribe = onAuthStateChanged(auth, (nextUser) => {
      setUser(nextUser);
      if (nextUser) {
        setDemoMode(false);
        void loadData(nextUser.uid);
      } else if (isUrlDemoRequested()) {
        const sample = demoData();
        setDemoMode(true);
        setRides(sample.rides);
        setRiskCells(sample.riskCells);
        setCredentials(sample.credentials);
        setLoading(false);
      } else {
        setRides([]);
        setRiskCells([]);
        setCredentials([]);
        setLoading(false);
      }
    });

    return unsubscribe;
  }, [loadData]);

  const signIn = useCallback(
    async (email: string, password: string): Promise<boolean> => {
      if (!auth) {
        setError("Firebase Auth is not configured.");
        return false;
      }
      setAuthBusy(true);
      setError(null);
      try {
        await signInWithEmailAndPassword(auth, email, password);
        setDemoMode(false);
        return true;
      } catch (caught) {
        setError(caught instanceof Error ? caught.message : "Sign-in failed.");
        return false;
      } finally {
        setAuthBusy(false);
      }
    },
    []
  );

  const signUp = useCallback(
    async (email: string, password: string): Promise<boolean> => {
      if (!auth) {
        setError("Firebase Auth is not configured.");
        return false;
      }
      setAuthBusy(true);
      setError(null);
      try {
        await createUserWithEmailAndPassword(auth, email, password);
        setDemoMode(false);
        return true;
      } catch (caught) {
        setError(caught instanceof Error ? caught.message : "Sign-up failed.");
        return false;
      } finally {
        setAuthBusy(false);
      }
    },
    []
  );

  const signInAnonymously = useCallback(async (): Promise<boolean> => {
    if (!auth) {
      setError("Firebase Auth is not configured.");
      return false;
    }
    setAuthBusy(true);
    setError(null);
    try {
      await firebaseSignInAnonymously(auth);
      setDemoMode(false);
      return true;
    } catch (caught) {
      setError(
        caught instanceof Error ? caught.message : "Anonymous sign-in failed."
      );
      return false;
    } finally {
      setAuthBusy(false);
    }
  }, []);

  const signOut = useCallback(async () => {
    if (auth) {
      await firebaseSignOut(auth);
    }
    setUser(null);
    setDemoMode(!isFirebaseConfigured);
    setCredentials([]);
    setError(null);
    if (!isFirebaseConfigured) {
      const data = demoData();
      setRides(data.rides);
      setRiskCells(data.riskCells);
      setCredentials(data.credentials);
    } else {
      setRides([]);
      setRiskCells([]);
    }
  }, []);

  const enterDemo = useCallback(() => {
    const data = demoData();
    setDemoMode(true);
    setUser(null);
    setRides(data.rides);
    setRiskCells(data.riskCells);
    setCredentials(data.credentials);
    setError(null);
  }, []);

  const refresh = useCallback(async () => {
    if (user) {
      await loadData(user.uid);
    } else if (demoMode) {
      const data = demoData();
      setRides(data.rides);
      setRiskCells(data.riskCells);
      setCredentials(data.credentials);
    }
  }, [demoMode, loadData, user]);

  const issueCredential = useCallback(async (): Promise<Credential | null> => {
    if (demoMode) {
      setError("Connect a Firebase project to issue a signed credential.");
      return null;
    }
    if (!firebaseFunctions) {
      setError("Cloud Functions are not configured.");
      return null;
    }
    setAuthBusy(true);
    setError(null);
    try {
      const mode = rides[0]?.mode ?? "motorcycle";
      const callable = httpsCallable<
        { mode: RideMode; days: number },
        Credential
      >(firebaseFunctions, "issueCredential");
      const result = await callable({ mode, days: 30 });
      setCredentials((previous) => [result.data, ...previous]);
      return result.data;
    } catch (caught) {
      setError(
        caught instanceof Error ? caught.message : "Could not issue credential."
      );
      return null;
    } finally {
      setAuthBusy(false);
    }
  }, [demoMode, rides]);

  const verifyCredential = useCallback(
    async (credentialId: string): Promise<CredentialVerification> => {
      if (demoMode) {
        return {
          valid: false,
          credential: null,
          reason:
            "Demo credential. Connect Firebase to verify a real Ed25519 signature."
        };
      }
      if (!firebaseFunctions) {
        return {
          valid: false,
          credential: null,
          reason: "Cloud Functions are not configured."
        };
      }
      try {
        const callable = httpsCallable<
          { credentialId: string },
          CredentialVerification
        >(firebaseFunctions, "verifyCredential");
        const result = await callable({ credentialId });
        return result.data;
      } catch (caught) {
        return {
          valid: false,
          credential: null,
          reason:
            caught instanceof Error ? caught.message : "Verification failed."
        };
      }
    },
    [demoMode]
  );

  const createInsurerView = useCallback(
    async (credentialId: string): Promise<InsurerShareLink | null> => {
      if (demoMode) {
        return {
          token: "demo",
          url: `${window.location.origin}/insurer/demo`
        };
      }
      if (!firebaseFunctions) {
        setError("Cloud Functions are not configured.");
        return null;
      }
      try {
        const callable = httpsCallable<
          { credentialId: string },
          InsurerShareLink
        >(firebaseFunctions, "createInsurerView");
        const result = await callable({ credentialId });
        return result.data;
      } catch (caught) {
        setError(
          caught instanceof Error ? caught.message : "Could not create share link."
        );
        return null;
      }
    },
    [demoMode]
  );

  const value = useMemo<AppContextValue>(
    () => ({
      user,
      demoMode,
      loading,
      authBusy,
      error,
      rides,
      riskCells,
      credentials,
      signIn,
      signUp,
      signInAnonymously,
      signOut,
      enterDemo,
      refresh,
      issueCredential,
      verifyCredential,
      createInsurerView
    }),
    [
      authBusy,
      createInsurerView,
      credentials,
      demoMode,
      enterDemo,
      error,
      issueCredential,
      loading,
      refresh,
      rides,
      riskCells,
      signIn,
      signInAnonymously,
      signOut,
      signUp,
      user,
      verifyCredential
    ]
  );

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp(): AppContextValue {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error("useApp must be used inside AppProvider");
  }
  return context;
}
