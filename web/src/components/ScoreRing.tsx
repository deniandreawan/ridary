export function ScoreRing({
  score,
  size = 96
}: {
  score: number;
  size?: number;
}) {
  const clamped = Math.min(100, Math.max(0, score));
  const color =
    clamped >= 75 ? "#00a6f4" : clamped >= 60 ? "#e17100" : "#e7000b";
  return (
    <div
      className="rounded-full p-[6px] shadow-sm"
      style={{
        width: size,
        height: size,
        background: `conic-gradient(${color} ${clamped * 3.6}deg, rgba(23,23,23,0.06) 0deg)`
      }}
      aria-label={`Safety score ${clamped} out of 100`}
      role="img"
    >
      <div className="flex h-full w-full flex-col items-center justify-center rounded-full bg-white">
        <span
          className="font-semibold leading-none tracking-tight text-paper"
          style={{ fontSize: size * 0.28 }}
        >
          {clamped}
        </span>
        <span className="mt-1 text-[10px] font-medium text-muted">
          safety
        </span>
      </div>
    </div>
  );
}
