import {
  Activity,
  Cloud,
  Cpu,
  MapPin,
  RefreshCw,
  Route,
  ShieldCheck,
  Smartphone,
  TriangleAlert
} from "lucide-react";
import { useState } from "react";
import { Link } from "react-router-dom";
import {
  EmptyState,
  SectionHeader
} from "../components/Banners";
import { RideRow } from "../components/RideRow";
import { RiskMap } from "../components/RiskMap";
import { ScoreRing } from "../components/ScoreRing";
import { SourceBadge } from "../components/SourceBadge";
import { StatCard } from "../components/StatCard";
import { useApp } from "../context/AppContext";
import { generateCommunityInsight } from "../lib/ai";
import { localCommunityInsight } from "../lib/communityInsight";
import {
  formatDateTime,
  formatDistance,
  formatSpeed,
  scoreBand
} from "../lib/format";
import { severityColor, topRiskCell } from "../lib/risk";
import type { CommunityInsight, InferenceSource } from "../types";

export default function OverviewPage() {
  const { rides, riskCells, loading, refresh, demoMode } = useApp();
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
          weekRides.reduce((sum, ride) => sum + ride.score, 0) /
            weekRides.length
        )
      : 0;
  const communityEvents = riskCells.reduce((sum, cell) => sum + cell.count, 0);
  const hotspot = topRiskCell(riskCells);

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
      <header className="flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div className="mono-label">Overview / Hybrid ride witness</div>
          <h1 className="mt-2 text-3xl font-semibold tracking-[-0.035em] sm:text-4xl">
            Your ride. Your proof.
          </h1>
          <p className="mt-2 max-w-2xl text-sm leading-relaxed text-muted">
            A private record of what happened, plus a collective map of the
            road risks riders actually meet.
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <span className="inline-flex items-center gap-2 rounded-full border border-line bg-card px-3 py-2 font-mono text-[9px] uppercase tracking-[0.14em] text-muted">
            <Cpu size={13} className="text-teal" />
            On-device → cloud
          </span>
          <button
            type="button"
            onClick={() => void refresh()}
            disabled={loading}
            className="focus-ring inline-flex items-center gap-2 rounded-full border border-line bg-card px-3 py-2 font-mono text-[9px] uppercase tracking-[0.14em] text-muted transition hover:text-paper disabled:opacity-60"
          >
            <RefreshCw
              size={12}
              className={loading ? "animate-spin" : undefined}
            />
            Refresh
          </button>
        </div>
      </header>

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Rides this week"
          value={String(weekRides.length)}
          hint="Private sessions on this account"
          icon={Route}
        />
        <StatCard
          label="Distance"
          value={formatDistance(weekDistance)}
          hint="Last 7 days"
          icon={Activity}
          tone="text-accent"
        />
        <StatCard
          label="Average score"
          value={weekRides.length > 0 ? String(averageScore) : "—"}
          hint={weekRides.length > 0 ? `Band ${scoreBand(averageScore)}` : "No rides yet"}
          icon={ShieldCheck}
          tone="text-teal"
        />
        <StatCard
          label="Community events"
          value={String(communityEvents)}
          hint={`${riskCells.length} risk cells`}
          icon={MapPin}
          tone="text-danger"
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[1.55fr_1fr]">
        <section className="surface p-4 sm:p-5">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
            <SectionHeader
              eyebrow="Collective intelligence"
              title="Community risk map"
            />
            <RiskLegend />
          </div>
          <div className="mt-4">
            <RiskMap riskCells={riskCells} ride={latest} height={430} />
          </div>
          {riskCells.length > 0 && (
            <div className="mt-3 grid gap-2 sm:grid-cols-2">
              {[...riskCells]
                .sort(
                  (a, b) =>
                    b.severitySum / b.count - a.severitySum / a.count
                )
                .slice(0, 4)
                .map((cell) => {
                  const topType =
                    Object.entries(cell.topTypes).sort(
                      (a, b) => b[1] - a[1]
                    )[0]?.[0] ?? "event";
                  const severity =
                    cell.count > 0 ? cell.severitySum / cell.count : 0;
                  return (
                    <div
                      key={cell.id}
                      className="flex items-center justify-between gap-3 rounded-xl border border-line bg-ink-soft px-3 py-2"
                    >
                      <div>
                        <div className="font-mono text-[10px] text-paper">
                          {cell.geohash}
                        </div>
                        <div className="mt-0.5 text-[9px] text-muted">
                          {cell.count} events · {topType.replaceAll("_", " ")}
                        </div>
                      </div>
                      <span
                        className="font-mono text-[10px]"
                        style={{ color: severityColor(severity) }}
                      >
                        sev {severity.toFixed(1)}
                      </span>
                    </div>
                  );
                })}
            </div>
          )}
          <div className="mt-3 flex flex-wrap items-center justify-between gap-2">
            <button
              type="button"
              onClick={() => void explainMap()}
              disabled={insightBusy || riskCells.length === 0}
              className="focus-ring inline-flex items-center gap-2 rounded-xl border border-line bg-card-soft px-3 py-2 text-[10px] font-semibold uppercase tracking-[0.12em] text-paper transition hover:border-white/20 disabled:opacity-50"
            >
              <Cloud size={12} className="text-accent" />
              {insightBusy
                ? "Reading the map…"
                : demoMode
                  ? "Preview local insight"
                  : "Explain with cloud AI"}
            </button>
            {insightSource && <SourceBadge source={insightSource} />}
          </div>
          {insightError && (
            <p className="mt-2 text-[10px] leading-relaxed text-muted">
              {insightError}
            </p>
          )}
          {insight && (
            <div className="mt-3 rounded-xl border border-line bg-ink-soft p-3">
              <div className="text-xs font-semibold text-paper">
                {insight.headline}
              </div>
              <p className="mt-1.5 text-[11px] leading-relaxed text-muted">
                {insight.summary}
              </p>
              {insight.hotspots.length > 0 && (
                <div className="mt-2 space-y-1">
                  {insight.hotspots.map((item) => (
                    <div
                      key={item.geohash}
                      className="font-mono text-[9px] leading-relaxed text-muted"
                    >
                      <span className="text-paper">{item.geohash}</span> ·{" "}
                      {item.explanation}
                    </div>
                  ))}
                </div>
              )}
              <p className="mt-2 text-[11px] font-semibold text-accent">
                {insight.action}
              </p>
            </div>
          )}
          {hotspot && (
            <div className="mt-3 flex flex-wrap items-center justify-between gap-2 text-[11px] text-muted">
              <span className="inline-flex items-center gap-1.5">
                <TriangleAlert size={12} className="text-accent" />
                Hottest cell{" "}
                <span className="font-mono text-paper">
                  {hotspot.geohash}
                </span>{" "}
                · {hotspot.count} events
              </span>
              <span>
                Aggregate only — no rider route or identity is shown.
              </span>
            </div>
          )}
        </section>

        <section className="surface flex flex-col p-5">
          <SectionHeader eyebrow="Latest ride" title="Private snapshot" />
          {latest ? (
            <>
              <div className="mt-5 flex items-center gap-4">
                <ScoreRing score={latest.score} size={92} />
                <div className="min-w-0">
                  <div className="text-sm font-semibold text-paper">
                    {formatDateTime(latest.startedAtMs)}
                  </div>
                  <div className="mt-1 font-mono text-[10px] uppercase tracking-[0.14em] text-muted">
                    {latest.mode}
                  </div>
                  <div className="mt-2">
                    <SourceBadge source={latest.inferenceSource} />
                  </div>
                </div>
              </div>
              <p className="mt-4 line-clamp-4 text-xs leading-relaxed text-muted">
                {latest.summary}
              </p>
              <div className="mt-4 grid grid-cols-2 gap-2">
                <MiniStat label="Distance" value={formatDistance(latest.distanceM)} />
                <MiniStat label="Avg speed" value={formatSpeed(latest.avgSpeedKph)} />
                <MiniStat label="Moments" value={String(latest.events.length)} />
                <MiniStat label="Band" value={scoreBand(latest.score)} />
              </div>
              <Link
                to={`/rides?ride=${encodeURIComponent(latest.id)}`}
                className="focus-ring mt-auto inline-flex items-center justify-center rounded-xl border border-line bg-card-soft px-4 py-3 text-xs font-semibold text-paper transition hover:border-white/20"
              >
                Open ride and run a review
              </Link>
            </>
          ) : (
            <div className="mt-4">
              <EmptyState
                title="No rides yet"
                message="Start a session on the iOS app, keep the phone in your pocket, and the snapshot will appear here."
              />
            </div>
          )}
        </section>
      </div>

      <div className="grid gap-4 xl:grid-cols-[1.45fr_1fr]">
        <section className="surface p-5">
          <SectionHeader
            eyebrow="History"
            title="Recent rides"
            action={
              rides.length > 0 ? (
                <Link
                  to="/rides"
                  className="focus-ring font-mono text-[10px] uppercase tracking-[0.14em] text-accent hover:text-accent/80"
                >
                  View all
                </Link>
              ) : undefined
            }
          />
          <div className="mt-4 space-y-2">
            {rides.length === 0 ? (
              <EmptyState
                title="Your history is private"
                message="Rides are stored locally on the iOS device and only summaries sync when you turn sharing on."
              />
            ) : (
              rides.slice(0, 4).map((ride) => <RideRow key={ride.id} ride={ride} />)
            )}
          </div>
        </section>

        <section className="surface p-5">
          <SectionHeader
            eyebrow="Why hybrid"
            title="Private at the edge. Collective in the cloud."
          />
          <div className="mt-4 space-y-3">
            <SplitRow
              icon={<Smartphone size={15} />}
              title="On device"
              text="Ride snapshot, event explanation, incident interview, and evidence drafting."
              tone="text-teal"
            />
            <SplitRow
              icon={<Cloud size={15} />}
              title="In the cloud"
              text="Cross-rider risk map, weekly patterns, and the signed credential narrative."
              tone="text-accent"
            />
          </div>
          <p className="mt-4 border-t border-line pt-4 text-[11px] leading-relaxed text-muted">
            Sensitive evidence is pinned to the on-device path. Aggregate
            analysis is the only thing that leaves the device by default.
          </p>
        </section>
      </div>
    </div>
  );
}

function RiskLegend() {
  return (
    <div className="flex flex-wrap items-center gap-3 font-mono text-[9px] uppercase tracking-[0.12em] text-muted">
      <LegendDot color="#5be3c0" label="Low" />
      <LegendDot color="#ffb84d" label="Medium" />
      <LegendDot color="#ff6b6b" label="High" />
    </div>
  );
}

function LegendDot({ color, label }: { color: string; label: string }) {
  return (
    <span className="inline-flex items-center gap-1.5">
      <span
        className="h-2 w-2 rounded-full"
        style={{ backgroundColor: color }}
      />
      {label}
    </span>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-line bg-ink-soft px-3 py-2">
      <div className="font-mono text-[9px] uppercase tracking-[0.14em] text-muted">
        {label}
      </div>
      <div className="mt-1 text-xs font-semibold text-paper">{value}</div>
    </div>
  );
}

function SplitRow({
  icon,
  title,
  text,
  tone
}: {
  icon: React.ReactNode;
  title: string;
  text: string;
  tone: string;
}) {
  return (
    <div className="flex gap-3 rounded-xl border border-line bg-ink-soft p-3">
      <div className={`mt-0.5 ${tone}`}>{icon}</div>
      <div>
        <div className="text-xs font-semibold text-paper">{title}</div>
        <div className="mt-1 text-[11px] leading-relaxed text-muted">{text}</div>
      </div>
    </div>
  );
}
