import { scoreColor } from "../lib/format";

export function ScoreRing({
  score,
  size = 96
}: {
  score: number;
  size?: number;
}) {
  const color = scoreColor(score);
  const clamped = Math.min(100, Math.max(0, score));
  return (
    <div
      className="rounded-full p-[7px]"
      style={{
        width: size,
        height: size,
        background: `conic-gradient(${color} ${clamped * 3.6}deg, rgba(11,17,20,0.08) 0deg)`
      }}
      aria-label={`Safety score ${clamped} out of 100`}
      role="img"
    >
      <div className="flex h-full w-full flex-col items-center justify-center rounded-full bg-card">
        <span
          className="font-mono font-semibold leading-none"
          style={{ color, fontSize: size * 0.27 }}
        >
          {clamped}
        </span>
        <span className="mt-1 font-mono text-[9px] uppercase tracking-[0.18em] text-muted">
          score
        </span>
      </div>
    </div>
  );
}
