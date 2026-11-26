import React from "react";
import { C } from "../theme";

export const BrandMark: React.FC<{
  size?: number;
  progress?: number;
  color?: string;
  glow?: boolean;
  style?: React.CSSProperties;
}> = ({ size = 96, progress = 1, color = C.sky, glow = true, style }) => {
  const dash = 430;
  const offset = dash * (1 - Math.max(0, Math.min(1, progress)));
  return (
    <div
      style={{
        width: size,
        height: size,
        position: "relative",
        filter: glow ? `drop-shadow(0 12px 30px ${color}33)` : undefined,
        ...style
      }}
    >
      <svg viewBox="0 0 240 240" width={size} height={size} fill="none">
        <defs>
          <linearGradient id="ridary-mark" x1="42" y1="176" x2="222" y2="120">
            <stop offset="0%" stopColor={C.sky} />
            <stop offset="100%" stopColor={C.skyDeep} />
          </linearGradient>
        </defs>
        <path
          d="M48 170 C76 165 83 138 100 110 C117 82 143 61 168 76 C187 88 189 116 199 133 C204 142 210 144 220 142"
          stroke="url(#ridary-mark)"
          strokeWidth="27"
          strokeLinecap="round"
          strokeDasharray={dash}
          strokeDashoffset={offset}
        />
        <circle cx="48" cy="170" r="28" fill={color} opacity={Math.min(1, progress * 2)} />
        <circle cx="220" cy="142" r="26" fill={color} opacity={Math.min(1, progress * 2)} />
      </svg>
    </div>
  );
};
