import React from "react";
import {
  AbsoluteFill,
  OffthreadVideo,
  staticFile,
  useCurrentFrame
} from "remotion";
import {
  Cloud,
  FunctionSquare,
  LockKeyhole,
  Sparkles,
  Smartphone
} from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { DeviceFrame } from "../components/DeviceFrame";
import { Chapter, Kicker, Micro, SourcePill } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { fade, rise, scaleIn } from "../lib/motion";

const sources = [
  {
    icon: Smartphone,
    label: "On device",
    detail: "Apple Foundation Models",
    tone: C.sky,
    active: true
  },
  {
    icon: Cloud,
    label: "In cloud",
    detail: "only when you choose",
    tone: C.muted,
    active: false
  },
  {
    icon: FunctionSquare,
    label: "Rules",
    detail: "offline fallback",
    tone: C.muted,
    active: false
  }
] as const;

export const Ask: React.FC = () => {
  const frame = useCurrentFrame();

  return (
    <AbsoluteFill>
      <Backdrop soft>
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
          <Chapter index="03" label="Ask your ride" />
        </div>

        <div style={{ position: "absolute", left: 92, top: 224, width: 790 }}>
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker>Conversation, with a source</Kicker>
          </div>
          <div
            style={{
              marginTop: 28,
              fontFamily: FONT,
              fontSize: 90,
              lineHeight: 0.97,
              letterSpacing: "-.07em",
              fontWeight: 650,
              color: C.ink
            }}
          >
            <div style={{ ...rise(frame, 10, 22) }}>Ask your ride</div>
            <div style={{ ...rise(frame, 18, 22), color: C.skyDeep }}>anything.</div>
          </div>
          <div
            style={{
              ...rise(frame, 32, 22),
              marginTop: 30,
              width: 620,
              fontFamily: FONT,
              fontSize: 25,
              lineHeight: 1.5,
              letterSpacing: "-.02em",
              color: C.muted
            }}
          >
            Ridary answers from a compact local context: scores, event types,
            and high-level patterns. No raw route, no sensor window, no incident
            statement.
          </div>

          <div style={{ marginTop: 44, display: "flex", flexDirection: "column", gap: 10 }}>
            {sources.map((source, index) => {
              const Icon = source.icon;
              return (
                <div
                  key={source.label}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 13,
                    padding: "13px 15px",
                    borderRadius: 16,
                    background: source.active ? "rgba(255,255,255,.78)" : "transparent",
                    border: `1px solid ${source.active ? "rgba(0,166,244,.18)" : C.line}`,
                    opacity: fade(frame, 46 + index * 10, 20),
                    transform: `translateY(${(1 - fade(frame, 46 + index * 10, 20)) * 8}px)`
                  }}
                >
                  <div
                    style={{
                      width: 34,
                      height: 34,
                      borderRadius: 999,
                      display: "grid",
                      placeItems: "center",
                      background: source.active ? "rgba(0,166,244,.12)" : "rgba(23,23,23,.04)",
                      color: source.active ? C.skyDeep : C.subtle
                    }}
                  >
                    <Icon size={17} strokeWidth={1.8} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <div
                      style={{
                        fontFamily: FONT,
                        fontSize: 17,
                        fontWeight: 640,
                        color: source.active ? C.ink : C.muted,
                        letterSpacing: "-.015em"
                      }}
                    >
                      {source.label}
                    </div>
                    <div
                      style={{
                        marginTop: 2,
                        fontFamily: MONO,
                        fontSize: 9,
                        letterSpacing: ".08em",
                        textTransform: "uppercase",
                        color: C.subtle
                      }}
                    >
                      {source.detail}
                    </div>
                  </div>
                  {source.active && (
                    <Sparkles size={16} color={C.skyDeep} strokeWidth={1.9} />
                  )}
                </div>
              );
            })}
          </div>

          <div
            style={{
              ...rise(frame, 96, 22),
              marginTop: 32,
              display: "flex",
              alignItems: "center",
              gap: 10,
              color: C.subtle,
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".08em",
              textTransform: "uppercase"
            }}
          >
            <LockKeyhole size={13} />
            No raw route in the prompt
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            right: 196,
            top: 108,
            ...scaleIn(frame, 14, 32)
          }}
        >
          <DeviceFrame width={372}>
            <OffthreadVideo
              src={staticFile("recordings/ios-ask.mp4")}
              muted
              style={{ width: "100%", height: "100%", objectFit: "cover" }}
            />
          </DeviceFrame>
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              marginTop: 18
            }}
          >
            <SourcePill
              label="Demo · on-device path"
              tone="soft"
              icon={<Smartphone size={13} />}
            />
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            left: 92,
            bottom: 150,
            display: "flex",
            alignItems: "center",
            gap: 12,
            fontFamily: MONO,
            fontSize: 10,
            letterSpacing: ".09em",
            textTransform: "uppercase",
            color: C.subtle
          }}
        >
          <span style={{ width: 6, height: 6, borderRadius: 99, background: C.sky }} />
          Source badge · part of the answer
        </div>
      </Backdrop>
    </AbsoluteFill>
  );
};
