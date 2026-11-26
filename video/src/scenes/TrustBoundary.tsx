import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  useCurrentFrame
} from "remotion";
import {
  Activity,
  ArrowRight,
  Check,
  Cloud,
  Cpu,
  FileWarning,
  Fingerprint,
  LockKeyhole,
  MapPin,
  MessageSquare,
  ShieldCheck,
  Sparkles
} from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { Chapter, Kicker, Micro, SourcePill } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { clamp, fade, rise } from "../lib/motion";

const privateRows = [
  [MapPin, "GPS route", "raw"],
  [Activity, "Motion windows", "raw"],
  [FileWarning, "Incident evidence", "raw"],
  [MessageSquare, "Statements", "raw"]
] as const;

const cloudRows = [
  [Sparkles, "Ride score", "derived"],
  [Fingerprint, "Derived summary", "derived"],
  [MapPin, "Coarse risk cells", "derived"],
  [ShieldCheck, "Signed credential", "derived"]
] as const;

export const TrustBoundary: React.FC = () => {
  const frame = useCurrentFrame();
  const boundary = interpolate(frame, [36, 92], [0, 1], {
    ...clamp,
    easing: Easing.bezier(0.22, 1, 0.36, 1)
  });
  const rawX = interpolate(frame, [80, 160], [0, 0.415], clamp);
  const rawFade = Math.min(1, Math.max(0, (frame - 70) / 18), Math.max(0, (200 - frame) / 20));
  const derivedX = interpolate(frame, [180, 270], [0, 1], {
    ...clamp,
    easing: Easing.bezier(0.22, 1, 0.36, 1)
  });
  const derivedFade = Math.min(1, Math.max(0, (frame - 170) / 16), Math.max(0, (300 - frame) / 20));
  const pulse = Math.sin(frame / 15) * 0.5 + 0.5;

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
          <Chapter index="06" label="The trust boundary" />
        </div>

        <div
          style={{
            position: "absolute",
            left: 0,
            right: 0,
            top: 152,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            textAlign: "center"
          }}
        >
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker>Hybrid inference, made visible</Kicker>
          </div>
          <div
            style={{
              marginTop: 20,
              fontFamily: FONT,
              fontSize: 68,
              lineHeight: 1.02,
              letterSpacing: "-.06em",
              fontWeight: 650,
              color: C.ink,
              maxWidth: 1180
            }}
          >
            <div style={{ ...rise(frame, 10, 22) }}>
              Private at the edge.{" "}
              <span style={{ color: C.skyDeep }}>Collective in the cloud.</span>
            </div>
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            left: 136,
            top: 338,
            width: 740,
            height: 512,
            borderRadius: 30,
            background: "rgba(255,255,255,.8)",
            border: "1px solid rgba(255,255,255,.95)",
            boxShadow: "0 28px 70px rgba(23,23,23,.07)",
            overflow: "hidden",
            opacity: fade(frame, 18, 24),
            transform: `translateY(${(1 - fade(frame, 18, 24)) * 16}px)`
          }}
        >
          <div
            style={{
              position: "absolute",
              inset: 0,
              background:
                "radial-gradient(ellipse 80% 80% at 20% 0%, rgba(223,242,254,.9), transparent 60%)"
            }}
          />
          <div
            style={{
              position: "relative",
              padding: "26px 30px",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between"
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: 11 }}>
              <div
                style={{
                  width: 38,
                  height: 38,
                  borderRadius: 12,
                  background: C.white,
                  color: C.skyDeep,
                  display: "grid",
                  placeItems: "center",
                  boxShadow: "0 8px 18px rgba(0,132,209,.10)"
                }}
              >
                <LockKeyhole size={19} strokeWidth={1.8} />
              </div>
              <div>
                <Micro>On this iPhone</Micro>
                <div
                  style={{
                    marginTop: 3,
                    fontFamily: FONT,
                    fontSize: 18,
                    fontWeight: 650,
                    color: C.ink
                  }}
                >
                  Private record
                </div>
              </div>
            </div>
            <SourcePill label="Raw + private" tone="ink" />
          </div>
          <div style={{ position: "relative", padding: "0 30px" }}>
            {privateRows.map(([Icon, title, tag], index) => (
              <div
                key={title}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 14,
                  height: 68,
                  borderTop: `1px solid ${C.line}`,
                  opacity: fade(frame, 44 + index * 9, 18)
                }}
              >
                <Icon size={17} color={C.skyDeep} strokeWidth={1.8} />
                <span
                  style={{
                    fontFamily: FONT,
                    fontSize: 18,
                    fontWeight: 600,
                    color: C.ink,
                    letterSpacing: "-.015em"
                  }}
                >
                  {title}
                </span>
                <span
                  style={{
                    marginLeft: "auto",
                    fontFamily: MONO,
                    fontSize: 9,
                    letterSpacing: ".1em",
                    textTransform: "uppercase",
                    color: C.subtle
                  }}
                >
                  {tag}
                </span>
              </div>
            ))}
            <div
              style={{
                marginTop: 20,
                display: "flex",
                alignItems: "center",
                gap: 9,
                color: C.muted,
                fontFamily: FONT,
                fontSize: 14
              }}
            >
              <LockKeyhole size={14} color={C.skyDeep} />
              Stored with file protection. Camera, mic, and audio never used.
            </div>
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            right: 136,
            top: 338,
            width: 740,
            height: 512,
            borderRadius: 30,
            background: "rgba(255,255,255,.8)",
            border: "1px solid rgba(255,255,255,.95)",
            boxShadow: "0 28px 70px rgba(23,23,23,.07)",
            overflow: "hidden",
            opacity: fade(frame, 30, 24),
            transform: `translateY(${(1 - fade(frame, 30, 24)) * 16}px)`
          }}
        >
          <div
            style={{
              position: "absolute",
              inset: 0,
              background:
                "radial-gradient(ellipse 80% 80% at 84% 0%, rgba(223,242,254,.8), transparent 60%)"
            }}
          />
          <div
            style={{
              position: "relative",
              padding: "26px 30px",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between"
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: 11 }}>
              <div
                style={{
                  width: 38,
                  height: 38,
                  borderRadius: 12,
                  background: C.white,
                  color: C.skyDeep,
                  display: "grid",
                  placeItems: "center",
                  boxShadow: "0 8px 18px rgba(0,132,209,.10)"
                }}
              >
                <Cloud size={19} strokeWidth={1.8} />
              </div>
              <div>
                <Micro>In the cloud</Micro>
                <div
                  style={{
                    marginTop: 3,
                    fontFamily: FONT,
                    fontSize: 18,
                    fontWeight: 650,
                    color: C.ink
                  }}
                >
                  Derived signal
                </div>
              </div>
            </div>
            <SourcePill label="Derived only" />
          </div>
          <div style={{ position: "relative", padding: "0 30px" }}>
            {cloudRows.map(([Icon, title, tag], index) => (
              <div
                key={title}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 14,
                  height: 68,
                  borderTop: `1px solid ${C.line}`,
                  opacity: fade(frame, 58 + index * 9, 18)
                }}
              >
                <Icon size={17} color={C.skyDeep} strokeWidth={1.8} />
                <span
                  style={{
                    fontFamily: FONT,
                    fontSize: 18,
                    fontWeight: 600,
                    color: C.ink,
                    letterSpacing: "-.015em"
                  }}
                >
                  {title}
                </span>
                <span
                  style={{
                    marginLeft: "auto",
                    fontFamily: MONO,
                    fontSize: 9,
                    letterSpacing: ".1em",
                    textTransform: "uppercase",
                    color: C.subtle
                  }}
                >
                  {tag}
                </span>
              </div>
            ))}
            <div
              style={{
                marginTop: 20,
                display: "flex",
                alignItems: "center",
                gap: 9,
                color: C.muted,
                fontFamily: FONT,
                fontSize: 14
              }}
            >
              <ShieldCheck size={14} color={C.skyDeep} />
              Aggregated, signed, and safe to share.
            </div>
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            left: 936,
            top: 338,
            width: 2,
            height: 512,
            background: `linear-gradient(180deg, rgba(0,166,244,0), ${C.sky}, rgba(0,166,244,0))`,
            opacity: boundary * 0.8
          }}
        >
          <div
            style={{
              position: "absolute",
              left: -4,
              top: 26,
              width: 10,
              height: 10,
              borderRadius: 999,
              background: C.sky,
              boxShadow: `0 0 0 7px rgba(0,166,244,${0.08 + pulse * 0.08})`
            }}
          />
        </div>
        <div
          style={{
            position: "absolute",
            left: 850,
            top: 620,
            width: 176,
            textAlign: "center",
            fontFamily: MONO,
            fontSize: 10,
            letterSpacing: ".1em",
            textTransform: "uppercase",
            color: C.muted,
            opacity: boundary
          }}
        >
          trust boundary
        </div>

        <div
          style={{
            position: "absolute",
            left: 0,
            right: 0,
            bottom: 150,
            display: "flex",
            justifyContent: "center",
            gap: 10,
            opacity: fade(frame, 270, 24)
          }}
        >
          <SourcePill
            label="Apple Foundation Models"
            icon={<Cpu size={14} strokeWidth={1.8} />}
          />
          <SourcePill
            label="Firebase AI Logic"
            tone="ink"
            icon={<Sparkles size={14} strokeWidth={1.8} />}
          />
          <SourcePill
            label="Firebase App Check"
            tone="soft"
            icon={<Check size={14} strokeWidth={2.2} />}
          />
        </div>
      </Backdrop>
    </AbsoluteFill>
  );
};
