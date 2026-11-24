import { Activity, AlertTriangle, Hand, PauseCircle } from "lucide-react";
import { formatDateTime } from "../lib/format";
import { EVENT_LABELS, type RideEvent } from "../types";
import { SourceBadge } from "./SourceBadge";

function EventTypeIcon({ type }: { type: RideEvent["type"] }) {
  switch (type) {
    case "impact":
    case "crash_candidate":
      return <AlertTriangle size={15} strokeWidth={1.9} />;
    case "long_stop":
      return <PauseCircle size={15} strokeWidth={1.9} />;
    case "manual":
      return <Hand size={15} strokeWidth={1.9} />;
    default:
      return <Activity size={15} strokeWidth={1.9} />;
  }
}

export function EventCard({
  event,
  rideStartMs,
  index
}: {
  event: RideEvent;
  rideStartMs?: number;
  index?: number;
}) {
  const isSevere = event.severity >= 4;
  const isModerate = event.severity >= 3;
  const badgeStyle = isSevere
    ? "bg-danger/12 text-danger"
    : isModerate
      ? "bg-warning/14 text-warning"
      : "bg-sky-soft text-sky-deep";
  const atSeconds =
    rideStartMs !== undefined
      ? Math.max(0, Math.round((event.occurredAtMs - rideStartMs) / 1000))
      : null;

  return (
    <div className="flex items-start gap-3.5 py-3.5">
      <div
        className={`flex h-8.5 w-8.5 shrink-0 items-center justify-center rounded-full text-[13px] font-semibold ${badgeStyle}`}
      >
        {index !== undefined ? index : <EventTypeIcon type={event.type} />}
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-[15px] font-medium text-paper">
            {EVENT_LABELS[event.type]}
          </span>
          <span
            className={`rounded-full px-2 py-0.5 text-[11px] font-medium ${badgeStyle}`}
          >
            Severity {event.severity}
          </span>
          <span className="ml-auto flex items-center gap-2">
            {atSeconds !== null && (
              <span className="font-mono text-[12px] text-subtle">
                +{Math.floor(atSeconds / 60)}:
                {String(atSeconds % 60).padStart(2, "0")}
              </span>
            )}
            <SourceBadge source={event.source} />
          </span>
        </div>
        <p className="mt-1 text-[13px] leading-relaxed text-muted">
          {event.summary}
        </p>
        <div className="mt-1 text-[12px] text-subtle">
          {formatDateTime(event.occurredAtMs)} · {event.geohash}
        </div>
      </div>
    </div>
  );
}
