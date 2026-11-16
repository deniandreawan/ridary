import { AlertTriangle, FlaskConical, X } from "lucide-react";
import type { ReactNode } from "react";

export function DemoBanner() {
  return (
    <div className="flex items-start gap-3 rounded-2xl border border-accent/25 bg-accent/8 px-4 py-3">
      <FlaskConical size={16} className="mt-0.5 shrink-0 text-accent" />
      <div className="text-xs leading-relaxed text-muted">
        <span className="font-semibold text-paper">Demo mode.</span> The
        dashboard is showing sample rides and risk cells. Add your Firebase
        web app values to `.env.local` to load live data and hybrid AI.
      </div>
    </div>
  );
}

export function ErrorBanner({
  message,
  onDismiss
}: {
  message: string;
  onDismiss?: () => void;
}) {
  return (
    <div className="flex items-start gap-3 rounded-2xl border border-danger/25 bg-danger/8 px-4 py-3">
      <AlertTriangle size={16} className="mt-0.5 shrink-0 text-danger" />
      <div className="flex-1 text-xs leading-relaxed text-muted">{message}</div>
      {onDismiss && (
        <button
          type="button"
          onClick={onDismiss}
          className="focus-ring rounded-md p-1 text-muted hover:text-paper"
          aria-label="Dismiss error"
        >
          <X size={13} />
        </button>
      )}
    </div>
  );
}

export function SectionHeader({
  eyebrow,
  title,
  action
}: {
  eyebrow?: string;
  title: string;
  action?: ReactNode;
}) {
  return (
    <div className="flex items-end justify-between gap-4">
      <div>
        {eyebrow && <div className="mono-label mb-2">{eyebrow}</div>}
        <h2 className="text-lg font-semibold tracking-tight text-paper">
          {title}
        </h2>
      </div>
      {action}
    </div>
  );
}

export function EmptyState({
  title,
  message
}: {
  title: string;
  message: string;
}) {
  return (
    <div className="surface-soft flex flex-col items-center gap-2 px-6 py-12 text-center">
      <div className="font-mono text-[10px] uppercase tracking-[0.18em] text-accent">
        Nothing here yet
      </div>
      <div className="text-sm font-semibold">{title}</div>
      <div className="max-w-sm text-xs leading-relaxed text-muted">{message}</div>
    </div>
  );
}

export function LoadingScreen() {
  return (
    <div className="flex min-h-[60vh] items-center justify-center">
      <div className="flex items-center gap-3 font-mono text-xs uppercase tracking-[0.2em] text-muted">
        <span className="h-2 w-2 animate-pulse rounded-full bg-accent" />
        Loading Ridary
      </div>
    </div>
  );
}
