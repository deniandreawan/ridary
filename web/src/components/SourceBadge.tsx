import { Cloud, Cpu, FunctionSquare, RefreshCw } from "lucide-react";
import { inferenceLabel } from "../lib/format";
import type { InferenceSource } from "../types";

const STYLES: Record<InferenceSource, string> = {
  on_device: "bg-sky-soft text-sky-deep border-sky/20",
  in_cloud: "bg-white/90 text-sky-deep border-line",
  fallback: "bg-canvas-soft text-muted border-line/80",
  deterministic: "bg-canvas-soft text-muted border-line/80"
};

function SourceIcon({ source }: { source: InferenceSource }) {
  switch (source) {
    case "on_device":
      return <Cpu size={11} strokeWidth={1.9} />;
    case "in_cloud":
      return <Cloud size={11} strokeWidth={1.9} />;
    case "fallback":
      return <RefreshCw size={11} strokeWidth={1.9} />;
    case "deterministic":
      return <FunctionSquare size={11} strokeWidth={1.9} />;
  }
}

export function SourceBadge({ source }: { source: InferenceSource }) {
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-[11px] font-medium ${STYLES[source]}`}
    >
      <SourceIcon source={source} />
      {inferenceLabel(source)}
    </span>
  );
}
