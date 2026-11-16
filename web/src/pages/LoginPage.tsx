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
    <div className="min-h-screen px-4 py-8 sm:px-6">
      <div className="mx-auto grid min-h-[calc(100vh-4rem)] max-w-6xl items-center gap-10 lg:grid-cols-[1.1fr_0.9fr]">
        <section className="max-w-xl">
          <Logo />
          <div className="mono-label mt-12">Hybrid AI · Private by default</div>
          <h1 className="mt-4 text-4xl font-semibold leading-[1.05] tracking-[-0.04em] sm:text-6xl">
            Every ride,
            <br />
            on record.
          </h1>
          <p className="mt-5 max-w-md text-sm leading-relaxed text-muted">
            Ridary turns a phone in your pocket into a private ride witness.
            On-device AI explains what happened. The cloud only sees what you
            choose to share.
          </p>

          <div className="mt-10 space-y-4">
            <Feature
              icon={<Smartphone size={16} />}
              title="Private at the edge"
              text="Route, motion, evidence, and incident notes stay on your phone."
            />
            <Feature
              icon={<Cpu size={16} />}
              title="Hybrid inference"
              text="Apple Foundation Models or Chrome Nano first; Gemini fallback when needed."
            />
            <Feature
              icon={<Cloud size={16} />}
              title="Collective in the cloud"
              text="Anonymized event points build a road-risk map without exposing your route."
            />
          </div>
        </section>

        <section className="surface p-6 sm:p-8">
          <div className="flex items-center justify-between gap-4">
            <div>
              <div className="mono-label">Rider access</div>
              <h2 className="mt-2 text-2xl font-semibold tracking-tight">
                {mode === "signin" ? "Welcome back" : "Create your account"}
              </h2>
            </div>
            <ShieldCheck className="text-teal" size={22} />
          </div>

          <div className="mt-6 grid grid-cols-2 gap-1 rounded-xl border border-line bg-ink-soft p-1">
            <button
              type="button"
              onClick={() => setMode("signin")}
              className={`focus-ring rounded-lg px-3 py-2 text-xs font-semibold transition ${
                mode === "signin"
                  ? "bg-card text-paper"
                  : "text-muted hover:text-paper"
              }`}
            >
              Sign in
            </button>
            <button
              type="button"
              onClick={() => setMode("signup")}
              className={`focus-ring rounded-lg px-3 py-2 text-xs font-semibold transition ${
                mode === "signup"
                  ? "bg-card text-paper"
                  : "text-muted hover:text-paper"
              }`}
            >
              Create account
            </button>
          </div>

          <form onSubmit={(event) => void handleSubmit(event)} className="mt-5 space-y-4">
            <label className="block">
              <span className="mono-label">Email</span>
              <input
                type="email"
                autoComplete="email"
                required
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                placeholder="you@example.com"
                className="focus-ring mt-2 w-full rounded-xl border border-line bg-ink-soft px-3.5 py-3 text-sm text-paper outline-none placeholder:text-muted/60"
              />
            </label>
            <label className="block">
              <span className="mono-label">Password</span>
              <input
                type="password"
                autoComplete={mode === "signin" ? "current-password" : "new-password"}
                required
                minLength={6}
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                placeholder="At least 6 characters"
                className="focus-ring mt-2 w-full rounded-xl border border-line bg-ink-soft px-3.5 py-3 text-sm text-paper outline-none placeholder:text-muted/60"
              />
            </label>

            {error && <ErrorBanner message={error} />}

            <button
              type="submit"
              disabled={authBusy}
              className="focus-ring flex w-full items-center justify-center gap-2 rounded-xl bg-accent px-4 py-3 text-sm font-semibold text-ink transition hover:bg-accent/90 disabled:cursor-not-allowed disabled:opacity-60"
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
            <div className="h-px flex-1 bg-line" />
            <span className="mono-label">or</span>
            <div className="h-px flex-1 bg-line" />
          </div>

          <div className="space-y-2">
            <button
              type="button"
              disabled={authBusy}
              onClick={() => void signInAnonymously()}
              className="focus-ring w-full rounded-xl border border-line bg-card-soft px-4 py-3 text-xs font-semibold text-paper transition hover:border-white/20 disabled:opacity-60"
            >
              Continue as guest
            </button>
            <button
              type="button"
              onClick={enterDemo}
              className="focus-ring w-full rounded-xl border border-accent/25 bg-accent/8 px-4 py-3 text-xs font-semibold text-accent transition hover:bg-accent/12"
            >
              Explore the demo dashboard
            </button>
          </div>

          {!isFirebaseConfigured && (
            <p className="mt-5 text-[11px] leading-relaxed text-muted">
              Firebase is not configured. The dashboard will run in demo mode
              with sample data. Add your web app values to{" "}
              <code className="font-mono text-paper">.env.local</code> to sign
              in and use hybrid AI.
            </p>
          )}
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
    <div className="flex gap-3">
      <div className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border border-line bg-card text-accent">
        {icon}
      </div>
      <div>
        <div className="text-sm font-semibold text-paper">{title}</div>
        <div className="mt-1 max-w-sm text-xs leading-relaxed text-muted">
          {text}
        </div>
      </div>
    </div>
  );
}
