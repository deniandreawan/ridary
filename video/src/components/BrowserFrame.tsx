import React from "react";
import { C, FONT, MONO } from "../theme";

export const BrowserFrame: React.FC<{
  width?: number;
  url?: string;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ width = 1320, url = "ridary-demo.web.app/app", children, style }) => {
  const bar = 46;
  const radius = 24;
  const bodyHeight = Math.round(width * (9 / 16));
  return (
    <div
      style={{
        width,
        borderRadius: radius,
        background: "#ffffff",
        overflow: "hidden",
        boxShadow:
          "0 52px 110px rgba(0,0,0,.26), 0 14px 36px rgba(0,0,0,.15), 0 0 0 1px rgba(23,23,23,.08)",
        ...style
      }}
    >
      <div
        style={{
          height: bar,
          display: "flex",
          alignItems: "center",
          gap: 12,
          padding: "0 18px",
          background: "rgba(250,250,250,.96)",
          borderBottom: `1px solid ${C.line}`,
          position: "relative"
        }}
      >
        <div style={{ display: "flex", gap: 7 }}>
          {["#ff5f57", "#febc2e", "#28c840"].map((color) => (
            <div
              key={color}
              style={{ width: 10, height: 10, borderRadius: 999, background: color }}
            />
          ))}
        </div>
        <div
          style={{
            position: "absolute",
            left: "50%",
            transform: "translateX(-50%)",
            width: "46%",
            height: 27,
            borderRadius: 999,
            background: "#ffffff",
            border: `1px solid ${C.line}`,
            color: C.muted,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontFamily: MONO,
            fontSize: 11,
            letterSpacing: ".02em",
            gap: 7
          }}
        >
          <span style={{ color: C.sky, fontSize: 12 }}>●</span>
          {url}
        </div>
        <div
          style={{
            marginLeft: "auto",
            color: C.subtle,
            fontFamily: FONT,
            fontSize: 13,
            letterSpacing: "-.01em"
          }}
        >
          Live demo
        </div>
      </div>
      <div
        style={{
          width,
          height: bodyHeight,
          background: C.canvas,
          overflow: "hidden",
          position: "relative"
        }}
      >
        {children}
      </div>
    </div>
  );
};
