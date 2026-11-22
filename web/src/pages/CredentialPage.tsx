import {
  CheckCircle2,
  Copy,
  ExternalLink,
  KeyRound,
  Share2,
  ShieldCheck,
  XCircle
} from "lucide-react";
import { useState } from "react";
import { EmptyState, SectionHeader } from "../components/Banners";
import { ScoreRing } from "../components/ScoreRing";
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
    <div className="space-y-5">
      <header className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div className="mono-label">Credential / Ridary Proof</div>
          <h1 className="mt-2 text-3xl font-semibold tracking-[-0.03em]">
            Proof without surveillance.
          </h1>
          <p className="mt-2 max-w-2xl text-sm leading-relaxed text-muted">
            A signed safety credential that shows the pattern, not your route.
            Insurers can verify the signature without receiving raw location or
            sensor data.
          </p>
        </div>
        {latest && (
          <button
            type="button"
            onClick={() => void issue()}
            disabled={busyIssue || demoMode}
            className="focus-ring inline-flex items-center gap-2 rounded-xl border border-line bg-card px-4 py-2.5 text-xs font-semibold text-paper transition hover:border-ink/20 disabled:opacity-50"
          >
            <ShieldCheck size={14} className="text-teal" />
            {busyIssue ? "Issuing…" : "Issue new credential"}
          </button>
        )}
      </header>

      {latest ? (
        <div className="grid gap-4 xl:grid-cols-[1.45fr_1fr]">
          <section className="surface p-6">
            <div className="flex flex-col gap-5 sm:flex-row sm:items-center">
              <ScoreRing score={latest.score} size={126} />
              <div className="min-w-0">
                <div className="mono-label">Ridary Proof</div>
                <div className="mt-1 text-2xl font-semibold tracking-tight">
                  {latestBand} band
                </div>
                <div className="mt-2 inline-flex items-center gap-2 rounded-full border border-teal/30 bg-teal/8 px-2.5 py-1 font-mono text-[9px] uppercase tracking-[0.12em] text-teal">
                  <CheckCircle2 size={11} />
                  Signed by {latest.issuer}
                </div>
                <p className="mt-3 text-xs leading-relaxed text-muted">
                  {formatPeriod(latest.periodStart, latest.periodEnd)}
                </p>
              </div>
            </div>

            <div className="mt-6 grid grid-cols-2 gap-2 sm:grid-cols-4">
              <Meta label="Rides" value={String(latest.rideCount)} />
              <Meta label="Moments" value={String(latest.eventCount)} />
              <Meta label="Issued" value={formatISODate(latest.issuedAt)} />
              <Meta label="Expires" value={formatISODate(latest.expiresAt)} />
            </div>

            <div className="mt-5 space-y-2 border-t border-line pt-4 font-mono text-[10px] text-muted">
              <div className="flex items-center gap-2">
                <KeyRound size={11} className="text-accent" />
                key {latest.publicKeyId}
              </div>
              <div className="break-all">
                hash {latest.payloadHash}
              </div>
            </div>

            <div className="mt-5 flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => void verify()}
                disabled={busyVerify}
                className="focus-ring inline-flex items-center gap-2 rounded-xl border border-line bg-card-soft px-4 py-2.5 text-xs font-semibold text-paper transition hover:border-ink/20 disabled:opacity-60"
              >
                <ShieldCheck size={14} />
                {busyVerify ? "Verifying…" : "Verify signature"}
              </button>
              <button
                type="button"
                onClick={() => void shareCredential()}
                disabled={busyShare}
                className="focus-ring inline-flex items-center gap-2 rounded-xl bg-accent px-4 py-2.5 text-xs font-semibold text-on-accent transition hover:bg-accent/90 disabled:opacity-60"
              >
                <Share2 size={14} />
                {busyShare ? "Creating link…" : "Share with insurer"}
              </button>
            </div>

            {demoMode && (
              <p className="mt-3 text-[10px] leading-relaxed text-muted">
                This is a sample credential. Connect a Firebase project to
                issue and verify a real server-signed credential.
              </p>
            )}
          </section>

          <div className="space-y-4">
            {verification && (
              <section
                className={`surface p-4 ${
                  verification.valid ? "" : "border-danger/20"
                }`}
              >
                <div className="flex items-start gap-3">
                  {verification.valid ? (
                    <CheckCircle2 size={18} className="mt-0.5 text-teal" />
                  ) : (
                    <XCircle size={18} className="mt-0.5 text-danger" />
                  )}
                  <div>
                    <div className="text-sm font-semibold text-paper">
                      {verification.valid
                        ? "Signature and hash match"
                        : "Verification did not pass"}
                    </div>
                    <p className="mt-1 text-[11px] leading-relaxed text-muted">
                      {verification.reason ??
                        "The Ed25519 signature and payload hash are valid."}
                    </p>
                  </div>
                </div>
              </section>
            )}

            {share && (
              <section className="surface p-4">
                <div className="mono-label">Insurer link</div>
                <div className="mt-2 break-all rounded-xl border border-line bg-ink-soft p-3 font-mono text-[10px] text-paper">
                  {share.url}
                </div>
                <div className="mt-3 flex flex-wrap gap-2">
                  <button
                    type="button"
                    onClick={() => void copy(share.url)}
                    className="focus-ring inline-flex items-center gap-2 rounded-xl border border-line bg-card-soft px-3 py-2 text-xs font-semibold text-paper"
                  >
                    <Copy size={13} />
                    {copied ? "Copied" : "Copy link"}
                  </button>
                  <a
                    href={share.url}
                    target="_blank"
                    rel="noreferrer"
                    className="focus-ring inline-flex items-center gap-2 rounded-xl border border-line bg-card-soft px-3 py-2 text-xs font-semibold text-paper"
                  >
                    <ExternalLink size={13} />
                    Open insurer view
                  </a>
                </div>
              </section>
            )}

            <section className="surface p-5">
              <SectionHeader eyebrow="How it works" title="Three steps" />
              <ol className="mt-4 space-y-4">
                <Step
                  number="01"
                  title="Ride privately"
                  text="The phone records route and motion locally. On-device AI builds the snapshot."
                />
                <Step
                  number="02"
                  title="Issue a proof"
                  text="The server checks eligible rides and signs a credential with Ed25519."
                />
                <Step
                  number="03"
                  title="Share the proof"
                  text="The insurer gets a score and a signature, never the raw route."
                />
              </ol>
            </section>
          </div>
        </div>
      ) : (
        <section className="surface p-6">
          <EmptyState
            title="No credential yet"
            message="Record at least three rides in the last 30 days, then issue a signed Ridary Proof."
          />
          <div className="mt-4 flex justify-center">
            <button
              type="button"
              onClick={() => void issue()}
              disabled={busyIssue || demoMode}
              className="focus-ring inline-flex items-center gap-2 rounded-xl bg-accent px-5 py-3 text-xs font-semibold text-on-accent transition hover:bg-accent/90 disabled:opacity-50"
            >
              <ShieldCheck size={15} />
              {busyIssue ? "Issuing…" : "Issue credential"}
            </button>
          </div>
          {demoMode && (
            <p className="mt-3 text-center text-[10px] leading-relaxed text-muted">
              Credential issuance needs a configured Firebase project and a
              signed-in rider.
            </p>
          )}
        </section>
      )}

      {credentials.length > 1 && (
        <section className="surface p-5">
          <SectionHeader eyebrow="Archive" title="Past credentials" />
          <div className="mt-4 space-y-2">
            {credentials.slice(1).map((credential) => (
              <div
                key={credential.credentialId}
                className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-line bg-ink-soft px-4 py-3"
              >
                <div>
                  <div className="text-xs font-semibold text-paper">
                    {formatPeriod(credential.periodStart, credential.periodEnd)}
                  </div>
                  <div className="mt-1 font-mono text-[9px] uppercase tracking-[0.12em] text-muted">
                    score {credential.score} · {credential.rideCount} rides
                  </div>
                </div>
                <div className="inline-flex items-center gap-2">
                  <span className="font-mono text-[10px] text-muted">
                    band
                  </span>
                  <span className="font-semibold text-teal">
                    {scoreBand(credential.score)}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}
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

function Step({
  number,
  title,
  text
}: {
  number: string;
  title: string;
  text: string;
}) {
  return (
    <li className="flex gap-3">
      <div className="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg border border-accent/25 bg-accent/8 font-mono text-[9px] text-accent">
        {number}
      </div>
      <div>
        <div className="text-xs font-semibold text-paper">{title}</div>
        <div className="mt-1 text-[11px] leading-relaxed text-muted">
          {text}
        </div>
      </div>
    </li>
  );
}
