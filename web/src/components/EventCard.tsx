import { AlertTriangle, Activity, PauseCircle, Hand } from "lucide-react";
import { EVENT_LABELS, type RideEvent } from "../types";
import { formatDateTime } from "../lib/format";
import { SourceBadge } from "./SourceBadge";

function EventTypeIcon({ type }: { type: RideEvent["type"] }) {
  switch (type) {
    case "impact":
    case "crash_candidate":
      return <AlertTriangle size={14} strokeWidth={1.9} />;
    case "long_stop":
      return <PauseCircle size={14} strokeWidth={1.9} />;
    case "manual":
      return <Hand size={14} strokeWidth={1.9} />;
    default:
      return <Activity size={14} strokeWidth={1.9} />;
  }
}

export function EventCard({
  event,
  rideStartMs
}: {
  event: RideEvent;
  rideStartMs?: number;
}) {
  const tone =
    event.severity >= 4
      ? "text-danger border-danger/25 bg-danger/8"
      : event.severity >= 3
        ? "text-warning border-warning/25 bg-warning/8"
        : "text-teal border-teal/25 bg-teal/8";
  const atSeconds =
    rideStartMs !== undefined
      ? Math.max(0, Math.round((event.occurredAtMs - rideStartMs) / 1000))
      : null;

  return (
    <div className="flex gap-3 rounded-xl border border-line bg-ink-soft p-3">
      <div
        className={`mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border ${tone}`}
      >
        <EventTypeIcon type={event.type} />
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs font-semibold text-paper">
            {EVENT_LABELS[event.type]}
          </span>
          <span className="font-mono text-[9px] uppercase tracking-[0.12em] text-muted">
            severity {event.severity}
          </span>
          {atSeconds !== null && (
            <span className="font-mono text-[9px] text-muted">
              +{atSeconds}s
            </span>
          )}
          <span className="ml-auto">
            <SourceBadge source={event.source} />
          </span>
        </div>
        <p className="mt-1.5 text-[11px] leading-relaxed text-muted">
          {event.summary}
        </p>
        <div className="mt-1 font-mono text-[9px] text-muted/70">
          {formatDateTime(event.occurredAtMs)} · {event.geohash}
        </div>
      </div>
    </div>
  );
}
