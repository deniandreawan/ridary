import { inferenceLabel } from "../lib/format";
import type { InferenceSource } from "../types";

const STYLES: Record<InferenceSource, string> = {
  on_device: "border-teal/30 bg-teal/10 text-teal",
  in_cloud: "border-accent/30 bg-accent/10 text-accent",
  fallback: "border-line bg-ink/5 text-muted",
  deterministic: "border-line bg-ink/5 text-muted"
};

export function SourceBadge({ source }: { source: InferenceSource }) {
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 font-mono text-[10px] uppercase tracking-[0.12em] ${STYLES[source]}`}
    >
      <span className="h-1.5 w-1.5 rounded-full bg-current" />
      {inferenceLabel(source)}
    </span>
  );
}
