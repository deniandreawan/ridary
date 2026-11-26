import React from "react";
import { C } from "../theme";

export const DeviceFrame: React.FC<{
  width?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ width = 370, children, style }) => {
  const height = Math.round(width * (2622 / 1206));
  const pad = Math.max(8, Math.round(width * 0.024));
  const radius = Math.round(width * 0.145);
  return (
    <div
      style={{
        width: width + pad * 2,
        height: height + pad * 2,
        borderRadius: radius + pad,
        padding: pad,
        background:
          "linear-gradient(145deg, #46474b 0%, #101012 24%, #050506 70%, #2b2c30 100%)",
        boxShadow:
          "0 70px 120px rgba(0,0,0,.34), 0 20px 50px rgba(0,0,0,.22), inset 0 0 0 1px rgba(255,255,255,.14), inset 0 0 0 3px rgba(0,0,0,.6)",
        position: "relative",
        ...style
      }}
    >
      <div
        style={{
          width,
          height,
          borderRadius: radius,
          overflow: "hidden",
          background: "#000",
          position: "relative",
          boxShadow: "inset 0 0 0 1px rgba(255,255,255,.10)"
        }}
      >
        {children}
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: radius,
            pointerEvents: "none",
            background:
              "linear-gradient(116deg, rgba(255,255,255,.15) 0%, rgba(255,255,255,0) 28%, rgba(255,255,255,0) 64%, rgba(255,255,255,.05) 100%)"
          }}
        />
      </div>
      <div
        style={{
          position: "absolute",
          left: -3,
          top: height * 0.255,
          width: 3,
          height: 54,
          borderRadius: "3px 0 0 3px",
          background: "#1a1a1c"
        }}
      />
      <div
        style={{
          position: "absolute",
          left: -3,
          top: height * 0.35,
          width: 3,
          height: 92,
          borderRadius: "3px 0 0 3px",
          background: "#1a1a1c"
        }}
      />
      <div
        style={{
          position: "absolute",
          right: -3,
          top: height * 0.3,
          width: 3,
          height: 120,
          borderRadius: "0 3px 3px 0",
          background: "#1a1a1c"
        }}
      />
      <div
        style={{
          position: "absolute",
          inset: 0,
          borderRadius: radius + pad,
          pointerEvents: "none",
          boxShadow: `inset 0 0 0 1px rgba(255,255,255,.06), 0 0 0 1px ${C.night}`
        }}
      />
    </div>
  );
};
