import React from "react";
import {
  AbsoluteFill,
  Img,
  OffthreadVideo,
  interpolate,
  staticFile,
  useCurrentFrame
} from "remotion";
import { Cloud, MapPin, Radio, ShieldCheck } from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { BrowserFrame } from "../components/BrowserFrame";
import { Chapter, Kicker, Micro, SourcePill, Stat } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { clamp, fade, rise, scaleIn } from "../lib/motion";

export const CloudMap: React.FC = () => {
  const frame = useCurrentFrame();

  return (
    <AbsoluteFill>
      <Backdrop>
        <div
          style={{
            position: "absolute",
            left: 92,
            top: 64,
            right: 92,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between"
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 13 }}>
            <BrandMark size={44} />
            <span
              style={{
                fontFamily: FONT,
                fontSize: 19,
                fontWeight: 700,
                letterSpacing: "-.02em",
                color: C.ink
              }}
            >
              Ridary
            </span>
          </div>
          <Chapter index="04" label="Aggregate in the cloud" />
        </div>

        <div style={{ position: "absolute", left: 92, top: 190, width: 600 }}>
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker>Community risk, without raw routes</Kicker>
          </div>
          <div
            style={{
              marginTop: 24,
              fontFamily: FONT,
              fontSize: 83,
              lineHeight: 0.96,
              letterSpacing: "-.07em",
              fontWeight: 650,
              color: C.ink
            }}
          >
            <div style={{ ...rise(frame, 10, 22) }}>Collective</div>
            <div style={{ ...rise(frame, 18, 22) }}>in the</div>
            <div style={{ ...rise(frame, 26, 22), color: C.skyDeep }}>cloud.</div>
          </div>
          <div
            style={{
              ...rise(frame, 38, 22),
              marginTop: 25,
              width: 570,
              fontFamily: FONT,
              fontSize: 22,
              lineHeight: 1.5,
              letterSpacing: "-.02em",
              color: C.muted
            }}
          >
            Anonymized events become a community risk map. Riders compare their
            week, risk cells, and the moments that need attention. Patterns, not
            raw routes.
          </div>

          <div
            style={{
              ...rise(frame, 54, 22),
              marginTop: 38,
              display: "flex",
              gap: 34,
              alignItems: "flex-end"
            }}
          >
            <Stat value="47" label="Anonymized moments" />
            <div style={{ height: 52, width: 1, background: C.line }} />
            <Stat value="3" label="Rides · sample week" />
            <div style={{ height: 52, width: 1, background: C.line }} />
            <Stat value="84" label="Average safety" />
          </div>

          <div
            style={{
              ...rise(frame, 70, 22),
              marginTop: 38,
              display: "flex",
              gap: 10,
              flexWrap: "wrap"
            }}
          >
            <SourcePill
              label="Patterns, not routes"
              icon={<ShieldCheck size={14} strokeWidth={2} />}
            />
            <SourcePill
              label="Coarse geohash only"
              tone="ink"
              icon={<MapPin size={14} strokeWidth={2} />}
            />
          </div>

          <div
            style={{
              ...rise(frame, 88, 22),
              marginTop: 34,
              display: "flex",
              alignItems: "center",
              gap: 10,
              color: C.subtle,
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".09em",
              textTransform: "uppercase"
            }}
          >
            <Radio size={13} color={C.skyDeep} />
            Derived signal · no identity
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            right: 92,
            top: 226,
            ...scaleIn(frame, 16, 34)
          }}
        >
          <BrowserFrame width={1130} url="ridary-demo.web.app/app">
            <div style={{ width: "100%", height: "100%", position: "relative" }}>
              <OffthreadVideo
                src={staticFile("recordings/web-dashboard.mp4")}
                muted
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
              />
              <Img
                src={staticFile("recordings/web-dashboard-still.png")}
                style={{
                  position: "absolute",
                  inset: 0,
                  width: "100%",
                  height: "100%",
                  objectFit: "cover",
                  opacity: interpolate(frame, [290, 320], [0, 1], clamp),
                  transform: `scale(${1 + interpolate(frame, [290, 720], [0, 0.035], clamp)})`
                }}
              />
            </div>
          </BrowserFrame>
          <div
            style={{
              position: "absolute",
              left: 22,
              top: -20,
              display: "flex",
              alignItems: "center",
              gap: 8,
              borderRadius: 999,
              background: "rgba(255,255,255,.94)",
              border: `1px solid ${C.line}`,
              padding: "8px 13px",
              boxShadow: "0 12px 24px rgba(23,23,23,.08)",
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".09em",
              textTransform: "uppercase",
              color: C.muted,
              opacity: fade(frame, 52, 20)
            }}
          >
            <span style={{ width: 7, height: 7, borderRadius: 99, background: C.sky }} />
            Live demo · sample data
          </div>
          <div
            style={{
              position: "absolute",
              right: 22,
              top: -20,
              display: "flex",
              alignItems: "center",
              gap: 8,
              borderRadius: 999,
              background: "rgba(9,13,17,.82)",
              border: "1px solid rgba(255,255,255,.12)",
              padding: "8px 13px",
              color: C.sky,
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".09em",
              textTransform: "uppercase",
              opacity: fade(frame, 66, 20)
            }}
          >
            <Cloud size={12} />
            the cloud sees no route
          </div>
        </div>
      </Backdrop>
    </AbsoluteFill>
  );
};
