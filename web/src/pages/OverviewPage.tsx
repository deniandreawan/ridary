import { Activity, ArrowUpRight, Cloud, Cpu, MapPin, RefreshCw, ShieldCheck } from "lucide-react";
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
      setInsightError("Cloud AI was unavailable, so a local aggregate summary is shown.");
    }
    setInsightBusy(false);
  }

  return (
    <div className="space-y-6">
      <header className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div className="mono-label">Overview</div>
          <h1 className="mt-2 max-w-2xl text-3xl font-semibold tracking-[-0.04em] text-paper sm:text-4xl">
            Your ride, on record.
          </h1>
          <p className="mt-2 max-w-xl text-sm leading-relaxed text-muted">
            A private record of what happened, plus the road risks riders
            actually meet.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="inline-flex items-center gap-2 rounded-full border border-line bg-card px-3 py-2 text-[10px] font-semibold text-muted">
            <Cpu size={13} className="text-teal" />
            On-device first
          </span>
          <button
            type="button"
            onClick={() => void refresh()}
            disabled={loading}
            className="focus-ring inline-flex items-center gap-2 rounded-full border border-line bg-card px-3 py-2 text-[10px] font-semibold text-muted transition hover:border-ink/20 hover:text-paper disabled:opacity-60"
          >
            <RefreshCw size={12} className={loading ? "animate-spin" : undefined} />
            Refresh
          </button>
        </div>
      </header>

      <div className="grid gap-4 xl:grid-cols-[1.55fr_0.85fr]">
        <section className="surface overflow-hidden">
          <div className="flex flex-col gap-3 p-5 pb-4 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <div className="mono-label">Community</div>
              <h2 className="mt-1 text-xl font-semibold tracking-tight text-paper">
                Road risk around you
              </h2>
              <p className="mt-1 text-xs text-muted">
                {communityEvents} anonymized moments across {riskCells.length} cells.
              </p>
            </div>
            <RiskLegend />
          </div>

          <RiskMap riskCells={riskCells} ride={latest} height={430} />

          {riskCells.length > 0 ? (
            <div className="grid gap-2 p-4 sm:grid-cols-2">
              {[...riskCells]
                .sort((a, b) => b.severitySum / b.count - a.severitySum / a.count)
                .slice(0, 4)
                .map((cell) => {
                  const topType =
                    Object.entries(cell.topTypes).sort((a, b) => b[1] - a[1])[0]?.[0] ??
                    "event";
                  const severity = cell.count > 0 ? cell.severitySum / cell.count : 0;
                  return (
                    <div
                      key={cell.id}
                      className="flex items-center justify-between gap-3 rounded-xl bg-card-soft px-3 py-2.5"
                    >
                      <div>
                        <div className="font-mono text-[11px] text-paper">{cell.geohash}</div>
                        <div className="mt-0.5 text-[10px] text-muted">
                          {cell.count} events · {topType.replaceAll("_", " ")}
                        </div>
                      </div>
                      <span
                        className="font-mono text-[10px] font-semibold"
                        style={{ color: severityColor(severity) }}
                      >
                        {severity.toFixed(1)}
                      </span>
                    </div>
                  );
                })}
            </div>
          ) : (
            <div className="p-4">
              <EmptyState
                title="No community events yet"
                message="Anonymized moments from synced rides will collect here."
              />
            </div>
          )}

          <div className="border-t border-line p-4">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <button
                type="button"
                onClick={() => void explainMap()}
                disabled={insightBusy || riskCells.length === 0}
                className="focus-ring inline-flex items-center gap-2 rounded-full border border-line bg-card-soft px-3.5 py-2 text-[11px] font-semibold text-paper transition hover:border-ink/20 disabled:opacity-50"
              >
                <Cloud size={13} className="text-accent" />
                {insightBusy
                  ? "Reading the map…"
                  : demoMode
                    ? "Preview local insight"
                    : "Explain with cloud AI"}
              </button>
              {insightSource && <SourceBadge source={insightSource} />}
            </div>
            {insightError && (
              <p className="mt-2 text-[11px] leading-relaxed text-muted">{insightError}</p>
            )}
            {insight && (
              <div className="mt-3 rounded-2xl bg-card-soft p-4">
                <div className="text-sm font-semibold text-paper">{insight.headline}</div>
                <p className="mt-1.5 text-xs leading-relaxed text-muted">{insight.summary}</p>
                <p className="mt-2 text-xs font-semibold text-accent">{insight.action}</p>
              </div>
            )}
            {hotspot && (
              <div className="mt-3 flex flex-wrap items-center justify-between gap-2 text-[11px] text-muted">
                <span className="inline-flex items-center gap-1.5">
                  <MapPin size={12} className="text-accent" />
                  Hottest cell <span className="font-mono text-paper">{hotspot.geohash}</span>
                </span>
                <span>Aggregate only — no rider route or identity.</span>
              </div>
            )}
          </div>
        </section>

        <aside className="space-y-4">
          <section className="surface p-5">
            <SectionHeader title="This week" />
            <div className="mt-4 grid grid-cols-3 gap-2">
              <WeekValue value={String(weekRides.length)} label="Rides" />
              <WeekValue value={formatDistance(weekDistance)} label="Distance" />
              <WeekValue value={weekRides.length ? String(averageScore) : "—"} label="Avg score" />
            </div>
            <div className="mt-4 flex items-center justify-between gap-2 border-t border-line pt-3">
              <span className="text-xs text-muted">
                {weekRides.length ? `Band ${scoreBand(averageScore)}` : "No rides yet"}
              </span>
              {latest && <SourceBadge source={latest.inferenceSource} />}
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
            className="focus-ring group surface flex items-center gap-3 p-4 transition hover:-translate-y-0.5"
          >
            <ShieldCheck size={22} className="shrink-0 text-teal" />
            <div className="min-w-0 flex-1">
              <div className="text-sm font-semibold text-paper">
                {latestCredential ? "Ridary Proof" : "Build your proof"}
              </div>
              <div className="mt-0.5 text-[11px] text-muted">
                {latestCredential
                  ? `Band ${scoreBand(latestCredential.score)} · score ${latestCredential.score}`
                  : "3 rides → signed credential"}
              </div>
            </div>
            <ArrowUpRight size={15} className="text-muted transition group-hover:text-accent" />
          </Link>
        </aside>
      </div>

      {recent.length > 0 && (
        <section className="space-y-3">
          <div className="flex items-end justify-between">
            <SectionHeader title="Recent rides" />
            <Link to="/rides" className="text-xs font-semibold text-accent">
              View all
            </Link>
          </div>
          <div className="grid gap-3 md:grid-cols-3">
            {recent.map((ride) => (
              <RideActivityCard key={ride.id} ride={ride} compact />
            ))}
          </div>
        </section>
      )}

      <section className="surface grid gap-6 p-6 md:grid-cols-2">
        <div>
          <div className="mono-label">Why hybrid</div>
          <h2 className="mt-2 text-2xl font-semibold tracking-tight text-paper">
            Private at the edge. Collective in the cloud.
          </h2>
          <p className="mt-2 max-w-md text-xs leading-relaxed text-muted">
            Ride snapshots and incident notes are private by default. Only derived
            moments and summaries can build the community map and signed proof.
          </p>
        </div>
        <div className="grid gap-3">
          <HybridRow
            icon={<Cpu size={16} />}
            title="On device"
            text="Snapshot, event explanation, incident interview, and evidence draft."
            tone="text-teal"
          />
          <HybridRow
            icon={<Cloud size={16} />}
            title="In cloud"
            text="Cross-rider risk map, weekly patterns, and the signed credential."
            tone="text-accent"
          />
          <HybridRow
            icon={<Activity size={16} />}
            title="Deterministic"
            text="Capture, event candidates, score, geohash, hash, and signature."
            tone="text-warning"
          />
        </div>
      </section>
    </div>
  );
}

function WeekValue({ value, label }: { value: string; label: string }) {
  return (
    <div>
      <div className="font-mono text-xl font-semibold text-paper">{value}</div>
      <div className="mt-1 text-[9px] font-medium uppercase tracking-[0.1em] text-muted">
        {label}
      </div>
    </div>
  );
}

function HybridRow({
  icon,
  title,
  text,
  tone
}: {
  icon: ReactNode;
  title: string;
  text: string;
  tone: string;
}) {
  return (
    <div className="flex gap-3 rounded-xl bg-card-soft p-3">
      <span className={`mt-0.5 ${tone}`}>{icon}</span>
      <div>
        <div className="text-xs font-semibold text-paper">{title}</div>
        <div className="mt-1 text-[11px] leading-relaxed text-muted">{text}</div>
      </div>
    </div>
  );
}

function RiskLegend() {
  return (
    <div className="flex items-center gap-3 text-[9px] font-medium uppercase tracking-[0.1em] text-muted">
      <span className="inline-flex items-center gap-1.5">
        <span className="h-2 w-2 rounded-full bg-teal" /> Low
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
