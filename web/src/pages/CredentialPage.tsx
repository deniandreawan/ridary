import {
  CalendarClock,
  CheckCircle2,
  Copy,
  ExternalLink,
  KeyRound,
  Lock,
  Share2,
  ShieldCheck,
  XCircle
} from "lucide-react";
import type { ReactNode } from "react";
import { useState } from "react";
import { EmptyState } from "../components/Banners";
import { useApp } from "../context/AppContext";
import { formatISODate, formatPeriod, scoreBand } from "../lib/format";
import type {
  CredentialVerification,
  InsurerShareLink
} from "../types";

export default function CredentialPage() {
  const {
    credentials,
    demoMode,
    issueCredential,
    verifyCredential,
    createInsurerView
  } = useApp();
  const latest = credentials[0];
  const latestBand = latest ? scoreBand(latest.score) : "D";

  const [verification, setVerification] =
    useState<CredentialVerification | null>(null);
  const [share, setShare] = useState<InsurerShareLink | null>(null);
  const [copied, setCopied] = useState(false);
  const [busyIssue, setBusyIssue] = useState(false);
  const [busyVerify, setBusyVerify] = useState(false);
  const [busyShare, setBusyShare] = useState(false);

  async function copy(value: string) {
    try {
      await navigator.clipboard.writeText(value);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1600);
    } catch {
      setCopied(false);
    }
  }

  async function issue() {
    setBusyIssue(true);
    await issueCredential();
    setBusyIssue(false);
  }

  async function verify() {
    if (!latest) return;
    setBusyVerify(true);
    setVerification(await verifyCredential(latest.credentialId));
    setBusyVerify(false);
  }

  async function shareCredential() {
    if (!latest) return;
    setBusyShare(true);
    setShare(await createInsurerView(latest.credentialId));
    setBusyShare(false);
  }

  return (
    <div className="mx-auto max-w-3xl space-y-5">
      {latest ? (
        <article className="surface overflow-hidden">
          <div className="ios-hero-pastel flex flex-col items-center px-6 pb-11 pt-9 text-center">
            <div className="mono-label">
              Valid until {formatISODate(latest.expiresAt)}
            </div>
            <div className="ios-hero-badge mt-3.5">
              <ShieldCheck size={26} strokeWidth={1.9} />
            </div>
            <div className="mt-3.5 text-[34px] font-semibold tracking-[-0.03em] text-paper">
              {latestBand} Band
            </div>
            <div className="mt-1 text-[13px] text-muted">
              {formatPeriod(latest.periodStart, latest.periodEnd)} ·{" "}
              {latest.rideCount} rides
            </div>
          </div>

          <div className="relative -mt-6 rounded-t-[1.625rem] bg-white pt-7 shadow-[0_-6px_20px_rgba(23,23,23,0.04)]">
            <div className="mx-auto max-w-xl px-6 pb-6 text-center">
              <h1 className="text-[23px] font-semibold tracking-[-0.025em] text-paper">
                Proof, not surveillance
              </h1>
              <p className="mt-2.5 text-[15px] leading-relaxed text-muted">
                A cryptographic summary of your recent rides. Share your safety
                band with an insurer without exposing routes or raw GPS.
              </p>
              <div className="mt-3.5 inline-flex items-center gap-1.5 text-[13px]">
                <CheckCircle2 size={14} className="text-sky" />
                <span className="font-medium text-paper">
                  Signed by {latest.issuer}
                </span>
                <span className="text-muted">· Ed25519 verified</span>
              </div>
            </div>

            <div className="mx-6 h-px bg-line/75" />

            <div className="grid grid-cols-3 divide-x divide-line/75 items-center px-6 py-5 text-center">
              <CenteredProofMetric
                value={`${latestBand} Band`}
                label="Safety tier"
                accent
              />
              <CenteredProofMetric
                value={String(latest.score)}
                label="Out of 100"
              />
              <CenteredProofMetric
                value={`${latest.rideCount} rides`}
                label={`${latest.eventCount} moments`}
              />
            </div>

            <div className="mx-6 h-px bg-line/75" />

            <div className="space-y-4 px-6 py-6">
              <h2 className="text-[17px] font-semibold tracking-[-0.015em] text-paper">
                What this credential proves
              </h2>

              <HighlightRow
                icon={<ShieldCheck size={15} />}
                title={`Signed by ${latest.issuer}`}
                subtitle="Cryptographic Ed25519 signature verifying your safety band and ride count."
              />
              <HighlightRow
                icon={<Lock size={15} />}
                title="Zero raw GPS shared"
                subtitle="Insurers see only your aggregate score and period—never routes or timestamps."
              />
              <HighlightRow
                icon={<CalendarClock size={15} />}
                title={`Valid until ${formatISODate(latest.expiresAt)}`}
                subtitle={`Covers your ${latest.mode} sessions from ${formatPeriod(
                  latest.periodStart,
                  latest.periodEnd
                )}.`}
              />
              <HighlightRow
                icon={<KeyRound size={15} />}
                title={`Key ${latest.publicKeyId}`}
                subtitle={latest.payloadHash}
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
                        ? "Signature valid"
                        : "Verification failed"}
                    </div>
                    <p className="mt-0.5 text-[13px] text-muted">
                      {verification.reason ??
                        "The credential hash and Ed25519 signature match."}
                    </p>
                  </div>
                </div>
              </>
            )}

            {share && (
              <>
                <div className="mx-6 h-px bg-line/75" />
                <div className="px-6 py-5">
                  <div className="text-[15px] font-medium text-paper">
                    Shareable insurer link
                  </div>
                  <div className="mt-2 break-all rounded-2xl bg-canvas-soft px-3.5 py-2.5 font-mono text-[12px] text-paper">
                    {share.url}
                  </div>
                  <div className="mt-3 flex flex-wrap gap-2">
                    <button
                      type="button"
                      onClick={() => void copy(share.url)}
                      className="btn-glass focus-ring px-3.5 py-2 text-[13px]"
                    >
                      <Copy size={13} />
                      {copied ? "Copied" : "Copy link"}
                    </button>
                    <a
                      href={share.url}
                      target="_blank"
                      rel="noreferrer"
                      className="btn-glass focus-ring px-3.5 py-2 text-[13px]"
                    >
                      <ExternalLink size={13} />
                      Open insurer view
                    </a>
                  </div>
                </div>
              </>
            )}

            {credentials.length > 1 && (
              <>
                <div className="mx-6 h-px bg-line/75" />
                <div className="px-6 py-6">
                  <h3 className="text-[17px] font-semibold tracking-[-0.015em] text-paper">
                    Earlier proofs
                  </h3>
                  <div className="mt-3 divide-y divide-line/65">
                    {credentials.slice(1).map((credential) => (
                      <div
                        key={credential.credentialId}
                        className="flex items-center justify-between gap-3 py-3"
                      >
                        <div>
                          <div className="text-[15px] font-medium text-paper">
                            {formatPeriod(
                              credential.periodStart,
                              credential.periodEnd
                            )}
                          </div>
                          <div className="mt-0.5 text-[13px] text-muted">
                            Score {credential.score} · {credential.rideCount} rides
                          </div>
                        </div>
                        <span className="text-[17px] font-semibold text-sky-deep">
                          {scoreBand(credential.score)}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              </>
            )}

            <div className="mx-6 h-px bg-line/75" />

            <p className="px-6 py-4 text-center text-[12px] text-subtle">
              Ridary Proof is a personal safety credential, not legal proof, a
              court record, or an insurance guarantee.
            </p>

            <div className="border-t border-line/75 px-6 py-4">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <div className="text-[16px] font-semibold text-paper">
                    {latestBand} Band{" "}
                    <span className="text-[13px] font-normal text-muted">
                      · {latest.score} / 100
                    </span>
                  </div>
                  <div className="text-[12px] text-subtle">
                    Expires {formatISODate(latest.expiresAt)}
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-2">
                  {!demoMode && (
                    <button
                      type="button"
                      onClick={() => void issue()}
                      disabled={busyIssue}
                      className="btn-glass focus-ring px-4 py-2 text-[13px] disabled:opacity-50"
                    >
                      {busyIssue ? "Issuing…" : "Re-issue"}
                    </button>
                  )}
                  <button
                    type="button"
                    onClick={() => void verify()}
                    disabled={busyVerify}
                    className="btn-glass focus-ring px-4 py-2 text-[13px] disabled:opacity-60"
                  >
                    {busyVerify ? "Verifying…" : "Verify"}
                  </button>
                  <button
                    type="button"
                    onClick={() => void shareCredential()}
                    disabled={busyShare}
                    className="btn-glass-sky focus-ring px-4 py-2 text-[13px] disabled:opacity-60"
                  >
                    <Share2 size={14} />
                    {busyShare ? "Sharing…" : "Share"}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </article>
      ) : (
        <section className="surface overflow-hidden">
          <div className="ios-hero-pastel flex flex-col items-center px-6 pb-11 pt-9 text-center">
            <div className="mono-label">30-day window</div>
            <div className="ios-hero-badge mt-3.5">
              <ShieldCheck size={24} strokeWidth={1.9} />
            </div>
            <div className="mt-3.5 text-[28px] font-semibold tracking-[-0.025em] text-paper">
              Build your proof
            </div>
            <div className="mt-1 text-[13px] text-muted">
              Record at least 3 rides in the last 30 days
            </div>
          </div>
          <div className="relative -mt-6 rounded-t-[1.625rem] bg-white p-6">
            <EmptyState
              title="No credential yet"
              message="Record at least three rides in the last 30 days, then issue a signed Ridary Proof that an insurer can verify."
            />
            <div className="mt-5 flex justify-center">
              <button
                type="button"
                onClick={() => void issue()}
                disabled={busyIssue || demoMode}
                className="btn-glass-sky focus-ring px-5 py-2.5 text-[14px] disabled:opacity-50"
              >
                <ShieldCheck size={15} />
                {busyIssue ? "Issuing…" : "Issue proof"}
              </button>
            </div>
          </div>
        </section>
      )}
    </div>
  );
}

function CenteredProofMetric({
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

function HighlightRow({
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
