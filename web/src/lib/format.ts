import type { InferenceSource, RideMode } from "../types";

export function formatDateTime(ms: number): string {
  return new Intl.DateTimeFormat("en", {
    dateStyle: "medium",
    timeStyle: "short"
  }).format(new Date(ms));
}

export function formatDate(ms: number): string {
  return new Intl.DateTimeFormat("en", { dateStyle: "medium" }).format(
    new Date(ms)
  );
}

export function formatISODate(value: string): string {
  const ms = Date.parse(value);
  return Number.isNaN(ms) ? value : formatDate(ms);
}

export function formatPeriod(start: string, end: string): string {
  return `${formatISODate(start)} – ${formatISODate(end)}`;
}

export function formatDistance(meters: number): string {
  if (!Number.isFinite(meters)) return "—";
  if (meters >= 1000) return `${(meters / 1000).toFixed(1)} km`;
  return `${Math.round(meters)} m`;
}

export function formatDuration(seconds: number): string {
  if (!Number.isFinite(seconds)) return "—";
  const total = Math.max(0, Math.floor(seconds));
  const hours = Math.floor(total / 3600);
  const minutes = Math.floor((total % 3600) / 60);
  const secs = total % 60;
  if (hours > 0) {
    return `${hours}:${String(minutes).padStart(2, "0")}:${String(secs).padStart(2, "0")}`;
  }
  return `${minutes}:${String(secs).padStart(2, "0")}`;
}

export function formatSpeed(kph: number): string {
  if (!Number.isFinite(kph)) return "—";
  return `${Math.round(kph)} km/h`;
}

export function scoreBand(score: number): "A" | "B" | "C" | "D" {
  if (score >= 90) return "A";
  if (score >= 75) return "B";
  if (score >= 60) return "C";
  return "D";
}

export function scoreColor(score: number): string {
  if (score >= 90) return "#5be3c0";
  if (score >= 75) return "#ffb84d";
  if (score >= 60) return "#ff9f5a";
  return "#ff6b6b";
}

export function inferenceLabel(source: InferenceSource): string {
  switch (source) {
    case "on_device":
      return "On device";
    case "in_cloud":
      return "In cloud";
    case "fallback":
      return "Fallback";
    case "deterministic":
      return "Rules";
  }
}

export function modeLabel(mode: RideMode): string {
  return mode.charAt(0).toUpperCase() + mode.slice(1);
}
