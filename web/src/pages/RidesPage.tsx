import {
  Cloud,
  Cpu,
  Gauge,
  Route as RouteIcon,
  TimerReset
} from "lucide-react";
import { useMemo, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { EmptyState, SectionHeader } from "../components/Banners";
import { EventCard } from "../components/EventCard";
import { RiskMap } from "../components/RiskMap";
import { ScoreRing } from "../components/ScoreRing";
import { SourceBadge } from "../components/SourceBadge";
import { StatCard } from "../components/StatCard";
import { useApp } from "../context/AppContext";
import { generateRideSnapshot, type SnapshotResult } from "../lib/ai";
import {
  formatDateTime,
  formatDistance,
  formatDuration,
  formatSpeed,
  scoreBand
} from "../lib/format";
import { localRideReview } from "../lib/localReview";
import type { InferenceSource, RideSnapshot } from "../types";

interface ReviewState {
  review: RideSnapshot | null;
  source: InferenceSource | null;
  raw: string | null;
  error: string | null;
  busy: boolean;
}

export default function RidesPage() {
  const { rides, demoMode } = useApp();
  const [searchParams, setSearchParams] = useSearchParams();
  const selectedId = searchParams.get("ride");
  const selected = useMemo(
    () => rides.find((ride) => ride.id === selectedId) ?? rides[0],
    [rides, selectedId]
  );

  const [reviews, setReviews] = useState<Record<string, ReviewState>>({});
  const currentReview = selected ? reviews[selected.id] : undefined;
  const review = currentReview?.review ?? null;
  const reviewSource = currentReview?.source ?? null;
  const reviewRaw = currentReview?.raw ?? null;
  const reviewError = currentReview?.error ?? null;
  const reviewBusy = currentReview?.busy ?? false;

  function updateReview(id: string, patch: Partial<ReviewState>) {
    setReviews((previous) => {
      const existing = previous[id] ?? {
        review: null,
        source: null,
        raw: null,
        error: null,
        busy: false
      };
      return { ...previous, [id]: { ...existing, ...patch } };
    });
  }

  async function runReview() {
    if (!selected) return;
    const ride = selected;
    updateReview(ride.id, { busy: true, error: null, raw: null });

    if (demoMode) {
      updateReview(ride.id, {
        review: localRideReview(ride),
        source: "deterministic"
      });
      updateReview(ride.id, { busy: false });
      return;
    }

    try {
      const result: SnapshotResult = await generateRideSnapshot(
        ride,
        ride.events
      );
      updateReview(ride.id, {
        review: result.snapshot ?? localRideReview(ride),
        source: result.source,
        raw: result.snapshot ? null : result.text,
        error: result.snapshot
          ? null
          : "The model returned text but not the expected structured shape. A local review is shown."
      });
    } catch (caught) {
      updateReview(ride.id, {
        review: localRideReview(ride),
        source: "fallback",
        error:
          caught instanceof Error
            ? caught.message
            : "On-device AI was unavailable; a local review is shown."
      });
    } finally {
      updateReview(ride.id, { busy: false });
    }
  }

  if (!selected) {
    return (
      <div className="space-y-6">
        <header>
          <div className="mono-label">Rides</div>
          <h1 className="mt-2 text-3xl font-semibold tracking-[-0.03em]">
            Your ride history
          </h1>
        </header>
        <EmptyState
          title="No rides yet"
          message="Once the iOS app records a ride and syncs its summary, it will appear here."
        />
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <header className="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div className="mono-label">Rides / Detail</div>
          <h1 className="mt-2 text-3xl font-semibold tracking-[-0.03em]">
            {formatDateTime(selected.startedAtMs)}
          </h1>
          <p className="mt-1 font-mono text-[10px] uppercase tracking-[0.16em] text-muted">
            {selected.mode} · {selected.events.length} flagged moments
          </p>
        </div>
        <div className="flex items-center gap-3">
          <SourceBadge source={selected.inferenceSource} />
          <ScoreRing score={selected.score} size={62} />
        </div>
      </header>

      <div className="grid gap-4 lg:grid-cols-[290px_1fr]">
        <aside className="surface max-h-[680px] overflow-y-auto p-2 scrollbar-thin">
          {rides.map((ride) => {
            const active = ride.id === selected.id;
            return (
              <button
                key={ride.id}
                type="button"
                onClick={() => setSearchParams({ ride: ride.id })}
                className={`focus-ring mb-1 w-full rounded-xl border px-3 py-3 text-left transition ${
                  active
                    ? "border-accent/30 bg-accent/8"
                    : "border-transparent hover:border-line hover:bg-white/5"
                }`}
              >
                <div className="flex items-center justify-between gap-2">
                  <span className="text-xs font-semibold text-paper">
                    {formatDateTime(ride.startedAtMs)}
                  </span>
                  <span className="font-mono text-[10px] text-muted">
                    {ride.score}
                  </span>
                </div>
                <div className="mt-1 flex items-center gap-2 font-mono text-[9px] uppercase tracking-[0.12em] text-muted">
                  <span>{ride.mode}</span>
                  <span>·</span>
                  <span>{formatDistance(ride.distanceM)}</span>
                </div>
              </button>
            );
          })}
        </aside>

        <div className="space-y-4">
          <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <StatCard
              label="Distance"
              value={formatDistance(selected.distanceM)}
              icon={RouteIcon}
            />
            <StatCard
              label="Duration"
              value={formatDuration(selected.durationS)}
              icon={TimerReset}
            />
            <StatCard
              label="Avg speed"
              value={formatSpeed(selected.avgSpeedKph)}
              icon={Gauge}
            />
            <StatCard
              label="Max speed"
              value={formatSpeed(selected.maxSpeedKph)}
              icon={Gauge}
              tone="text-accent"
            />
          </div>

          <section className="surface p-4">
            <SectionHeader
              eyebrow="Private route"
              title="Where the ride happened"
            />
            <div className="mt-3">
              <RiskMap
                riskCells={[]}
                ride={selected}
                height={300}
              />
            </div>
            <p className="mt-3 text-[10px] leading-relaxed text-muted">
              The route is shown only because this dashboard received an
              explicit route preview. Raw GPS samples never leave the phone.
            </p>
          </section>

          <section className="surface p-5">
            <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
              <SectionHeader
                eyebrow="Hybrid AI review"
                title="What the model noticed"
              />
              <button
                type="button"
                onClick={() => void runReview()}
                disabled={reviewBusy}
                className="focus-ring inline-flex items-center justify-center gap-2 rounded-xl bg-accent px-4 py-2.5 text-xs font-semibold text-ink transition hover:bg-accent/90 disabled:opacity-60"
              >
                {reviewBusy ? (
                  "Reviewing…"
                ) : (
                  <>
                    <Cpu size={14} />
                    {demoMode ? "Preview local review" : "Run on-device review"}
                  </>
                )}
              </button>
            </div>

            <div className="mt-3 flex items-center gap-2 font-mono text-[9px] uppercase tracking-[0.14em] text-muted">
              <Cpu size={11} className="text-teal" />
              Chrome Nano first
              <span className="text-muted/50">→</span>
              <Cloud size={11} className="text-accent" />
              Gemini fallback
            </div>

            {reviewError && (
              <p className="mt-3 rounded-xl border border-accent/25 bg-accent/8 px-3 py-2 text-[11px] leading-relaxed text-muted">
                {reviewError}
              </p>
            )}

            {review ? (
              <div className="mt-4 space-y-4">
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-sm font-semibold text-paper">
                    {review.headline}
                  </span>
                  {reviewSource && <SourceBadge source={reviewSource} />}
                </div>
                <p className="text-xs leading-relaxed text-muted">
                  {review.summary}
                </p>
                {review.riskMoments.length > 0 && (
                  <div className="space-y-2">
                    {review.riskMoments.map((moment) => (
                      <div
                        key={`${moment.type}-${moment.atSeconds}`}
                        className="rounded-xl border border-line bg-ink-soft p-3"
                      >
                        <div className="flex items-center justify-between gap-2">
                          <span className="text-xs font-semibold text-paper">
                            {moment.type}
                          </span>
                          <span className="font-mono text-[9px] text-muted">
                            +{moment.atSeconds}s
                          </span>
                        </div>
                        <p className="mt-1 text-[11px] leading-relaxed text-muted">
                          {moment.explanation}
                        </p>
                      </div>
                    ))}
                  </div>
                )}
                <div className="rounded-xl border border-teal/20 bg-teal/6 p-3">
                  <div className="mono-label text-teal">Coaching tip</div>
                  <p className="mt-1 text-xs leading-relaxed text-paper">
                    {review.coachingTip}
                  </p>
                </div>
                <p className="text-[10px] leading-relaxed text-muted">
                  {review.scoreRationale}
                </p>
                {reviewRaw && (
                  <p className="text-[10px] leading-relaxed text-muted">
                    Raw model output: {reviewRaw}
                  </p>
                )}
              </div>
            ) : (
              <p className="mt-4 text-xs leading-relaxed text-muted">
                Run a private review to turn the deterministic event
                candidates into a short, useful explanation. In demo mode this
                uses local rules; with Firebase it uses Chrome Nano when
                available.
              </p>
            )}
          </section>

          <section className="surface p-5">
            <SectionHeader
              eyebrow="Evidence"
              title="Flagged moments"
              action={
                <span className="font-mono text-[9px] uppercase tracking-[0.14em] text-muted">
                  band {scoreBand(selected.score)}
                </span>
              }
            />
            <div className="mt-4 space-y-2">
              {selected.events.length === 0 ? (
                <EmptyState
                  title="No flagged moments"
                  message="A clean ride still creates a private summary and a safety score."
                />
              ) : (
                selected.events.map((event) => (
                  <EventCard
                    key={event.id}
                    event={event}
                    rideStartMs={selected.startedAtMs}
                  />
                ))
              )}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}
