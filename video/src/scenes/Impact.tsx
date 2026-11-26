import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import {
  ArrowUpRight,
  CameraOff,
  Car,
  MicOff,
  ShieldCheck,
  Sparkles,
  Users
} from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { Chapter, Hairline, Kicker, Micro } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { fade, rise } from "../lib/motion";

const outcomes = [
  {
    icon: Users,
    label: "Riders",
    title: "A voice",
    copy: "A private record of what happened, owned by the person who was there."
  },
  {
    icon: Car,
    label: "Cities",
    title: "A signal",
    copy: "Aggregate risk patterns that show where the road asks for attention."
  },
  {
    icon: ShieldCheck,
    label: "Insurers",
    title: "A proof",
    copy: "A signed safety band that verifies the pattern without exposing the route."
  }
] as const;

export const Impact: React.FC = () => {
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
          <Chapter index="07" label="What changes" />
        </div>

        <div style={{ position: "absolute", left: 92, top: 184, width: 1400 }}>
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker>Privacy-first safety, at the edge</Kicker>
          </div>
          <div
            style={{
              marginTop: 24,
              fontFamily: FONT,
              fontSize: 96,
              lineHeight: 0.95,
              letterSpacing: "-.072em",
              fontWeight: 650,
              color: C.ink
            }}
          >
            <div style={{ ...rise(frame, 10, 22) }}>
              A private witness for{" "}
              <span style={{ color: C.skyDeep }}>every ride.</span>
            </div>
          </div>
          <div
            style={{
              ...rise(frame, 26, 22),
              marginTop: 26,
              width: 780,
              fontFamily: FONT,
              fontSize: 25,
              lineHeight: 1.5,
              letterSpacing: "-.02em",
              color: C.muted
            }}
          >
            The smartphone already knows what happened. Ridary makes that
            knowledge useful without turning the rider into the product.
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            left: 92,
            right: 92,
            top: 546,
            display: "flex",
            gap: 20
          }}
        >
          {outcomes.map((outcome, index) => {
            const Icon = outcome.icon;
            return (
              <div
                key={outcome.label}
                style={{
                  flex: 1,
                  minHeight: 268,
                  borderRadius: 26,
                  background: "rgba(255,255,255,.72)",
                  border: "1px solid rgba(255,255,255,.94)",
                  boxShadow: "0 24px 60px rgba(23,23,23,.06)",
                  padding: "26px 28px",
                  display: "flex",
                  flexDirection: "column",
                  opacity: fade(frame, 44 + index * 12, 22),
                  transform: `translateY(${(1 - fade(frame, 44 + index * 12, 22)) * 14}px)`
                }}
              >
                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between"
                  }}
                >
                  <div
                    style={{
                      width: 42,
                      height: 42,
                      borderRadius: 999,
                      background: "rgba(223,242,254,.9)",
                      color: C.skyDeep,
                      display: "grid",
                      placeItems: "center"
                    }}
                  >
                    <Icon size={20} strokeWidth={1.8} />
                  </div>
                  <Micro>{outcome.label}</Micro>
                </div>
                <div
                  style={{
                    marginTop: 22,
                    fontFamily: FONT,
                    fontSize: 42,
                    letterSpacing: "-.055em",
                    fontWeight: 650,
                    color: C.ink
                  }}
                >
                  {outcome.title}
                </div>
                <div
                  style={{
                    marginTop: 12,
                    fontFamily: FONT,
                    fontSize: 17,
                    lineHeight: 1.45,
                    letterSpacing: "-.015em",
                    color: C.muted
                  }}
                >
                  {outcome.copy}
                </div>
                <div
                  style={{
                    marginTop: "auto",
                    paddingTop: 20,
                    display: "flex",
                    alignItems: "center",
                    gap: 7,
                    color: C.skyDeep,
                    fontFamily: MONO,
                    fontSize: 9,
                    letterSpacing: ".08em",
                    textTransform: "uppercase"
                  }}
                >
                  <Sparkles size={12} />
                  Private by design
                </div>
              </div>
            );
          })}
        </div>

        <div
          style={{
            position: "absolute",
            left: 92,
            right: 92,
            bottom: 150,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            opacity: fade(frame, 100, 24)
          }}
        >
          <div style={{ display: "flex", gap: 24, alignItems: "center" }}>
            {[
              [CameraOff, "No camera"],
              [MicOff, "No audio"],
              [ShieldCheck, "No automatic dispatch"]
            ].map(([Icon, label]) => {
              const IconComponent = Icon as React.ComponentType<{
                size?: number;
                strokeWidth?: number;
              }>;
              return (
                <div
                  key={label as string}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 8,
                    fontFamily: MONO,
                    fontSize: 10,
                    letterSpacing: ".08em",
                    textTransform: "uppercase",
                    color: C.muted
                  }}
                >
                  <IconComponent size={14} strokeWidth={1.8} />
                  {label as string}
                </div>
              );
            })}
          </div>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 8,
              color: C.ink,
              fontFamily: FONT,
              fontSize: 17,
              fontWeight: 600,
              letterSpacing: "-.02em"
            }}
          >
            Proof, not surveillance.
            <ArrowUpRight size={18} color={C.skyDeep} />
          </div>
        </div>
      </Backdrop>
    </AbsoluteFill>
  );
};
