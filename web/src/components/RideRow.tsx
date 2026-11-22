import {
  ArrowUpRight,
  Bike,
  CarFront,
  Footprints,
  TrainFront
} from "lucide-react";
import { Link } from "react-router-dom";
import {
  formatDateTime,
  formatDistance,
  formatDuration,
  scoreBand
} from "../lib/format";
import type { Ride, RideMode } from "../types";
import { ScoreRing } from "./ScoreRing";
import { SourceBadge } from "./SourceBadge";

function ModeIcon({ mode }: { mode: RideMode }) {
  switch (mode) {
    case "motorcycle":
    case "bicycle":
      return <Bike size={17} strokeWidth={1.8} />;
    case "car":
      return <CarFront size={17} strokeWidth={1.8} />;
    case "running":
      return <Footprints size={17} strokeWidth={1.8} />;
    case "transit":
      return <TrainFront size={17} strokeWidth={1.8} />;
  }
}

export function RideRow({ ride }: { ride: Ride }) {
  return (
    <Link
      to={`/rides?ride=${encodeURIComponent(ride.id)}`}
      className="focus-ring group flex items-center gap-4 rounded-2xl border border-line bg-card/60 px-4 py-3 transition hover:border-ink/20 hover:bg-card"
    >
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-line bg-card-soft text-accent">
        <ModeIcon mode={ride.mode} />
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-2">
          <span className="truncate text-sm font-semibold text-paper">
            {formatDateTime(ride.startedAtMs)}
          </span>
          <span className="hidden font-mono text-[10px] uppercase tracking-[0.14em] text-muted sm:inline">
            {ride.mode}
          </span>
        </div>
        <div className="mt-1 flex flex-wrap items-center gap-x-2 gap-y-1 text-[11px] text-muted">
          <span>{formatDistance(ride.distanceM)}</span>
          <span>·</span>
          <span>{formatDuration(ride.durationS)}</span>
          <span>·</span>
          <span>
            {ride.events.length} moment{ride.events.length === 1 ? "" : "s"}
          </span>
        </div>
      </div>
      <div className="hidden sm:block">
        <SourceBadge source={ride.inferenceSource} />
      </div>
      <div className="flex items-center gap-2">
        <div className="text-right">
          <div className="font-mono text-[10px] uppercase tracking-[0.16em] text-muted">
            band {scoreBand(ride.score)}
          </div>
          <div className="font-mono text-xs font-semibold text-paper">
            {ride.score}/100
          </div>
        </div>
        <ScoreRing score={ride.score} size={44} />
      </div>
      <ArrowUpRight
        size={15}
        className="shrink-0 text-muted transition group-hover:text-accent"
      />
    </Link>
  );
}
