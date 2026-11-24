import {
  ArrowRight,
  Cloud,
  Cpu,
  ShieldCheck,
  Smartphone
} from "lucide-react";
import { type FormEvent, useState } from "react";
import { ErrorBanner } from "../components/Banners";
import { Logo } from "../components/Logo";
import { RouteArt } from "../components/RouteArt";
import { useApp } from "../context/AppContext";
import { isFirebaseConfigured } from "../firebase";

export default function LoginPage() {
  const { signIn, signUp, signInAnonymously, enterDemo, authBusy, error } =
    useApp();
  const [mode, setMode] = useState<"signin" | "signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (mode === "signin") {
      await signIn(email, password);
    } else {
      await signUp(email, password);
    }
  }

  return (
    <div className="min-h-[100dvh] bg-canvas px-4 py-8 sm:px-6">
      <div className="mx-auto grid min-h-[calc(100dvh-4rem)] max-w-5xl items-center gap-10 lg:grid-cols-[1.08fr_0.92fr]">
        <section className="max-w-xl">
          <Logo />

          <div className="mt-10 inline-flex items-center gap-1.5 rounded-full bg-sky-soft px-3 py-1 text-[12px] font-medium text-sky-deep">
            <span className="h-1.5 w-1.5 rounded-full bg-sky" />
            Hybrid AI · Private by default
          </div>

          <h1 className="mt-4 text-4xl font-semibold leading-[1.08] tracking-[-0.035em] text-paper sm:text-5xl">
            Every ride, on record.
          </h1>
          <p className="mt-3 max-w-md text-[15px] leading-relaxed text-muted">
            Ridary turns a phone in your pocket into a private ride witness.
            On-device AI explains what happened; the cloud sees only what you
            choose to share.
          </p>

          <div className="surface mt-7 overflow-hidden">
            <RouteArt
              route={[
                [-6.2088, 106.8456],
                [-6.2146, 106.8502],
                [-6.2201, 106.8529],
                [-6.225, 106.847],
                [-6.219, 106.84]
              ]}
              className="h-44 w-full"
            />
            <div className="flex items-center justify-between gap-3 border-t border-line/70 bg-white px-5 py-3.5">
              <div>
                <div className="text-[14px] font-medium text-paper">
                  A steady ride with one hard brake
                </div>
                <div className="text-[12px] text-muted">
                  Motorcycle · 8.2 km · 25m
                </div>
              </div>
              <span className="inline-flex items-center gap-1.5 rounded-full bg-sky-soft px-2.5 py-1 text-[11px] font-medium text-sky-deep">
                <span className="h-1.5 w-1.5 rounded-full bg-sky" />
                96 · A Band
              </span>
            </div>
          </div>

          <div className="mt-7 divide-y divide-line/70">
            <Feature
              icon={<Smartphone size={16} />}
              title="Private at the edge"
              text="Raw routes, sensor windows, and incident notes stay on your iPhone."
            />
            <Feature
              icon={<Cpu size={16} />}
              title="On-device first"
              text="Apple Foundation Models and Chrome Nano summarize rides locally."
            />
            <Feature
              icon={<Cloud size={16} />}
              title="Proof, not surveillance"
              text="Share a signed safety band with an insurer without exposing raw GPS."
            />
          </div>
        </section>

        <section className="surface overflow-hidden">
          <div className="ios-hero-pastel flex flex-col items-center px-6 pb-9 pt-8 text-center">
            <div className="mono-label">Rider access</div>
            <div className="ios-hero-badge mt-3">
              <ShieldCheck size={24} strokeWidth={1.9} />
            </div>
            <h2 className="mt-3 text-[24px] font-semibold tracking-[-0.025em] text-paper">
              {mode === "signin" ? "Welcome back" : "Create your account"}
            </h2>
            <p className="mt-1 text-[13px] text-muted">
              Sign in with your iPhone account or explore sample data
            </p>
          </div>

          <div className="-mt-5 rounded-t-[1.625rem] bg-white px-6 pb-7 pt-6 sm:px-8">
            <div className="grid grid-cols-2 gap-1 rounded-full bg-canvas-soft p-1">
              <button
                type="button"
                onClick={() => setMode("signin")}
                className={`focus-ring rounded-full px-3 py-2 text-[13px] font-medium transition ${
                  mode === "signin"
                    ? "bg-white text-paper shadow-sm"
                    : "text-muted hover:text-paper"
                }`}
              >
                Sign in
              </button>
              <button
                type="button"
                onClick={() => setMode("signup")}
                className={`focus-ring rounded-full px-3 py-2 text-[13px] font-medium transition ${
                  mode === "signup"
                    ? "bg-white text-paper shadow-sm"
                    : "text-muted hover:text-paper"
                }`}
              >
                Create account
              </button>
            </div>

            <form
              onSubmit={(event) => void handleSubmit(event)}
              className="mt-5 space-y-4"
            >
              <label className="block">
                <span className="text-[13px] font-medium text-paper">Email</span>
                <input
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  placeholder="you@example.com"
                  className="focus-ring mt-1.5 w-full rounded-2xl border border-line bg-canvas-soft px-3.5 py-3 text-[14px] text-paper outline-none transition focus:border-sky focus:bg-white placeholder:text-subtle"
                />
              </label>
              <label className="block">
                <span className="text-[13px] font-medium text-paper">
                  Password
                </span>
                <input
                  type="password"
                  autoComplete={
                    mode === "signin" ? "current-password" : "new-password"
                  }
                  required
                  minLength={6}
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  placeholder="At least 6 characters"
                  className="focus-ring mt-1.5 w-full rounded-2xl border border-line bg-canvas-soft px-3.5 py-3 text-[14px] text-paper outline-none transition focus:border-sky focus:bg-white placeholder:text-subtle"
                />
              </label>

              {error && <ErrorBanner message={error} />}

              <button
                type="submit"
                disabled={authBusy}
                className="btn-glass-sky focus-ring w-full px-5 py-3 text-[14px] disabled:cursor-not-allowed disabled:opacity-60"
              >
                {authBusy ? (
                  "Working…"
                ) : (
                  <>
                    {mode === "signin" ? "Sign in" : "Create account"}
                    <ArrowRight size={15} />
                  </>
                )}
              </button>
            </form>

            <div className="my-5 flex items-center gap-3">
              <div className="h-px flex-1 bg-line/80" />
              <span className="text-[12px] text-subtle">or</span>
              <div className="h-px flex-1 bg-line/80" />
            </div>

            <div className="space-y-2.5">
              <button
                type="button"
                onClick={enterDemo}
                className="btn-glass focus-ring w-full border-sky/25 bg-sky-soft/55 px-4 py-3 text-[13px] font-medium text-sky-deep hover:bg-sky-soft"
              >
                Explore the demo dashboard
              </button>
              <button
                type="button"
                disabled={authBusy}
                onClick={() => void signInAnonymously()}
                className="btn-glass focus-ring w-full px-4 py-3 text-[13px] text-paper disabled:opacity-60"
              >
                Continue as guest
              </button>
            </div>

            {!isFirebaseConfigured && (
              <p className="mt-4 text-center text-[12px] leading-relaxed text-muted">
                Running in local demo mode. Add your web config to{" "}
                <code className="font-mono text-paper">.env.local</code> for live
                Firebase sync.
              </p>
            )}
          </div>
        </section>
      </div>
    </div>
  );
}

function Feature({
  icon,
  title,
  text
}: {
  icon: React.ReactNode;
  title: string;
  text: string;
}) {
  return (
    <div className="flex items-start gap-3.5 py-3.5">
      <div className="ios-icon-circle mt-0.5">{icon}</div>
      <div>
        <div className="text-[15px] font-medium text-paper">{title}</div>
        <div className="mt-0.5 text-[13px] leading-relaxed text-muted">
          {text}
        </div>
      </div>
    </div>
  );
}
