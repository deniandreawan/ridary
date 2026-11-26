import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig
} from "remotion";
import { ArrowUpRight, LockKeyhole, Sparkles } from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { Kicker, Micro, SourcePill } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { clamp, reveal, rise } from "../lib/motion";

export const Intro: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const mark = spring({ frame, fps, config: { damping: 20, stiffness: 90 } });
  const route = interpolate(frame, [18, 92], [0, 1], {
    ...clamp,
    easing: Easing.bezier(0.22, 1, 0.36, 1)
  });
  const dot = interpolate(frame, [76, 104], [0, 1], clamp);

  return (
    <AbsoluteFill>
      <Backdrop weave>
        <div
          style={{
            position: "absolute",
            left: 92,
            top: 64,
            display: "flex",
            alignItems: "center",
            gap: 14
          }}
        >
          <BrandMark size={58} progress={mark} />
          <div>
            <div
              style={{
                fontFamily: FONT,
                fontSize: 22,
                fontWeight: 700,
                letterSpacing: "-.02em",
                color: C.ink
              }}
            >
              Ridary
            </div>
            <Micro style={{ marginTop: 4 }}>Private ride witness</Micro>
          </div>
        </div>
        <div
          style={{
            position: "absolute",
            right: 92,
            top: 72,
            fontFamily: MONO,
            fontSize: 12,
            letterSpacing: ".12em",
            color: C.subtle,
            textTransform: "uppercase",
            textAlign: "right",
            lineHeight: 1.8
          }}
        >
          Build Hybrid AI 2026
          <br />
          iOS + Web
        </div>

        <div
          style={{
            position: "absolute",
            left: 92,
            top: 260,
            width: 870
          }}
        >
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker>A ride that keeps its own secrets</Kicker>
          </div>
          <div
            style={{
              marginTop: 30,
              fontFamily: FONT,
              fontSize: 154,
              lineHeight: 0.88,
              letterSpacing: "-.075em",
              fontWeight: 660,
              color: C.ink
            }}
          >
            <div style={{ ...rise(frame, 10, 22) }}>Every ride.</div>
            <div
              style={{
                ...rise(frame, 18, 22),
                color: C.skyDeep,
                display: "flex",
                alignItems: "center",
                gap: 24
              }}
            >
              On record.
              <span
                style={{
                  display: "inline-block",
                  width: 74,
                  height: 74,
                  borderRadius: 999,
                  border: `1px solid rgba(0,132,209,.22)`,
                  background: "rgba(223,242,254,.78)",
                  color: C.skyDeep,
                  transform: `rotate(${frame * 0.25}deg)`,
                  marginTop: 10
                }}
              >
                <ArrowUpRight size={52} strokeWidth={1.6} style={{ margin: 11 }} />
              </span>
            </div>
          </div>
          <div
            style={{
              ...rise(frame, 30, 22),
              marginTop: 34,
              maxWidth: 700,
              fontFamily: FONT,
              fontSize: 29,
              lineHeight: 1.38,
              letterSpacing: "-.025em",
              color: C.muted
            }}
          >
            A private record of where you were — and proof you can share.
            <span style={{ color: C.ink, fontWeight: 600 }}> Without giving away the route.</span>
          </div>
          <div
            style={{
              ...rise(frame, 42, 22),
              marginTop: 44,
              display: "flex",
              gap: 10,
              flexWrap: "wrap"
            }}
          >
            <SourcePill
              label="On-device first"
              icon={<Sparkles size={15} strokeWidth={2} />}
            />
            <SourcePill
              label="Raw data stays local"
              tone="ink"
              icon={<LockKeyhole size={15} strokeWidth={2} />}
            />
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            right: 92,
            top: 168,
            width: 760,
            height: 720,
            borderRadius: 40,
            background:
              "linear-gradient(160deg, rgba(255,255,255,.92), rgba(255,255,255,.48))",
            border: "1px solid rgba(255,255,255,.9)",
            boxShadow:
              "0 40px 100px rgba(0,132,209,.10), inset 0 0 0 1px rgba(229,229,229,.65)",
            overflow: "hidden",
            transform: `translateY(${Math.sin(frame / 100) * 7}px)`
          }}
        >
          <div
            style={{
              position: "absolute",
              inset: 0,
              opacity: 0.85,
              background:
                "radial-gradient(ellipse 60% 50% at 72% 30%, rgba(0,166,244,.14), transparent 70%), radial-gradient(ellipse 80% 40% at 30% 100%, rgba(223,242,254,.7), transparent 70%)"
            }}
          />
          <div
            style={{
              position: "absolute",
              inset: 26,
              borderRadius: 26,
              border: "1px solid rgba(23,23,23,.07)",
              backgroundImage:
                "linear-gradient(rgba(23,23,23,.055) 1px, transparent 1px), linear-gradient(90deg, rgba(23,23,23,.055) 1px, transparent 1px)",
              backgroundSize: "68px 68px",
              maskImage:
                "radial-gradient(ellipse 90% 80% at 50% 50%, black 0%, transparent 86%)"
            }}
          />
          <svg
            viewBox="0 0 760 620"
            width={760}
            height={620}
            style={{ position: "absolute", left: 0, top: 44 }}
            fill="none"
          >
            <defs>
              <linearGradient id="intro-route" x1="90" y1="430" x2="710" y2="200">
                <stop offset="0%" stopColor={C.sky} />
                <stop offset="100%" stopColor={C.skyDeep} />
              </linearGradient>
              <filter id="route-glow" x="-50%" y="-50%" width="200%" height="200%">
                <feGaussianBlur stdDeviation="12" />
              </filter>
            </defs>
            <path
              d="M110 440 C210 430 225 350 280 250 C340 140 455 90 550 170 C610 220 610 330 652 378 C675 405 700 411 725 406"
              stroke="rgba(0,166,244,.14)"
              strokeWidth="34"
              strokeLinecap="round"
              strokeDasharray="1180"
              strokeDashoffset={1180 * (1 - route)}
              filter="url(#route-glow)"
            />
            <path
              d="M110 440 C210 430 225 350 280 250 C340 140 455 90 550 170 C610 220 610 330 652 378 C675 405 700 411 725 406"
              stroke="url(#intro-route)"
              strokeWidth="10"
              strokeLinecap="round"
              strokeDasharray="1180"
              strokeDashoffset={1180 * (1 - route)}
            />
            <circle
              cx="110"
              cy="440"
              r="13"
              fill={C.sky}
              opacity={Math.min(1, route * 3)}
            />
            <circle
              cx="725"
              cy="406"
              r="21"
              fill="rgba(255,255,255,.9)"
              stroke={C.skyDeep}
              strokeWidth="5"
              opacity={dot}
            />
            <circle
              cx="725"
              cy="406"
              r={9 + Math.sin(frame / 12) * 1.3}
              fill={C.skyDeep}
              opacity={dot}
            />
          </svg>

          <div
            style={{
              position: "absolute",
              left: 48,
              top: 54,
              fontFamily: MONO,
              fontSize: 12,
              letterSpacing: ".13em",
              color: C.subtle,
              textTransform: "uppercase"
            }}
          >
            A private route
          </div>
          <div
            style={{
              position: "absolute",
              right: 42,
              top: 48,
              display: "flex",
              alignItems: "center",
              gap: 7,
              borderRadius: 999,
              padding: "8px 11px",
              background: "rgba(255,255,255,.74)",
              border: "1px solid rgba(229,229,229,.8)",
              fontFamily: FONT,
              fontSize: 13,
              color: C.muted
            }}
          >
            <LockKeyhole size={14} strokeWidth={2} />
            local
          </div>
          <div
            style={{
              position: "absolute",
              left: 52,
              bottom: 70,
              display: "flex",
              flexDirection: "column",
              gap: 16
            }}
          >
            {[
              ["GPS", "stays here"],
              ["Motion", "stays here"],
              ["Moments", "stay here"]
            ].map(([label, value], index) => (
              <div
                key={label}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 12,
                  opacity: Math.min(1, route * 2.2 - index * 0.25)
                }}
              >
                <div
                  style={{
                    width: 6,
                    height: 6,
                    borderRadius: 99,
                    background: C.sky
                  }}
                />
                <span
                  style={{
                    fontFamily: FONT,
                    fontSize: 16,
                    fontWeight: 630,
                    color: C.ink,
                    width: 82
                  }}
                >
                  {label}
                </span>
                <span
                  style={{
                    fontFamily: MONO,
                    fontSize: 10,
                    letterSpacing: ".08em",
                    textTransform: "uppercase",
                    color: C.subtle
                  }}
                >
                  {value}
                </span>
              </div>
            ))}
          </div>
          <div
            style={{
              position: "absolute",
              right: 46,
              bottom: 60,
              fontFamily: FONT,
              fontSize: 13,
              color: C.muted,
              textAlign: "right",
              lineHeight: 1.6
            }}
          >
            <span style={{ color: C.ink, fontWeight: 600 }}>Proof on demand</span>
            <br />
            Not surveillance.
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            left: 92,
            bottom: 60,
            display: "flex",
            gap: 40,
            alignItems: "center",
            color: C.subtle,
            fontFamily: MONO,
            fontSize: 11,
            letterSpacing: ".11em",
            textTransform: "uppercase",
            opacity: reveal(frame, 62, 20)
          }}
        >
          <span>Built with Firebase AI Logic</span>
          <span style={{ width: 44, height: 1, background: C.line }} />
          <span>Firebase App Check</span>
        </div>
      </Backdrop>
    </AbsoluteFill>
  );
};
