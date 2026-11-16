export function Logo({ compact = false }: { compact?: boolean }) {
  return (
    <div className="flex items-center gap-3">
      <svg
        width="34"
        height="34"
        viewBox="0 0 34 34"
        fill="none"
        aria-hidden="true"
        className="shrink-0"
      >
        <rect
          x="1"
          y="1"
          width="32"
          height="32"
          rx="11"
          stroke="rgba(255,184,77,0.35)"
        />
        <path
          d="M8 24.5C11.5 24 12.2 12 16.8 12C20.6 12 20.4 22 25.8 20.5"
          stroke="#ffb84d"
          strokeWidth="2.2"
          strokeLinecap="round"
        />
        <circle cx="8" cy="24.5" r="2.2" fill="#5be3c0" />
        <circle cx="25.8" cy="20.5" r="2.2" fill="#ffb84d" />
      </svg>
      <div className="leading-tight">
        <div className="font-mono text-[10px] tracking-[0.32em] text-accent">
          RIDARY
        </div>
        {!compact && (
          <div className="text-xs text-muted">Private ride witness</div>
        )}
      </div>
    </div>
  );
}
