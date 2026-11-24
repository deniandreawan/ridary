export function Logo({ compact = false }: { compact?: boolean }) {
  return (
    <div className="flex items-center gap-3">
      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-sky-soft">
        <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          aria-hidden="true"
        >
          <path
            d="M4 17.5C7.2 17 8 7.5 12.2 7.5C15.8 7.5 15.6 15.5 20 14"
            stroke="#0084d1"
            strokeWidth="2.2"
            strokeLinecap="round"
          />
          <circle cx="4" cy="17.5" r="2.2" fill="#00a6f4" />
          <circle cx="20" cy="14" r="2.2" fill="#0084d1" />
        </svg>
      </div>
      <div className="leading-tight">
        <div className="text-[15px] font-semibold tracking-[-0.02em] text-paper">
          Ridary
        </div>
        {!compact && (
          <div className="text-[12px] font-normal text-muted">
            Private ride witness
          </div>
        )}
      </div>
    </div>
  );
}
