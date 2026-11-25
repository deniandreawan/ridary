import {
  Activity,
  ArrowUpRight,
  Cloud,
  Cpu,
  MapPin,
  RefreshCw,
  ShieldCheck
} from "lucide-react";
import { motion, useReducedMotion } from "motion/react";
import { useState } from "react";
import { Link } from "react-router-dom";
import { EmptyState } from "../components/Banners";
import { RiskMap } from "../components/RiskMap";
import { RouteArt } from "../components/RouteArt";
import { SourceBadge } from "../components/SourceBadge";
import { useApp } from "../context/AppContext";
import {
  formatDateTime,
  formatDistance,
  formatDuration,
  scoreBand
} from "../lib/format";
import { severityColor, topRiskCell } from "../lib/risk";

type LayerMode = "all" | "risk" | "route";

export default function OverviewPage() {
  const { rides, riskCells, credentials, loading, refresh } = useApp();
  const [layers, setLayers] = useState<LayerMode>("all");
  const reduce = useReducedMotion();

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
  const topCells = [...riskCells]
    .sort((a, b) => b.severitySum / b.count - a.severitySum / a.count)
    .slice(0, 4);
  const recentRides = rides.slice(0, 3);

  const panelMotion = reduce
    ? {}
    : {
        initial: { opacity: 0, y: 12 },
        animate: { opacity: 1, y: 0 },
        transition: { duration: 0.45, ease: [0.16, 1, 0.3, 1] as const }
      };

  return (
    <div className="space-y-5">
      <header className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div className="mono-label">Overview</div>
          <h1 className="mt-1.5 text-3xl font-semibold tracking-[-0.035em] text-paper sm:text-[34px]">
            Your ride, on record.
          </h1>
          <p className="mt-1.5 max-w-xl text-[15px] leading-relaxed text-muted">
            A private record of what happened on this iPhone, paired with the
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

      <section className="surface overflow-hidden">
        <div className="relative">
          <RiskMap
            riskCells={riskCells}
            ride={latest}
            heightClassName="h-[360px] sm:h-[520px]"
            showRisk={layers !== "route"}
            showRoute={layers !== "risk"}
          />

          <motion.div
            {...panelMotion}
            className="pointer-events-none absolute inset-x-4 top-4 flex items-start justify-between gap-3 sm:inset-x-5"
          >
            <div className="pointer-events-auto hidden w-[58%] max-w-[286px] rounded-2xl border border-white/80 bg-white/86 p-4 shadow-[0_12px_32px_rgba(23,23,23,0.08)] backdrop-blur-xl sm:block">
              <div className="text-[11px] font-medium text-sky-deep">This week</div>
              <div className="mt-1 text-[28px] font-semibold tracking-[-0.035em] text-paper">
                {formatDistance(weekDistance)}
              </div>
              <div className="mt-0.5 text-[12px] text-muted">
                {weekRides.length} {weekRides.length === 1 ? "ride" : "rides"} ·{" "}
                {weekRides.length ? `${averageScore} avg safety` : "no rides yet"}
              </div>
              <div className="mt-3 flex items-center justify-between border-t border-line/70 pt-2.5">
                <span className="text-[11px] font-medium text-paper">
                  {weekRides.length ? `${scoreBand(averageScore)} Band` : "—"}
                </span>
                {latest && <SourceBadge source={latest.inferenceSource} />}
              </div>
            </div>

            <div className="pointer-events-auto flex items-center gap-0.5 rounded-full border border-white/80 bg-white/86 p-1 shadow-[0_8px_24px_rgba(23,23,23,0.07)] backdrop-blur-xl">
              {(["all", "risk", "route"] as LayerMode[]).map((mode) => (
                <button
                  key={mode}
                  type="button"
                  onClick={() => setLayers(mode)}
                  className={`focus-ring rounded-full px-3 py-1.5 text-[11px] font-medium capitalize transition ${
                    layers === mode
                      ? "bg-sky-soft text-sky-deep"
                      : "text-muted hover:text-paper"
                  }`}
                  aria-pressed={layers === mode}
                >
                  {mode}
                </button>
              ))}
            </div>
          </motion.div>

          {latest && (
            <motion.div
              {...panelMotion}
              transition={
                reduce
                  ? undefined
                  : { duration: 0.45, delay: 0.08, ease: [0.16, 1, 0.3, 1] }
              }
              className="pointer-events-auto absolute bottom-4 left-4 hidden max-w-[260px] items-center gap-3 rounded-2xl border border-white/80 bg-white/86 p-3 shadow-[0_12px_32px_rgba(23,23,23,0.08)] backdrop-blur-xl sm:flex"
            >
              <RouteArt
                route={latest.routePreview}
                className="h-11 w-14 shrink-0 rounded-xl border border-line/60"
              />
              <div className="min-w-0">
                <div className="truncate text-[12px] font-medium text-paper">
                  Latest ride
                </div>
                <div className="mt-0.5 text-[11px] text-muted">
                  {formatDistance(latest.distanceM)} · {formatDuration(latest.durationS)}
                </div>
                <div className="mt-0.5 text-[11px] text-sky-deep">
                  {latest.score} · {scoreBand(latest.score)} Band
                </div>
              </div>
              <Link
                to={`/app/rides?ride=${encodeURIComponent(latest.id)}`}
                className="focus-ring ml-1 shrink-0 rounded-full p-1 text-muted hover:text-paper"
                aria-label="Open latest ride"
              >
                <ArrowUpRight size={14} />
              </Link>
            </motion.div>
          )}

        </div>

        <div className="border-t border-line/70 px-5 py-4 sm:hidden">
          <div className="flex items-end justify-between gap-4">
            <div>
              <div className="text-[11px] font-medium text-sky-deep">This week</div>
              <div className="mt-0.5 text-[22px] font-semibold tracking-[-0.025em] text-paper">
                {formatDistance(weekDistance)}
              </div>
              <div className="text-[12px] text-muted">
                {weekRides.length} {weekRides.length === 1 ? "ride" : "rides"} ·{" "}
                {weekRides.length ? `${averageScore} avg safety` : "no rides yet"}
              </div>
            </div>
            {latest && <SourceBadge source={latest.inferenceSource} />}
          </div>
        </div>

        <div className="flex flex-wrap items-center justify-between gap-3 border-t border-line/70 px-5 py-3.5">
          <div className="flex items-center gap-2.5 text-[12px] text-muted">
            <RiskLegend />
            {hotspot && (
              <>
                <span className="hidden h-3 w-px bg-line sm:block" />
                <span className="hidden sm:inline">
                  Top cell <span className="font-mono text-paper">{hotspot.geohash}</span>
                </span>
              </>
            )}
          </div>
          <span className="text-[11px] text-subtle">
            {communityEvents} anonymized moments · aggregate cells only · no raw GPS
          </span>
        </div>
      </section>

      <div className="grid gap-5 lg:grid-cols-[1.35fr_0.65fr] lg:items-start">
        <section className="surface p-5">
          <div className="flex items-baseline justify-between gap-3">
            <div>
              <div className="mono-label">Ride log</div>
              <h2 className="mt-1 text-[17px] font-semibold tracking-[-0.015em] text-paper">
                Recent sessions
              </h2>
            </div>
            <Link
              to="/app/rides"
              className="focus-ring text-[12px] font-medium text-sky-deep hover:underline"
            >
              View all
            </Link>
          </div>

          {recentRides.length === 0 ? (
            <div className="mt-4">
              <EmptyState
                title="No rides yet"
                message="Start a session on the iOS app and its summary will land here."
              />
            </div>
          ) : (
            <div className="mt-4 divide-y divide-line/70">
              {recentRides.map((ride) => (
                <Link
                  key={ride.id}
                  to={`/app/rides?ride=${encodeURIComponent(ride.id)}`}
                  className="focus-ring group flex items-center gap-3.5 py-3 transition first:pt-0 last:pb-0"
                >
                  <RouteArt
                    route={ride.routePreview}
                    className="h-12 w-16 shrink-0 rounded-xl border border-line/60"
                  />
                  <div className="min-w-0 flex-1">
                    <div className="flex items-baseline justify-between gap-2">
                      <span className="truncate text-[14px] font-medium text-paper">
                        {formatDateTime(ride.startedAtMs)}
                      </span>
                      <span className="text-[15px] font-semibold text-sky-deep">
                        {ride.score}
                      </span>
                    </div>
                    <div className="mt-0.5 flex items-center gap-2 text-[12px] capitalize text-muted">
                      <span>{ride.mode}</span>
                      <span>·</span>
                      <span>{formatDistance(ride.distanceM)}</span>
                      <span>·</span>
                      <span>{formatDuration(ride.durationS)}</span>
                    </div>
                  </div>
                  <ArrowUpRight
                    size={15}
                    className="shrink-0 text-subtle transition group-hover:text-sky-deep"
                  />
                </Link>
              ))}
            </div>
          )}
        </section>

        <div className="space-y-5">
          <Link
            to="/app/credential"
            className="focus-ring group block overflow-hidden rounded-[1.625rem] border border-sky/15 bg-sky-soft/55 p-5 transition duration-200 hover:-translate-y-0.5"
          >
            <div className="flex items-start justify-between gap-3">
              <div className="ios-icon-circle bg-white">
                <ShieldCheck size={18} />
              </div>
              <ArrowUpRight
                size={16}
                className="text-sky-deep/60 transition group-hover:text-sky-deep"
              />
            </div>
            <div className="mt-4 text-[13px] font-medium text-sky-deep">
              Ridary Proof
            </div>
            <div className="mt-1 text-[24px] font-semibold tracking-[-0.025em] text-paper">
              {latestCredential
                ? `${scoreBand(latestCredential.score)} Band`
                : "Build your proof"}
            </div>
            <div className="mt-1 text-[12px] leading-relaxed text-muted">
              {latestCredential
                ? `${latestCredential.score}/100 · ${latestCredential.rideCount} rides · Ed25519 signed`
                : "Record 3 rides, then issue a signed credential."}
            </div>
          </Link>

          {latest && (
            <section className="surface p-5">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <div className="mono-label">Latest snapshot</div>
                  <h2 className="mt-1 text-[16px] font-semibold tracking-[-0.015em] text-paper">
                    What the model noticed
                  </h2>
                </div>
                <SourceBadge source={latest.inferenceSource} />
              </div>
              <p className="mt-3 text-[13px] leading-relaxed text-muted">
                {latest.summary}
              </p>
              <Link
                to={`/app/rides?ride=${encodeURIComponent(latest.id)}`}
                className="focus-ring mt-3 inline-flex items-center gap-1 text-[12px] font-medium text-sky-deep hover:underline"
              >
                Open ride
                <ArrowUpRight size={13} />
              </Link>
            </section>
          )}
        </div>
      </div>

      <div className="grid gap-8 border-t border-line/70 pt-7 lg:grid-cols-[1.2fr_0.8fr]">
        <section>
          <div className="flex items-baseline justify-between gap-3">
            <div>
              <div className="mono-label">Community</div>
              <h2 className="mt-1 text-[17px] font-semibold tracking-[-0.015em] text-paper">
                Road risk cells
              </h2>
            </div>
            <span className="text-[12px] text-muted">
              {riskCells.length} cells
            </span>
          </div>

          {topCells.length === 0 ? (
            <div className="mt-4">
              <EmptyState
                title="No community events yet"
                message="Anonymized moments from synced rides will collect here."
              />
            </div>
          ) : (
            <div className="mt-3 divide-y divide-line/70">
              {topCells.map((cell) => {
                const topType =
                  Object.entries(cell.topTypes).sort((a, b) => b[1] - a[1])[0]?.[0] ??
                  "event";
                const severity = cell.count > 0 ? cell.severitySum / cell.count : 0;
                return (
                  <div key={cell.id} className="flex items-center justify-between gap-3 py-3.5 first:pt-1 last:pb-0">
                    <div className="flex items-center gap-3">
                      <div className="ios-icon-circle h-8 w-8">
                        <MapPin size={14} />
                      </div>
                      <div>
                        <div className="text-[14px] font-medium capitalize text-paper">
                          {topType.replaceAll("_", " ")}
                        </div>
                        <div className="text-[12px] text-muted">
                          <span className="font-mono">{cell.geohash}</span> ·{" "}
                          {cell.count} events
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
          )}
        </section>

        <section>
          <div className="mono-label">Hybrid inference</div>
          <h2 className="mt-1 text-[17px] font-semibold tracking-[-0.015em] text-paper">
            Where the work happens
          </h2>
          <div className="mt-3 divide-y divide-line/70">
            <HybridRow
              icon={<Cpu size={15} />}
              title="On device"
              text="Ride snapshots, Ask Ridary, and sensitive incident notes on Apple Foundation Models or Chrome Nano."
              badge="Private"
            />
            <HybridRow
              icon={<Cloud size={15} />}
              title="In cloud"
              text="Cross-rider risk cells, weekly patterns, and the signed credential narrative."
              badge="Derived"
            />
            <HybridRow
              icon={<Activity size={15} />}
              title="Rules"
              text="Deterministic capture, event thresholds, score, hash, and offline fallback."
              badge="Fallback"
            />
          </div>
        </section>
      </div>
    </div>
  );
}

function RiskLegend() {
  return (
    <div className="flex items-center gap-3 text-[11px] text-muted">
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

function HybridRow({
  icon,
  title,
  text,
  badge
}: {
  icon: React.ReactNode;
  title: string;
  text: string;
  badge: string;
}) {
  return (
    <div className="flex items-start gap-3 py-3.5 first:pt-1 last:pb-0">
      <div className="ios-icon-circle mt-0.5 h-8 w-8">{icon}</div>
      <div className="flex-1">
        <div className="flex items-center gap-2">
          <div className="text-[14px] font-medium text-paper">{title}</div>
          <span className="rounded-full bg-canvas-soft px-2 py-0.5 text-[10px] font-medium text-muted">
            {badge}
          </span>
        </div>
        <div className="mt-0.5 text-[12px] leading-relaxed text-muted">
          {text}
        </div>
      </div>
    </div>
  );
}
