import { AlertTriangle, Sparkles, X } from "lucide-react";
import type { ReactNode } from "react";

export function DemoBanner() {
  return (
    <div className="flex items-center gap-3 rounded-2xl border border-sky/20 bg-sky-soft/65 px-4 py-3">
      <div className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-white text-sky">
        <Sparkles size={14} />
      </div>
      <div className="text-[13px] leading-relaxed text-muted">
        <span className="font-medium text-paper">Sample dashboard.</span> Showing
        demo rides, risk cells, and a signed credential. Add your Firebase web
        values to <code className="font-mono text-[12px] text-paper">.env.local</code>{" "}
        for live sync and hybrid AI.
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
    <div className="flex items-start gap-3 rounded-2xl border border-danger/20 bg-danger/6 px-4 py-3">
      <AlertTriangle size={16} className="mt-0.5 shrink-0 text-danger" />
      <div className="flex-1 text-[13px] leading-relaxed text-paper">
        {message}
      </div>
      {onDismiss && (
        <button
          type="button"
          onClick={onDismiss}
          className="focus-ring rounded-full p-1 text-muted hover:text-paper"
          aria-label="Dismiss error"
        >
          <X size={14} />
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
    <div className="flex items-baseline justify-between gap-4">
      <div>
        {eyebrow && <div className="mono-label mb-1">{eyebrow}</div>}
        <h2 className="text-[17px] font-semibold tracking-[-0.02em] text-paper">
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
    <div className="surface-soft flex flex-col items-center gap-1.5 px-6 py-10 text-center">
      <div className="text-[15px] font-semibold text-paper">{title}</div>
      <div className="max-w-sm text-[13px] leading-relaxed text-muted">
        {message}
      </div>
    </div>
  );
}

export function LoadingScreen() {
  return (
    <div className="flex min-h-[55vh] items-center justify-center">
      <div className="inline-flex items-center gap-2.5 rounded-full bg-white px-4 py-2 text-[13px] font-medium text-muted shadow-sm">
        <span className="h-2 w-2 animate-pulse rounded-full bg-sky" />
        Loading Ridary…
      </div>
    </div>
  );
}
