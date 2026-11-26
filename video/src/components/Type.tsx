import React from "react";
import { C, FONT, MONO } from "../theme";

export const Kicker: React.FC<{
  children: React.ReactNode;
  dark?: boolean;
  color?: string;
  style?: React.CSSProperties;
}> = ({ children, dark = false, color, style }) => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      gap: 10,
      fontFamily: FONT,
      fontSize: 15,
      fontWeight: 650,
      letterSpacing: ".18em",
      textTransform: "uppercase",
      color: color ?? (dark ? "rgba(255,255,255,.56)" : C.muted),
      ...style
    }}
  >
    <span
      style={{
        width: 7,
        height: 7,
        borderRadius: 999,
        background: color ?? C.sky,
        boxShadow: `0 0 0 4px ${dark ? "rgba(0,166,244,.16)" : "rgba(0,166,244,.12)"}`
      }}
    />
    {children}
  </div>
);

export const Chapter: React.FC<{
  index: string;
  label: string;
  dark?: boolean;
}> = ({ index, label, dark = false }) => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      gap: 14,
      fontFamily: MONO,
      fontSize: 14,
      letterSpacing: ".12em",
      color: dark ? "rgba(255,255,255,.52)" : C.subtle,
      textTransform: "uppercase"
    }}
  >
    <span style={{ color: C.sky }}>{index}</span>
    <span style={{ width: 44, height: 1, background: dark ? "rgba(255,255,255,.2)" : C.line }} />
    <span>{label}</span>
  </div>
);

export const SourcePill: React.FC<{
  label: string;
  tone?: "sky" | "ink" | "soft";
  icon?: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ label, tone = "sky", icon, style }) => {
  const palette =
    tone === "ink"
      ? { bg: "rgba(23,23,23,.06)", fg: C.ink, border: "rgba(23,23,23,.1)" }
      : tone === "soft"
        ? { bg: "rgba(255,255,255,.7)", fg: C.muted, border: "rgba(255,255,255,.8)" }
        : { bg: "rgba(223,242,254,.86)", fg: C.skyDeep, border: "rgba(0,166,244,.18)" };
  return (
    <div
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: 8,
        borderRadius: 999,
        background: palette.bg,
        border: `1px solid ${palette.border}`,
        color: palette.fg,
        padding: "8px 13px",
        fontSize: 15,
        fontWeight: 620,
        fontFamily: FONT,
        letterSpacing: "-.01em",
        whiteSpace: "nowrap",
        ...style
      }}
    >
      {icon}
      {label}
    </div>
  );
};

export const Stat: React.FC<{
  value: string;
  label: string;
  dark?: boolean;
}> = ({ value, label, dark = false }) => (
  <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
    <div
      style={{
        fontFamily: FONT,
        fontSize: 45,
        fontWeight: 640,
        letterSpacing: "-.055em",
        color: dark ? C.white : C.ink,
        lineHeight: 1
      }}
    >
      {value}
    </div>
    <div
      style={{
        fontFamily: MONO,
        fontSize: 12,
        letterSpacing: ".12em",
        textTransform: "uppercase",
        color: dark ? "rgba(255,255,255,.45)" : C.subtle
      }}
    >
      {label}
    </div>
  </div>
);

export const Hairline: React.FC<{ dark?: boolean; style?: React.CSSProperties }> = ({
  dark = false,
  style
}) => (
  <div
    style={{
      height: 1,
      width: "100%",
      background: dark ? "rgba(255,255,255,.12)" : C.line,
      ...style
    }}
  />
);

export const Micro: React.FC<{
  children: React.ReactNode;
  dark?: boolean;
  color?: string;
  style?: React.CSSProperties;
}> = ({ children, dark = false, color, style }) => (
  <div
    style={{
      fontFamily: MONO,
      fontSize: 12,
      lineHeight: 1.5,
      letterSpacing: ".1em",
      textTransform: "uppercase",
      color: color ?? (dark ? "rgba(255,255,255,.42)" : C.subtle),
      ...style
    }}
  >
    {children}
  </div>
);
