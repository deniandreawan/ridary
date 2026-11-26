import React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";
import script from "../../script.json";
import { C, FONT } from "../theme";
import { clamp } from "../lib/motion";

type Cue = { start: number; end: number; text: string };

const cues: Cue[] = script.scenes.flatMap((scene) =>
  scene.captions.map(([start, end, text]) => ({
    start: start as number,
    end: end as number,
    text: text as string
  }))
);

export const CaptionTrack: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const time = frame / fps;
  const cue = cues.find((item) => time >= item.start && time < item.end);
  if (!cue) return null;

  const local = (time - cue.start) * fps;
  const fadeIn = Math.min(1, local / 7);
  const fadeOut = Math.min(1, (cue.end - time) * fps / 7);
  const opacity = Math.min(fadeIn, fadeOut);
  const lift = (1 - Math.min(1, local / 10)) * 8;

  return (
    <AbsoluteFill style={{ pointerEvents: "none", zIndex: 50 }}>
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 52,
          display: "flex",
          justifyContent: "center",
          padding: "0 90px"
        }}
      >
        <div
          style={{
            opacity,
            transform: `translateY(${lift}px)`,
            maxWidth: 1200,
            borderRadius: 16,
            padding: "11px 22px 12px",
            background: "rgba(250,250,250,.93)",
            border: `1px solid rgba(229,229,229,.9)`,
            boxShadow: "0 12px 32px rgba(23,23,23,.10)",
            backdropFilter: "blur(18px)",
            display: "flex",
            alignItems: "baseline",
            gap: 12,
            fontFamily: FONT
          }}
        >
          <span
            style={{
              color: C.skyDeep,
              fontSize: 10,
              fontWeight: 700,
              letterSpacing: ".14em",
              lineHeight: 1.2
            }}
          >
            EN
          </span>
          <span
            style={{
              color: C.ink,
              fontSize: 28,
              lineHeight: 1.34,
              letterSpacing: "-.018em",
              fontWeight: 520,
              textAlign: "center"
            }}
          >
            {cue.text}
          </span>
        </div>
      </div>
    </AbsoluteFill>
  );
};

export const ProgressRail: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();
  return (
    <AbsoluteFill style={{ pointerEvents: "none", zIndex: 60 }}>
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 0,
          height: 3,
          background: "rgba(23,23,23,.06)"
        }}
      >
        <div
          style={{
            height: "100%",
            width: `${(frame / durationInFrames) * 100}%`,
            background: `linear-gradient(90deg, ${C.skySoft}, ${C.sky}, ${C.skyDeep})`
          }}
        />
      </div>
    </AbsoluteFill>
  );
};

export const Loupe: React.FC<{
  frame: number;
  start: number;
  end: number;
  children: React.ReactNode;
}> = ({ frame, start, end, children }) => {
  const opacity = Math.min(
    Math.max(0, Math.min(1, (frame - start) / 8)),
    Math.max(0, Math.min(1, (end - frame) / 8))
  );
  return (
    <div style={{ opacity, transform: `translateY(${(1 - opacity) * 6}px)` }}>
      {children}
    </div>
  );
};

export const captionStyle = {
  color: C.ink,
  fontSize: 28,
  lineHeight: 1.34
};
