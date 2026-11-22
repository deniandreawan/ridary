import { ArrowUpRight, Bike, CarFront, Footprints, TrainFront } from "lucide-react";
import { Link } from "react-router-dom";
import {
  formatDateTime,
  formatDistance,
  formatDuration,
  scoreBand
} from "../lib/format";
import type { Ride, RideMode } from "../types";
import { RouteArt } from "./RouteArt";
import { ScoreRing } from "./ScoreRing";
import { SourceBadge } from "./SourceBadge";

function ModeIcon({ mode }: { mode: RideMode }) {
  switch (mode) {
    case "motorcycle":
    case "bicycle":
      return <Bike size={15} strokeWidth={2} />;
    case "car":
      return <CarFront size={15} strokeWidth={2} />;
    case "running":
      return <Footprints size={15} strokeWidth={2} />;
    case "transit":
      return <TrainFront size={15} strokeWidth={2} />;
  }
}

export function RideActivityCard({
  ride,
  compact = false
}: {
  ride: Ride;
  compact?: boolean;
}) {
  return (
    <Link
      to={`/rides?ride=${encodeURIComponent(ride.id)}`}
      className="focus-ring group block overflow-hidden rounded-[1.375rem] border border-line bg-card transition duration-300 ease-[cubic-bezier(0.16,1,0.3,1)] hover:-translate-y-0.5 hover:shadow-[0_20px_50px_rgba(11,17,20,0.10)]"
    >
      <div className={`relative overflow-hidden bg-cyan-soft/30 ${compact ? "h-28" : "h-40"}`}>
        <RouteArt
          route={ride.routePreview}
          className="absolute inset-0 h-full w-full transition duration-500 ease-[cubic-bezier(0.16,1,0.3,1)] group-hover:scale-[1.03]"
        />
        <div className="absolute left-3 top-3">
          <SourceBadge source={ride.inferenceSource} />
        </div>
        <div className="absolute right-3 top-3">
          <ScoreRing score={ride.score} size={compact ? 42 : 52} />
        </div>
      </div>

      <div className="p-4">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <div className="flex items-center gap-2">
              <span className="text-muted">
                <ModeIcon mode={ride.mode} />
              </span>
              <span className="truncate text-sm font-semibold tracking-tight text-paper">
                {formatDateTime(ride.startedAtMs)}
              </span>
            </div>
            <div className="mt-1 text-[11px] capitalize text-muted">
              {ride.mode} · band {scoreBand(ride.score)}
            </div>
          </div>
          <ArrowUpRight
            size={16}
            className="shrink-0 text-muted transition group-hover:text-accent"
          />
        </div>

        <div className="mt-4 grid grid-cols-3 gap-2 border-t border-line pt-3">
          <Metric value={formatDistance(ride.distanceM)} label="Distance" />
          <Metric value={formatDuration(ride.durationS)} label="Time" />
          <Metric value={String(ride.events.length)} label="Moments" />
        </div>
      </div>
    </Link>
  );
}

function Metric({ value, label }: { value: string; label: string }) {
  return (
    <div>
      <div className="font-mono text-[12px] font-semibold text-paper">{value}</div>
      <div className="mt-0.5 text-[9px] font-medium uppercase tracking-[0.1em] text-muted">
        {label}
      </div>
    </div>
  );
}
