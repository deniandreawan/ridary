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
import { SourceBadge } from "./SourceBadge";

function ModeIcon({ mode }: { mode: RideMode }) {
  switch (mode) {
    case "motorcycle":
    case "bicycle":
      return <Bike size={15} strokeWidth={1.9} />;
    case "car":
      return <CarFront size={15} strokeWidth={1.9} />;
    case "running":
      return <Footprints size={15} strokeWidth={1.9} />;
    case "transit":
      return <TrainFront size={15} strokeWidth={1.9} />;
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
      className="focus-ring group surface block overflow-hidden transition duration-200 ease-out hover:-translate-y-0.5 hover:shadow-[0_14px_34px_rgba(23,23,23,0.07)]"
    >
      <div className={`relative overflow-hidden bg-sky-soft/40 ${compact ? "h-28" : "h-36"}`}>
        <RouteArt
          route={ride.routePreview}
          className="absolute inset-0 h-full w-full transition duration-500 ease-[cubic-bezier(0.16,1,0.3,1)] group-hover:scale-[1.02]"
        />
        <div className="absolute left-3 top-3">
          <SourceBadge source={ride.inferenceSource} />
        </div>
        <div className="absolute right-3 top-3 rounded-full bg-white/92 px-2.5 py-1 text-[12px] font-semibold text-sky-deep shadow-sm backdrop-blur-md">
          {ride.score} · {scoreBand(ride.score)}
        </div>
      </div>

      <div className="p-4">
        <div className="flex items-start justify-between gap-3">
          <div className="flex min-w-0 items-center gap-3">
            <span className="ios-icon-circle">
              <ModeIcon mode={ride.mode} />
            </span>
            <div className="min-w-0">
              <div className="truncate text-[15px] font-medium tracking-[-0.01em] text-paper">
                {formatDateTime(ride.startedAtMs)}
              </div>
              <div className="mt-0.5 text-[13px] capitalize text-muted">
                {ride.mode} · {formatDistance(ride.distanceM)} · {formatDuration(ride.durationS)}
              </div>
            </div>
          </div>
          <ArrowUpRight
            size={16}
            className="mt-1 shrink-0 text-subtle transition group-hover:text-sky-deep"
          />
        </div>
      </div>
    </Link>
  );
}
