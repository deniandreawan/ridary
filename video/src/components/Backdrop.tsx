import React from "react";
import { AbsoluteFill, Img, staticFile, useCurrentFrame } from "remotion";
import { C } from "../theme";

export const Backdrop: React.FC<{
  dark?: boolean;
  soft?: boolean;
  weave?: boolean;
  children?: React.ReactNode;
}> = ({ dark = false, soft = false, weave = true, children }) => {
  const frame = useCurrentFrame();
  const drift = Math.sin(frame / 150) * 26;
  return (
    <AbsoluteFill
      style={{
        background: dark
          ? `radial-gradient(ellipse 75% 60% at 78% 12%, #123347 0%, ${C.night} 52%, #070708 100%)`
          : soft
            ? `radial-gradient(ellipse 80% 58% at 18% 0%, ${C.skySoft} 0%, rgba(223,242,254,0) 58%), ${C.canvasSoft}`
            : `radial-gradient(ellipse 65% 50% at 80% 0%, ${C.skySoft} 0%, rgba(223,242,254,0) 55%), ${C.canvas}`
      }}
    >
      {weave && (
        <AbsoluteFill
          style={{
            opacity: dark ? 0.3 : 0.42,
            transform: `translateX(${drift}px)`,
            backgroundImage: `linear-gradient(90deg, ${dark ? "rgba(255,255,255,.055)" : "rgba(23,23,23,.055)"} 1px, transparent 1px), linear-gradient(0deg, ${dark ? "rgba(255,255,255,.04)" : "rgba(23,23,23,.04)"} 1px, transparent 1px)`,
            backgroundSize: "152px 152px",
            maskImage:
              "radial-gradient(ellipse 80% 70% at 60% 46%, black 0%, transparent 78%)"
          }}
        />
      )}
      <AbsoluteFill
        style={{
          background: dark
            ? "radial-gradient(ellipse 60% 50% at 90% 80%, rgba(0,166,244,.22), transparent 70%)"
            : "radial-gradient(ellipse 38% 40% at 8% 92%, rgba(0,166,244,.11), transparent 70%)"
        }}
      />
      <AbsoluteFill
        style={{
          opacity: dark ? 0.085 : 0.045,
          mixBlendMode: dark ? "screen" : "multiply",
          pointerEvents: "none"
        }}
      >
        <Img
          src={staticFile("brand/grain.png")}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
        />
      </AbsoluteFill>
      {children}
    </AbsoluteFill>
  );
};
