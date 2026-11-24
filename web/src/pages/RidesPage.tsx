import {
  CheckCircle2,
  Cpu,
  Flag,
  ShieldCheck
} from "lucide-react";
import { useMemo, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { EmptyState } from "../components/Banners";
import { EventCard } from "../components/EventCard";
import { RiskMap } from "../components/RiskMap";
import { RouteArt } from "../components/RouteArt";
import { SourceBadge } from "../components/SourceBadge";
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
        source: "deterministic",
        busy: false
      });
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
      <div className="space-y-5">
        <header>
          <div className="mono-label">Rides</div>
          <h1 className="mt-1.5 text-3xl font-semibold tracking-[-0.03em]">
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

  const band = scoreBand(selected.score);
  const headline = review?.headline ?? "Ride captured";
  const summaryText = review?.summary ?? selected.summary;

  return (
    <div className="space-y-5">
      <header className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <div className="mono-label">Rides</div>
          <h1 className="mt-1 text-3xl font-semibold tracking-[-0.03em] text-paper">
            Ride summaries
          </h1>
        </div>
        <div className="text-[13px] text-muted">
          {rides.length} {rides.length === 1 ? "session" : "sessions"} synced
        </div>
      </header>

      <div className="grid gap-5 lg:grid-cols-[310px_1fr] lg:items-start">
        <aside className="surface max-h-[720px] overflow-y-auto p-2.5 scrollbar-thin">
          <div className="divide-y divide-line/65">
            {rides.map((ride) => {
              const active = ride.id === selected.id;
              return (
                <button
                  key={ride.id}
                  type="button"
                  onClick={() => setSearchParams({ ride: ride.id })}
                  className={`focus-ring w-full rounded-2xl px-3 py-3 text-left transition ${
                    active
                      ? "bg-sky-soft/65"
                      : "hover:bg-canvas-soft"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <RouteArt
                      route={ride.routePreview}
                      className="h-12 w-16 shrink-0 rounded-xl border border-line/70"
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
                      <div className="mt-0.5 text-[12px] capitalize text-muted">
                        {ride.mode} · {formatDistance(ride.distanceM)} ·{" "}
                        {formatDuration(ride.durationS)}
                      </div>
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        </aside>

        <article className="surface overflow-hidden">
          <div className="relative">
            <RiskMap riskCells={[]} ride={selected} height={320} />
          </div>

          <div className="relative -mt-6 rounded-t-[1.625rem] bg-white pt-7 shadow-[0_-6px_20px_rgba(23,23,23,0.04)]">
            <div className="mx-auto max-w-xl px-6 pb-6 text-center">
              <h2 className="text-[23px] font-semibold tracking-[-0.025em] text-paper">
                {headline}
              </h2>
              <p className="mt-2.5 text-[15px] leading-relaxed text-muted">
                {summaryText}
              </p>
              <div className="mt-3.5 inline-flex flex-wrap items-center justify-center gap-2 text-[13px]">
                <span className="inline-flex items-center gap-1.5 font-medium text-paper">
                  <ShieldCheck size={14} className="text-sky" />
                  {selected.score} Safety · {band} Band
                </span>
                <span className="text-muted">
                  · {formatDateTime(selected.startedAtMs)}
                </span>
                <SourceBadge source={reviewSource ?? selected.inferenceSource} />
              </div>
            </div>

            <div className="mx-6 h-px bg-line/75" />

            {review && (
              <>
                <div className="flex items-center gap-3.5 px-6 py-5">
                  <div className="ios-icon-circle h-10 w-10">
                    <ShieldCheck size={18} strokeWidth={1.9} />
                  </div>
                  <div>
                    <div className="text-[15px] font-medium text-paper">
                      {review.coachingTip}
                    </div>
                    <div className="mt-0.5 text-[13px] text-muted">
                      {review.scoreRationale}
                    </div>
                  </div>
                </div>
                <div className="mx-6 h-px bg-line/75" />
              </>
            )}

            <div className="grid grid-cols-3 divide-x divide-line/75 items-center px-6 py-5 text-center">
              <CenteredMetric
                value={String(selected.score)}
                label={`Safety · ${band} Band`}
                accent
              />
              <CenteredMetric
                value={formatDistance(selected.distanceM)}
                label={`${formatDuration(selected.durationS)} duration`}
              />
              <CenteredMetric
                value={formatSpeed(selected.avgSpeedKph)}
                label={`Avg · ${formatSpeed(selected.maxSpeedKph)} max`}
              />
            </div>

            <div className="mx-6 h-px bg-line/75" />

            <div className="px-6 py-6">
              <div className="flex items-baseline justify-between gap-4">
                <h3 className="text-[17px] font-semibold tracking-[-0.015em] text-paper">
                  Ride timeline
                </h3>
                <span className="text-[13px] text-muted">
                  {selected.events.length === 0
                    ? "Smooth ride"
                    : `${selected.events.length} ${
                        selected.events.length === 1 ? "moment" : "moments"
                      }`}
                </span>
              </div>

              <div className="mt-4 divide-y divide-line/65">
                <div className="flex items-start gap-3.5 py-3.5 first:pt-1">
                  <div className="ios-icon-circle">
                    <CheckCircle2 size={15} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-[15px] font-medium text-paper">
                        Ride started
                      </span>
                      <span className="font-mono text-[12px] text-subtle">
                        0:00
                      </span>
                    </div>
                    <div className="mt-0.5 text-[13px] capitalize text-muted">
                      {selected.mode} session · {formatDateTime(selected.startedAtMs)}
                    </div>
                  </div>
                </div>

                {selected.events.length === 0 ? (
                  <div className="flex items-start gap-3.5 py-3.5">
                    <div className="ios-icon-circle">
                      <ShieldCheck size={15} />
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="text-[15px] font-medium text-paper">
                        Steady pace maintained
                      </div>
                      <div className="mt-0.5 text-[13px] text-muted">
                        No hard braking, sharp turns, or impact spikes detected.
                      </div>
                    </div>
                  </div>
                ) : (
                  selected.events.map((event, index) => (
                    <EventCard
                      key={event.id}
                      event={event}
                      rideStartMs={selected.startedAtMs}
                      index={index + 1}
                    />
                  ))
                )}

                <div className="flex items-start gap-3.5 py-3.5 last:pb-1">
                  <div className="flex h-8.5 w-8.5 shrink-0 items-center justify-center rounded-full bg-canvas-soft text-muted">
                    <Flag size={14} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-[15px] font-medium text-paper">
                        Ride completed
                      </span>
                      <span className="font-mono text-[12px] text-subtle">
                        {formatDuration(selected.durationS)}
                      </span>
                    </div>
                    <div className="mt-0.5 text-[13px] text-muted">
                      {formatDistance(selected.distanceM)} recorded · Safety score{" "}
                      {selected.score}/100
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {reviewError && (
              <div className="px-6 pb-4">
                <p className="rounded-2xl bg-sky-soft/60 px-4 py-3 text-[12px] text-muted">
                  {reviewError}
                </p>
              </div>
            )}

            {reviewRaw && (
              <div className="px-6 pb-4">
                <p className="text-[12px] text-muted">
                  Raw model output: {reviewRaw}
                </p>
              </div>
            )}

            <div className="border-t border-line/75 px-6 py-4">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <div className="text-[15px] font-semibold text-paper">
                    {selected.score}{" "}
                    <span className="text-[13px] font-normal text-muted">
                      / 100 · {band} Band
                    </span>
                  </div>
                  <div className="text-[12px] text-subtle">
                    {formatDistance(selected.distanceM)} ·{" "}
                    {formatDuration(selected.durationS)} · Chrome Nano first
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => void runReview()}
                  disabled={reviewBusy}
                  className="btn-glass-sky focus-ring px-4 py-2.5 text-[13px] disabled:opacity-60"
                >
                  <Cpu size={14} />
                  {reviewBusy
                    ? "Reviewing…"
                    : demoMode
                      ? "Preview local review"
                      : "Run on-device review"}
                </button>
              </div>
            </div>
          </div>
        </article>
      </div>
    </div>
  );
}

function CenteredMetric({
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
