import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { LockKeyhole, Sparkles } from "lucide-react";
import { BrandMark } from "./components/BrandMark";
import { DeviceFrame } from "./components/DeviceFrame";
import { C, FONT, MONO } from "./theme";

export const Thumbnail: React.FC = () => (
  <AbsoluteFill
    style={{
      background:
        "radial-gradient(ellipse 60% 65% at 82% 24%, #12384d 0%, #0b0b0d 54%, #070708 100%)",
      overflow: "hidden"
    }}
  >
    <AbsoluteFill
      style={{
        backgroundImage:
          "linear-gradient(rgba(255,255,255,.04) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.04) 1px, transparent 1px)",
        backgroundSize: "86px 86px",
        maskImage: "radial-gradient(ellipse 70% 60% at 75% 40%, black, transparent 80%)"
      }}
    />
    <AbsoluteFill style={{ opacity: 0.09, mixBlendMode: "screen" }}>
      <Img
        src={staticFile("brand/grain.png")}
        style={{ width: "100%", height: "100%", objectFit: "cover" }}
      />
    </AbsoluteFill>

    <div style={{ position: "absolute", left: 68, top: 52, display: "flex", gap: 12 }}>
      <BrandMark size={44} color={C.sky} />
      <div>
        <div
          style={{
            fontFamily: FONT,
            fontSize: 18,
            fontWeight: 700,
            color: C.white,
            letterSpacing: "-.02em"
          }}
        >
          Ridary
        </div>
        <div
          style={{
            marginTop: 3,
            fontFamily: MONO,
            fontSize: 9,
            fontWeight: 500,
            letterSpacing: ".14em",
            textTransform: "uppercase",
            color: "rgba(255,255,255,.42)"
          }}
        >
          Private ride witness
        </div>
      </div>
    </div>
    <div
      style={{
        position: "absolute",
        right: 68,
        top: 60,
        fontFamily: MONO,
        fontSize: 10,
        letterSpacing: ".1em",
        textTransform: "uppercase",
        color: "rgba(255,255,255,.42)"
      }}
    >
      Build Hybrid AI 2026
    </div>

    <div style={{ position: "absolute", left: 68, top: 184, width: 650 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        <Sparkles size={14} color={C.sky} />
        <span
          style={{
            fontFamily: MONO,
            fontSize: 10,
            letterSpacing: ".12em",
            textTransform: "uppercase",
            color: C.sky
          }}
        >
          On-device AI · private by design
        </span>
      </div>
      <div
        style={{
          marginTop: 22,
          fontFamily: FONT,
          fontSize: 104,
          lineHeight: 0.9,
          letterSpacing: "-.075em",
          fontWeight: 660,
          color: C.white
        }}
      >
        Every ride.
        <br />
        <span style={{ color: C.sky }}>On record.</span>
      </div>
      <div
        style={{
          marginTop: 25,
          fontFamily: FONT,
          fontSize: 22,
          lineHeight: 1.4,
          letterSpacing: "-.02em",
          color: "rgba(255,255,255,.56)",
          maxWidth: 560
        }}
      >
        A private record of where you were. Proof you can share.
        <br />
        Without giving away the route.
      </div>
      <div style={{ marginTop: 30, display: "flex", gap: 10 }}>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 7,
            borderRadius: 999,
            background: "rgba(0,166,244,.15)",
            border: "1px solid rgba(0,166,244,.25)",
            padding: "9px 13px",
            color: C.sky,
            fontFamily: FONT,
            fontSize: 13,
            fontWeight: 600
          }}
        >
          <LockKeyhole size={13} />
          Raw data stays local
        </div>
        <div
          style={{
            borderRadius: 999,
            background: "rgba(255,255,255,.06)",
            border: "1px solid rgba(255,255,255,.12)",
            padding: "9px 13px",
            color: "rgba(255,255,255,.56)",
            fontFamily: FONT,
            fontSize: 13
          }}
        >
          iOS + web
        </div>
      </div>
    </div>

    <div style={{ position: "absolute", right: 92, top: 96 }}>
      <DeviceFrame width={252} style={{ transform: "rotate(4deg)" }}>
        <Img
          src={staticFile("recordings/ios-summary.png")}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
        />
      </DeviceFrame>
      <div
        style={{
          position: "absolute",
          left: -56,
          top: 170,
          display: "flex",
          alignItems: "center",
          gap: 7,
          borderRadius: 12,
          background: "rgba(11,11,13,.8)",
          border: "1px solid rgba(0,166,244,.25)",
          padding: "9px 11px",
          fontFamily: FONT,
          fontSize: 12,
          fontWeight: 600,
          color: C.white,
          boxShadow: "0 16px 40px rgba(0,0,0,.25)"
        }}
      >
        <span style={{ width: 7, height: 7, borderRadius: 99, background: C.sky }} />
        On device
      </div>
    </div>

    <div
      style={{
        position: "absolute",
        left: 68,
        bottom: 44,
        right: 68,
        display: "flex",
        justifyContent: "space-between",
        borderTop: "1px solid rgba(255,255,255,.12)",
        paddingTop: 14,
        fontFamily: MONO,
        fontSize: 10,
        letterSpacing: ".09em",
        textTransform: "uppercase",
        color: "rgba(255,255,255,.35)"
      }}
    >
      <span>Apple Foundation Models · Firebase AI Logic</span>
      <span>ridary-demo.web.app</span>
    </div>
  </AbsoluteFill>
);
