import { doc, getDoc } from "firebase/firestore";
import {
  AlertTriangle,
  CheckCircle2,
  Lock,
  ShieldCheck,
  XCircle
} from "lucide-react";
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { ErrorBanner, LoadingScreen, SectionHeader } from "../components/Banners";
import { ScoreRing } from "../components/ScoreRing";
import { useApp } from "../context/AppContext";
import { demoCredential } from "../data/demo";
import { db } from "../firebase";
import {
  formatISODate,
  formatPeriod,
  scoreBand
} from "../lib/format";
import type { CredentialVerification, InsurerView } from "../types";

function toInsurerView(data: Record<string, unknown>): InsurerView {
  return {
    credentialId: String(data.credentialId ?? ""),
    periodStart: String(data.periodStart ?? ""),
    periodEnd: String(data.periodEnd ?? ""),
    mode: (data.mode as InsurerView["mode"]) ?? "motorcycle",
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

export default function InsurerPage() {
  const { token } = useParams<{ token: string }>();
  const { verifyCredential } = useApp();
  const [view, setView] = useState<InsurerView | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [verification, setVerification] =
    useState<CredentialVerification | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      if (!token) {
        setError("This insurer link is missing a token.");
        setLoading(false);
        return;
      }

      if (token === "demo") {
        const {
          credentialId,
          periodStart,
          periodEnd,
          mode,
          score,
          rideCount,
          eventCount,
          issuedAt,
          expiresAt,
          issuer,
          publicKeyId,
          payloadHash,
          signature
        } = demoCredential;
        if (!cancelled) {
          setView({
            credentialId,
            periodStart,
            periodEnd,
            mode,
            score,
            rideCount,
            eventCount,
            issuedAt,
            expiresAt,
            issuer,
            publicKeyId,
            payloadHash,
            signature
          });
          setLoading(false);
        }
        return;
      }

      if (!db) {
        if (!cancelled) {
          setError("Firebase is not configured, so this link cannot be loaded.");
          setLoading(false);
        }
        return;
      }

      try {
        const snapshot = await getDoc(doc(db, "insurerViews", token));
        if (!snapshot.exists()) {
          if (!cancelled) {
            setError("This insurer link is invalid or has expired.");
            setLoading(false);
          }
          return;
        }
        if (!cancelled) {
          setView(toInsurerView(snapshot.data()));
          setLoading(false);
        }
      } catch (caught) {
        if (!cancelled) {
          setError(
            caught instanceof Error
              ? caught.message
              : "Could not load this insurer view."
          );
          setLoading(false);
        }
      }
    }

    void load();
    return () => {
      cancelled = true;
    };
  }, [token]);

  async function verify() {
    if (!view) return;
    setBusy(true);
    setVerification(await verifyCredential(view.credentialId));
    setBusy(false);
  }

  if (loading) {
    return <LoadingScreen />;
  }

  if (error || !view) {
    return (
      <div className="space-y-4">
        <ErrorBanner message={error ?? "This insurer view is unavailable."} />
        <div className="surface p-6 text-xs leading-relaxed text-muted">
          Ask the rider to create a fresh insurer link from the Ridary
          credential page.
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <header>
        <div className="mono-label">Ridary Proof / Insurer view</div>
        <h1 className="mt-2 text-3xl font-semibold tracking-[-0.03em]">
          A safety credential, not a route.
        </h1>
        <p className="mt-2 max-w-2xl text-sm leading-relaxed text-muted">
          This page was shared by a Ridary rider. It contains a signed score
          and aggregate ride history. It deliberately excludes the rider&apos;s
          identity and location history.
        </p>
      </header>

      <section className="surface p-6">
        <div className="flex flex-col gap-6 sm:flex-row sm:items-center">
          <ScoreRing score={view.score} size={132} />
          <div className="min-w-0 flex-1">
            <div className="mono-label">Ridary Proof</div>
            <div className="mt-1 text-3xl font-semibold tracking-tight">
              {scoreBand(view.score)} band
            </div>
            <div className="mt-2 inline-flex items-center gap-2 rounded-full border border-teal/30 bg-teal/8 px-2.5 py-1 font-mono text-[9px] uppercase tracking-[0.12em] text-teal">
              <ShieldCheck size={11} />
              Signed by {view.issuer}
            </div>
            <p className="mt-3 text-xs leading-relaxed text-muted">
              {formatPeriod(view.periodStart, view.periodEnd)} · {view.mode}
            </p>
          </div>
        </div>

        <div className="mt-6 grid grid-cols-2 gap-2 sm:grid-cols-4">
          <Meta label="Rides" value={String(view.rideCount)} />
          <Meta label="Moments" value={String(view.eventCount)} />
          <Meta label="Issued" value={formatISODate(view.issuedAt)} />
          <Meta label="Expires" value={formatISODate(view.expiresAt)} />
        </div>

        <div className="mt-5 space-y-2 border-t border-line pt-4 font-mono text-[10px] text-muted">
          <div className="flex items-center gap-2">
            <Lock size={11} className="text-accent" />
            key {view.publicKeyId}
          </div>
          <div className="break-all">hash {view.payloadHash}</div>
          <div className="break-all">signature {view.signature}</div>
        </div>

        <div className="mt-5 flex flex-wrap items-center gap-3">
          <button
            type="button"
            onClick={() => void verify()}
            disabled={busy}
            className="focus-ring inline-flex items-center gap-2 rounded-xl bg-accent px-4 py-2.5 text-xs font-semibold text-on-accent transition hover:bg-accent/90 disabled:opacity-60"
          >
            <ShieldCheck size={14} />
            {busy ? "Verifying…" : "Verify signature"}
          </button>
          <span className="text-[10px] leading-relaxed text-muted">
            Verification recomputes the payload hash and checks the Ed25519
            signature.
          </span>
        </div>

        {verification && (
          <div
            className={`mt-4 flex items-start gap-3 rounded-xl border p-4 ${
              verification.valid
                ? "border-teal/25 bg-teal/6"
                : "border-danger/25 bg-danger/6"
            }`}
          >
            {verification.valid ? (
              <CheckCircle2 size={18} className="mt-0.5 text-teal" />
            ) : (
              <XCircle size={18} className="mt-0.5 text-danger" />
            )}
            <div>
              <div className="text-xs font-semibold text-paper">
                {verification.valid
                  ? "Signature and hash match"
                  : "Verification did not pass"}
              </div>
              <div className="mt-1 text-[11px] leading-relaxed text-muted">
                {verification.reason ??
                  "The credential was signed by the Ridary issuer key."}
              </div>
            </div>
          </div>
        )}
      </section>

      <div className="grid gap-4 md:grid-cols-2">
        <section className="surface p-5">
          <SectionHeader eyebrow="Not included" title="What this view cannot see" />
          <ul className="mt-4 space-y-2 text-[11px] leading-relaxed text-muted">
            <li>· The rider&apos;s raw GPS route or sensor windows</li>
            <li>· The rider&apos;s name, email, or contact details</li>
            <li>· Incident evidence files or statements</li>
            <li>· Any live location or device identifier</li>
          </ul>
        </section>

        <section className="surface p-5">
          <SectionHeader eyebrow="Signature" title="What the proof means" />
          <div className="mt-4 flex items-start gap-3">
            <AlertTriangle size={16} className="mt-0.5 text-accent" />
            <p className="text-[11px] leading-relaxed text-muted">
              The signature proves that the credential fields were issued by
              Ridary and have not been altered. It is a personal safety
              credential, not a legal determination of fault, coverage, or
              insurability.
            </p>
          </div>
        </section>
      </div>

      <p className="text-center text-[10px] leading-relaxed text-muted">
        Ridary Proof is a personal safety credential. It is not legal advice, a
        court record, or an insurance guarantee.
      </p>
    </div>
  );
}

function Meta({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-line bg-ink-soft px-3 py-2">
      <div className="font-mono text-[9px] uppercase tracking-[0.14em] text-muted">
        {label}
      </div>
      <div className="mt-1 text-xs font-semibold text-paper">{value}</div>
    </div>
  );
}
