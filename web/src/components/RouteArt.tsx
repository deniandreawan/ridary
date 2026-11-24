type Point = [number, number];

function normalize(route: number[][]): Point[] {
  const points = route
    .filter(
      (pair): pair is Point =>
        Array.isArray(pair) &&
        pair.length === 2 &&
        Number.isFinite(pair[0]) &&
        Number.isFinite(pair[1])
    )
    .map(([lat, lon]) => [lon, lat] as Point);

  if (points.length < 2) return [];

  const xs = points.map(([x]) => x);
  const ys = points.map(([, y]) => y);
  const minX = Math.min(...xs);
  const maxX = Math.max(...xs);
  const minY = Math.min(...ys);
  const maxY = Math.max(...ys);
  const width = Math.max(maxX - minX, 0.00001);
  const height = Math.max(maxY - minY, 0.00001);
  const padding = 24;
  const scale = Math.min(
    (320 - padding * 2) / width,
    (160 - padding * 2) / height
  );
  const offsetX = (320 - width * scale) / 2;
  const offsetY = (160 - height * scale) / 2;

  return points.map(([x, y]) => [
    offsetX + (x - minX) * scale,
    offsetY + (y - minY) * scale
  ]);
}

function pathFor(points: Point[]): string {
  const first = points[0];
  if (!first) return "";
  if (points.length === 2) {
    const last = points[1];
    if (!last) return `M ${first[0].toFixed(1)} ${first[1].toFixed(1)}`;
    return `M ${first[0].toFixed(1)} ${first[1].toFixed(1)} L ${last[0].toFixed(1)} ${last[1].toFixed(1)}`;
  }
  let path = `M ${first[0].toFixed(1)} ${first[1].toFixed(1)}`;
  for (let index = 1; index < points.length - 1; index += 1) {
    const current = points[index];
    const next = points[index + 1];
    if (!current || !next) continue;
    const midpoint = [
      (current[0] + next[0]) / 2,
      (current[1] + next[1]) / 2
    ] as Point;
    path += ` Q ${current[0].toFixed(1)} ${current[1].toFixed(1)} ${midpoint[0].toFixed(1)} ${midpoint[1].toFixed(1)}`;
  }
  const last = points[points.length - 1];
  if (last) path += ` L ${last[0].toFixed(1)} ${last[1].toFixed(1)}`;
  return path;
}

export function RouteArt({
  route,
  className = ""
}: {
  route: number[][];
  className?: string;
}) {
  const points = normalize(route);
  const hasRoute = points.length > 1;
  const fallback = "M 30 122 C 72 104 62 54 122 68 C 176 82 172 34 290 42";
  const path = hasRoute ? pathFor(points) : fallback;
  const start: Point = points[0] ?? [30, 122];
  const end: Point = points[points.length - 1] ?? [290, 42];

  return (
    <svg
      viewBox="0 0 320 160"
      className={className}
      role="img"
      aria-label={hasRoute ? "Route preview" : "Route illustration"}
      preserveAspectRatio="xMidYMid slice"
    >
      <rect width="320" height="160" fill="#f0f9ff" />
      <path
        d="M -10 36 C 48 20 92 42 150 28 C 214 12 258 38 330 18"
        fill="none"
        stroke="#dff2fe"
        strokeWidth="2"
      />
      <path
        d="M -10 132 C 58 112 98 138 164 120 C 228 102 272 126 330 108"
        fill="none"
        stroke="#dff2fe"
        strokeWidth="2"
      />
      <path
        d="M 72 -12 C 56 44 96 66 82 118 C 76 140 88 154 104 172"
        fill="none"
        stroke="#dff2fe"
        strokeWidth="2"
      />
      <path
        d="M 236 -12 C 218 38 252 72 228 112 C 220 128 228 148 244 172"
        fill="none"
        stroke="#dff2fe"
        strokeWidth="2"
      />
      <path
        d={path}
        fill="none"
        stroke="rgba(255,255,255,0.96)"
        strokeWidth="9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d={path}
        fill="none"
        stroke="#00a6f4"
        strokeWidth="4.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <circle cx={start[0]} cy={start[1]} r="4.5" fill="#00a6f4" stroke="#ffffff" strokeWidth="2" />
      <circle cx={end[0]} cy={end[1]} r="5.5" fill="#0084d1" stroke="#ffffff" strokeWidth="2" />
    </svg>
  );
}
