import { Play, Sparkles } from "lucide-react";
import { demoRides } from "../../data/demo";
import { formatDistance, formatDuration } from "../../lib/format";
import { RouteArt } from "../RouteArt";

const rides = demoRides.slice(0, 2);

export function PhoneHomePreview() {
  return (
    <div className="flex h-full flex-col bg-white">
      <div className="relative h-[55%] shrink-0 overflow-hidden bg-sky-soft/35">
        <RouteArt
          route={demoRides[0]!.routePreview}
          className="absolute inset-0 h-full w-full"
        />
        <div className="absolute left-1/2 top-1/2 flex h-8 w-8 -translate-x-1/2 -translate-y-1/2 items-center justify-center rounded-full bg-sky/15">
          <span className="h-3.5 w-3.5 rounded-full border-[3px] border-white bg-sky shadow-sm" />
        </div>
        <div className="absolute bottom-3 right-2.5 inline-flex items-center gap-1 rounded-full bg-sky px-2.5 py-1 text-[7px] font-semibold text-white shadow-sm">
          <Play size={7} fill="currentColor" />
          Start
        </div>
      </div>

      <div className="relative -mt-4 flex min-h-0 flex-1 flex-col rounded-t-[1.7rem] bg-white px-3 pb-3 pt-2 shadow-[0_-8px_20px_rgba(23,23,23,0.06)]">
        <div className="mx-auto h-1 w-8 shrink-0 rounded-full bg-line" />

        <div className="mt-2.5 flex shrink-0 items-center gap-1.5">
          <div className="flex h-7 flex-1 items-center gap-1.5 rounded-full bg-canvas-soft px-2.5 text-[8px] font-medium text-muted">
            <Sparkles size={9} className="text-sky" />
            Ask Ridary
          </div>
          <div className="flex h-7 w-7 items-center justify-center rounded-full bg-sky-soft text-[8px] font-semibold text-sky-deep">
            R
          </div>
        </div>

        <div className="mb-1.5 mt-3 flex shrink-0 items-baseline justify-between">
          <span className="text-[10px] font-semibold text-paper">Rides</span>
          <span className="text-[6px] font-medium uppercase tracking-[0.08em] text-subtle">
            {demoRides.length} total
          </span>
        </div>

        <div className="min-h-0 flex-1 divide-y divide-line/70 overflow-hidden">
          {rides.map((ride) => (
            <div key={ride.id} className="flex items-center gap-2 py-2 first:pt-1">
              <RouteArt
                route={ride.routePreview}
                className="h-7 w-9 shrink-0 rounded-md border border-line/60"
              />
              <div className="min-w-0 flex-1">
                <div className="truncate text-[7px] font-medium text-paper">
                  {ride.mode} · {formatDistance(ride.distanceM)}
                </div>
                <div className="mt-0.5 truncate text-[6px] text-muted">
                  {formatDuration(ride.durationS)} · {ride.score} score
                </div>
              </div>
              <div className="text-[9px] font-semibold text-sky-deep">{ride.score}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
