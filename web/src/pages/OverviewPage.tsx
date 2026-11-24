import {
  Activity,
  ArrowUpRight,
  BarChart3,
  Cloud,
  Cpu,
  MapPin,
  RefreshCw,
  ShieldCheck
} from "lucide-react";
import type { ReactNode } from "react";
import { useState } from "react";
import { Link } from "react-router-dom";
import { EmptyState, SectionHeader } from "../components/Banners";
import { RideActivityCard } from "../components/RideActivityCard";
import { RiskMap } from "../components/RiskMap";
import { SourceBadge } from "../components/SourceBadge";
import { useApp } from "../context/AppContext";
import { generateCommunityInsight } from "../lib/ai";
import { localCommunityInsight } from "../lib/communityInsight";
import { formatDistance, scoreBand } from "../lib/format";
import { severityColor, topRiskCell } from "../lib/risk";
import type { CommunityInsight, InferenceSource } from "../types";

export default function OverviewPage() {
  const { rides, riskCells, credentials, loading, refresh, demoMode } = useApp();
  const [insight, setInsight] = useState<CommunityInsight | null>(null);
  const [insightSource, setInsightSource] = useState<InferenceSource | null>(null);
  const [insightBusy, setInsightBusy] = useState(false);
  const [insightError, setInsightError] = useState<string | null>(null);

  const latest = rides[0];
  const referenceNow = latest?.startedAtMs ?? 0;
  const cutoff = referenceNow - 7 * 24 * 60 * 60 * 1000;
  const weekRides = rides.filter((ride) => ride.startedAtMs >= cutoff);
  const weekDistance = weekRides.reduce((sum, ride) => sum + ride.distanceM, 0);
  const averageScore =
    weekRides.length > 0
      ? Math.round(
          weekRides.reduce((sum, ride) => sum + ride.score, 0) / weekRides.length
        )
      : 0;
  const communityEvents = riskCells.reduce((sum, cell) => sum + cell.count, 0);
  const hotspot = topRiskCell(riskCells);
  const latestCredential = credentials[0];
  const recent = rides.slice(1, 4);

  async function explainMap() {
    if (riskCells.length === 0) return;
    setInsightBusy(true);
    setInsightError(null);
    if (demoMode) {
      setInsight(localCommunityInsight(riskCells));
      setInsightSource("deterministic");
      setInsightBusy(false);
      return;
    }
    const result = await generateCommunityInsight(riskCells);
    setInsight(result.insight);
    setInsightSource(result.source);
    if (result.source === "fallback") {
      setInsightError(
        "Cloud AI was unavailable, so a local aggregate summary is shown."
      );
    }
    setInsightBusy(false);
  }

  return (
    <div className="space-y-6">
      <header className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div className="mono-label">Overview</div>
          <h1 className="mt-1.5 text-3xl font-semibold tracking-[-0.03em] text-paper sm:text-[34px]">
            Your ride, on record.
          </h1>
          <p className="mt-1.5 max-w-xl text-[15px] leading-relaxed text-muted">
            A private record of what happened on your iPhone, paired with the
            community road-risk map.
          </p>
        </div>
        <div className="flex items-center gap-2.5">
          <span className="inline-flex items-center gap-2 rounded-full bg-sky-soft px-3.5 py-2 text-[12px] font-medium text-sky-deep">
            <Cpu size={13} className="text-sky" />
            On-device first
          </span>
          <button
            type="button"
            onClick={() => void refresh()}
            disabled={loading}
            className="btn-glass focus-ring px-4 py-2 text-[12px] disabled:opacity-60"
          >
            <RefreshCw size={13} className={loading ? "animate-spin" : undefined} />
            Refresh
          </button>
        </div>
      </header>

      <div className="grid gap-5 xl:grid-cols-[1.52fr_0.88fr]">
        <section className="surface overflow-hidden">
          <div className="flex flex-col gap-3 px-6 pb-4 pt-5 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <div className="mono-label">Community risk map</div>
              <h2 className="mt-1 text-[20px] font-semibold tracking-[-0.02em] text-paper">
                Road risk around you
              </h2>
              <p className="mt-0.5 text-[13px] text-muted">
                {communityEvents} anonymized moments across {riskCells.length} coarse cells
              </p>
            </div>
            <RiskLegend />
          </div>

          <div className="px-5">
            <RiskMap riskCells={riskCells} ride={latest} height={400} />
          </div>

          {riskCells.length > 0 ? (
            <div className="mt-4 grid divide-y divide-line/70 border-t border-line/70 px-6 sm:grid-cols-2 sm:divide-x sm:divide-y-0">
              {[...riskCells]
                .sort((a, b) => b.severitySum / b.count - a.severitySum / a.count)
                .slice(0, 4)
                .map((cell, index) => {
                  const topType =
                    Object.entries(cell.topTypes).sort((a, b) => b[1] - a[1])[0]?.[0] ??
                    "event";
                  const severity = cell.count > 0 ? cell.severitySum / cell.count : 0;
                  return (
                    <div
                      key={cell.id}
                      className={`flex items-center justify-between gap-3 py-3.5 ${
                        index % 2 === 1 ? "sm:pl-5" : "sm:pr-5"
                      } ${index >= 2 ? "sm:border-t sm:border-line/70" : ""}`}
                    >
                      <div className="flex items-center gap-3">
                        <span className="ios-icon-circle h-8 w-8">
                          <MapPin size={14} />
                        </span>
                        <div>
                          <div className="text-[14px] font-medium capitalize text-paper">
                            {topType.replaceAll("_", " ")}
                          </div>
                          <div className="text-[12px] text-muted">
                            Cell <span className="font-mono">{cell.geohash}</span> · {cell.count} events
                          </div>
                        </div>
                      </div>
                      <span
                        className="rounded-full px-2.5 py-0.5 text-[12px] font-semibold"
                        style={{
                          color: severityColor(severity),
                          backgroundColor: `${severityColor(severity)}14`
                        }}
                      >
                        {severity.toFixed(1)}
                      </span>
                    </div>
                  );
                })}
            </div>
          ) : (
            <div className="p-5">
              <EmptyState
                title="No community events yet"
                message="Anonymized moments from synced rides will collect here."
              />
            </div>
          )}

          <div className="border-t border-line/70 px-6 py-4">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <div className="text-[12px] text-muted">
                {hotspot ? (
                  <span>
                    Top cell <span className="font-mono font-medium text-paper">{hotspot.geohash}</span> · Aggregate only, zero raw GPS
                  </span>
                ) : (
                  <span>Aggregate geohash cells only — no rider routes or identity</span>
                )}
              </div>

              <div className="flex items-center gap-2.5">
                {insightSource && <SourceBadge source={insightSource} />}
                <button
                  type="button"
                  onClick={() => void explainMap()}
                  disabled={insightBusy || riskCells.length === 0}
                  className="btn-glass-sky focus-ring px-4 py-2 text-[13px] disabled:opacity-50"
                >
                  <Cloud size={14} />
                  {insightBusy
                    ? "Reading map…"
                    : demoMode
                      ? "Preview local insight"
                      : "Explain with cloud AI"}
                </button>
              </div>
            </div>

            {insightError && (
              <p className="mt-2.5 text-[12px] text-muted">{insightError}</p>
            )}

            {insight && (
              <div className="mt-4 rounded-2xl bg-sky-soft/55 p-4">
                <div className="text-[15px] font-medium text-paper">
                  {insight.headline}
                </div>
                <p className="mt-1 text-[13px] leading-relaxed text-muted">
                  {insight.summary}
                </p>
                <p className="mt-2 text-[13px] font-medium text-sky-deep">
                  {insight.action}
                </p>
              </div>
            )}
          </div>
        </section>

        <aside className="space-y-4">
          <section className="surface overflow-hidden">
            <div className="ios-hero-pastel flex flex-col items-center px-6 pb-9 pt-7 text-center">
              <div className="mono-label">This week</div>
              <div className="ios-hero-badge mt-3">
                <BarChart3 size={22} strokeWidth={1.9} />
              </div>
              <div className="mt-3 text-[32px] font-semibold tracking-[-0.03em] text-paper">
                {formatDistance(weekDistance)}
              </div>
              <div className="mt-0.5 text-[13px] text-muted">
                {weekRides.length} {weekRides.length === 1 ? "ride" : "rides"} recorded
              </div>
            </div>

            <div className="-mt-5 rounded-t-[1.625rem] bg-white px-5 pb-4 pt-5">
              <div className="grid grid-cols-3 divide-x divide-line/75 items-center text-center">
                <WeekValue
                  value={weekRides.length ? String(averageScore) : "—"}
                  label="Avg safety"
                  accent
                />
                <WeekValue
                  value={String(weekRides.length)}
                  label="Rides"
                />
                <WeekValue
                  value={
                    weekRides.length ? `${scoreBand(averageScore)} Band` : "—"
                  }
                  label="Safety tier"
                />
              </div>
            </div>
          </section>

          {latest ? (
            <RideActivityCard ride={latest} compact />
          ) : (
            <EmptyState
              title="No rides yet"
              message="Start a session on the iOS app and its summary will land here."
            />
          )}

          <Link
            to="/credential"
            className="focus-ring group surface flex items-center gap-3.5 p-4 transition duration-200 hover:-translate-y-0.5"
          >
            <div className="ios-icon-circle h-10 w-10">
              <ShieldCheck size={18} strokeWidth={1.9} />
            </div>
            <div className="min-w-0 flex-1">
              <div className="text-[15px] font-medium text-paper">
                {latestCredential ? "Ridary Proof" : "Build your proof"}
              </div>
              <div className="mt-0.5 text-[13px] text-muted">
                {latestCredential
                  ? `${scoreBand(latestCredential.score)} Band · Score ${latestCredential.score}/100`
                  : "Record 3 rides to issue a signed credential"}
              </div>
            </div>
            <ArrowUpRight
              size={16}
              className="text-subtle transition group-hover:text-sky-deep"
            />
          </Link>
        </aside>
      </div>

      {recent.length > 0 && (
        <section className="space-y-3">
          <div className="flex items-baseline justify-between">
            <SectionHeader title="Recent rides" />
            <Link
              to="/rides"
              className="text-[13px] font-medium text-sky-deep hover:underline"
            >
              View all
            </Link>
          </div>
          <div className="grid gap-4 md:grid-cols-3">
            {recent.map((ride) => (
              <RideActivityCard key={ride.id} ride={ride} compact />
            ))}
          </div>
        </section>
      )}

      <section className="surface p-6">
        <div className="grid gap-6 lg:grid-cols-[0.95fr_1.05fr] lg:items-center">
          <div>
            <div className="mono-label">Hybrid trust boundary</div>
            <h2 className="mt-1.5 text-[22px] font-semibold tracking-[-0.025em] text-paper">
              Private at the edge. Collective in the cloud.
            </h2>
            <p className="mt-2 max-w-md text-[14px] leading-relaxed text-muted">
              Ride snapshots and incident notes stay private by default. Only
              derived moments and summaries build the community map and signed
              proof.
            </p>
          </div>
          <div className="divide-y divide-line/70">
            <HybridRow
              icon={<Cpu size={16} />}
              title="On device"
              text="Snapshot, event explanation, Ask Ridary, and locked incident statements."
            />
            <HybridRow
              icon={<Cloud size={16} />}
              title="In cloud"
              text="Cross-rider risk cells, weekly patterns, and signed Ed25519 credentials."
            />
            <HybridRow
              icon={<Activity size={16} />}
              title="Deterministic rules"
              text="Motion capture, event thresholds, safety score, SHA-256 hash, and offline fallback."
            />
          </div>
        </div>
      </section>
    </div>
  );
}

function WeekValue({
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
        className={`text-[18px] font-semibold tracking-tight ${
          accent ? "text-sky-deep" : "text-paper"
        }`}
      >
        {value}
      </div>
      <div className="mt-0.5 text-[12px] text-muted">{label}</div>
    </div>
  );
}

function HybridRow({
  icon,
  title,
  text
}: {
  icon: ReactNode;
  title: string;
  text: string;
}) {
  return (
    <div className="flex items-start gap-3.5 py-3.5 first:pt-0 last:pb-0">
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

function RiskLegend() {
  return (
    <div className="flex items-center gap-3.5 text-[12px] text-muted">
      <span className="inline-flex items-center gap-1.5">
        <span className="h-2 w-2 rounded-full bg-sky" /> Low
      </span>
      <span className="inline-flex items-center gap-1.5">
        <span className="h-2 w-2 rounded-full bg-warning" /> Medium
      </span>
      <span className="inline-flex items-center gap-1.5">
        <span className="h-2 w-2 rounded-full bg-safety" /> High
      </span>
    </div>
  );
}
