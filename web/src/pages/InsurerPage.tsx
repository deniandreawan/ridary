import { doc, getDoc } from "firebase/firestore";
import {
  CalendarClock,
  CheckCircle2,
  KeyRound,
  Lock,
  ShieldCheck,
  XCircle
} from "lucide-react";
import type { ReactNode } from "react";
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { ErrorBanner, LoadingScreen } from "../components/Banners";
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
        <div className="surface p-6 text-[13px] leading-relaxed text-muted">
          Ask the rider to create a fresh insurer link from the Ridary Proof
          screen.
        </div>
      </div>
    );
  }

  const band = scoreBand(view.score);

  return (
    <div className="mx-auto max-w-2xl">
      <article className="surface overflow-hidden">
        <div className="ios-hero-pastel flex flex-col items-center px-6 pb-11 pt-9 text-center">
          <div className="mono-label">
            Valid until {formatISODate(view.expiresAt)}
          </div>
          <div className="ios-hero-badge mt-3.5">
            <ShieldCheck size={26} strokeWidth={1.9} />
          </div>
          <div className="mt-3.5 text-[34px] font-semibold tracking-[-0.03em] text-paper">
            {band} Band
          </div>
          <div className="mt-1 text-[13px] capitalize text-muted">
            {formatPeriod(view.periodStart, view.periodEnd)} · {view.mode}
          </div>
        </div>

        <div className="relative -mt-6 rounded-t-[1.625rem] bg-white pt-7 shadow-[0_-6px_20px_rgba(23,23,23,0.04)]">
          <div className="mx-auto max-w-lg px-6 pb-6 text-center">
            <h1 className="text-[23px] font-semibold tracking-[-0.025em] text-paper">
              A safety credential, not a route
            </h1>
            <p className="mt-2.5 text-[15px] leading-relaxed text-muted">
              Shared by a Ridary rider. Contains a signed safety band and
              aggregate ride count while excluding identity and location
              history.
            </p>
            <div className="mt-3.5 inline-flex items-center gap-1.5 text-[13px]">
              <CheckCircle2 size={14} className="text-sky" />
              <span className="font-medium text-paper">
                Signed by {view.issuer}
              </span>
              <span className="text-muted">· Ed25519 signature</span>
            </div>
          </div>

          <div className="mx-6 h-px bg-line/75" />

          <div className="grid grid-cols-3 divide-x divide-line/75 items-center px-6 py-5 text-center">
            <CenteredInsurerMetric
              value={`${band} Band`}
              label="Safety tier"
              accent
            />
            <CenteredInsurerMetric
              value={String(view.score)}
              label="Out of 100"
            />
            <CenteredInsurerMetric
              value={`${view.rideCount} rides`}
              label={`${view.eventCount} moments`}
            />
          </div>

          <div className="mx-6 h-px bg-line/75" />

          <div className="space-y-4 px-6 py-6">
            <h2 className="text-[17px] font-semibold tracking-[-0.015em] text-paper">
              Credential details
            </h2>

            <InsurerRow
              icon={<ShieldCheck size={15} />}
              title={`Issued by ${view.issuer} on ${formatISODate(view.issuedAt)}`}
              subtitle="Recomputes the canonical payload hash and verifies the Ed25519 signature."
            />
            <InsurerRow
              icon={<Lock size={15} />}
              title="Excluded by design"
              subtitle="No raw GPS routes, sensor windows, rider name, email, or incident statements."
            />
            <InsurerRow
              icon={<CalendarClock size={15} />}
              title={`Expires ${formatISODate(view.expiresAt)}`}
              subtitle={`Covers ${view.mode} rides from ${formatPeriod(
                view.periodStart,
                view.periodEnd
              )}.`}
            />
            <InsurerRow
              icon={<KeyRound size={15} />}
              title={`Key ${view.publicKeyId}`}
              subtitle={view.payloadHash}
              mono
            />
          </div>

          {verification && (
            <>
              <div className="mx-6 h-px bg-line/75" />
              <div className="flex items-start gap-3.5 px-6 py-5">
                <div
                  className={`flex h-8.5 w-8.5 shrink-0 items-center justify-center rounded-full ${
                    verification.valid
                      ? "bg-sky-soft text-sky"
                      : "bg-danger/12 text-danger"
                  }`}
                >
                  {verification.valid ? (
                    <CheckCircle2 size={16} />
                  ) : (
                    <XCircle size={16} />
                  )}
                </div>
                <div>
                  <div className="text-[15px] font-medium text-paper">
                    {verification.valid
                      ? "Signature and hash match"
                      : "Verification did not pass"}
                  </div>
                  <div className="mt-0.5 text-[13px] text-muted">
                    {verification.reason ??
                      "The credential was signed by the Ridary issuer key."}
                  </div>
                </div>
              </div>
            </>
          )}

          <div className="mx-6 h-px bg-line/75" />

          <p className="px-6 py-4 text-center text-[12px] text-subtle">
            Ridary Proof is a personal safety credential, not legal advice, a
            court record, or an insurance guarantee.
          </p>

          <div className="border-t border-line/75 px-6 py-4">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <div>
                <div className="text-[16px] font-semibold text-paper">
                  {band} Band{" "}
                  <span className="text-[13px] font-normal text-muted">
                    · {view.score} / 100
                  </span>
                </div>
                <div className="text-[12px] text-subtle">
                  Key {view.publicKeyId}
                </div>
              </div>

              <button
                type="button"
                onClick={() => void verify()}
                disabled={busy}
                className="btn-glass-sky focus-ring px-5 py-2.5 text-[13px] disabled:opacity-60"
              >
                <ShieldCheck size={15} />
                {busy ? "Verifying…" : "Verify signature"}
              </button>
            </div>
          </div>
        </div>
      </article>
    </div>
  );
}

function CenteredInsurerMetric({
  value,
  label,
  accent = false
}: {
  value: string;
  label: string;
  accent?: boolean;
}) {
  return (
    <div>
      <div
        className={`text-[17px] font-semibold tracking-tight ${
          accent ? "text-sky-deep" : "text-paper"
        }`}
      >
        {value}
      </div>
      <div className="mt-0.5 text-[12px] text-muted">{label}</div>
    </div>
  );
}

function InsurerRow({
  icon,
  title,
  subtitle,
  mono = false
}: {
  icon: ReactNode;
  title: string;
  subtitle: string;
  mono?: boolean;
}) {
  return (
    <div className="flex items-start gap-3.5">
      <div className="ios-icon-circle mt-0.5">{icon}</div>
      <div className="min-w-0 flex-1">
        <div className="text-[15px] font-medium text-paper">{title}</div>
        <div
          className={`mt-0.5 text-[13px] text-muted ${
            mono ? "truncate font-mono text-[12px]" : "leading-relaxed"
          }`}
        >
          {subtitle}
        </div>
      </div>
    </div>
  );
}
