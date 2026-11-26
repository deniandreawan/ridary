import React from "react";
import {
  AbsoluteFill,
  OffthreadVideo,
  interpolate,
  staticFile,
  useCurrentFrame
} from "remotion";
import {
  BadgeCheck,
  Fingerprint,
  LockKeyhole,
  ShieldCheck,
  Signature,
  Sparkles
} from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { BrowserFrame } from "../components/BrowserFrame";
import { Chapter, Kicker, Micro, SourcePill } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { clamp, fade, rise, scaleIn } from "../lib/motion";

export const Proof: React.FC = () => {
  const frame = useCurrentFrame();
  const insurer = interpolate(frame, [230, 236], [0, 1], clamp);
  const insurerPill = fade(frame, 230, 20);

  return (
    <AbsoluteFill>
      <Backdrop dark>
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
            <BrandMark size={44} color={C.skySoft} />
            <span
              style={{
                fontFamily: FONT,
                fontSize: 19,
                fontWeight: 650,
                letterSpacing: "-.02em",
                color: C.white
              }}
            >
              Ridary
            </span>
          </div>
          <Chapter index="05" label="Prove, don’t expose" dark />
        </div>

        <div style={{ position: "absolute", left: 92, top: 206, width: 700 }}>
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker dark color={C.sky}>
              A signed safety band
            </Kicker>
          </div>
          <div
            style={{
              marginTop: 26,
              fontFamily: FONT,
              fontSize: 100,
              lineHeight: 0.92,
              letterSpacing: "-.075em",
              fontWeight: 650,
              color: C.white
            }}
          >
            <div style={{ ...rise(frame, 10, 22) }}>Proof,</div>
            <div style={{ ...rise(frame, 18, 22), color: C.sky }}>
              not surveillance.
            </div>
          </div>
          <div
            style={{
              ...rise(frame, 32, 22),
              marginTop: 30,
              width: 590,
              fontFamily: FONT,
              fontSize: 25,
              lineHeight: 1.5,
              letterSpacing: "-.02em",
              color: "rgba(255,255,255,.62)"
            }}
          >
            The insurer verifies the score, the period, and the Ed25519
            signature. They never see the route, the raw sensors, or the rider’s
            identity.
          </div>

          <div
            style={{
              ...rise(frame, 48, 22),
              marginTop: 40,
              display: "flex",
              flexDirection: "column",
              gap: 0,
              width: 600
            }}
          >
            {[
              [BadgeCheck, "Ed25519 signed", "issuer key"],
              [LockKeyhole, "Zero raw GPS", "excluded by design"],
              [Fingerprint, "No identity", "aggregate only"]
            ].map(([Icon, title, detail], index) => {
              const IconComponent = Icon as React.ComponentType<{
                size?: number;
                strokeWidth?: number;
                color?: string;
              }>;
              return (
                <div
                  key={title as string}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 13,
                    padding: "15px 0",
                    borderTop: `1px solid ${C.nightLine}`,
                    opacity: fade(frame, 64 + index * 11, 20)
                  }}
                >
                  <IconComponent size={17} color={C.sky} strokeWidth={1.8} />
                  <span
                    style={{
                      fontFamily: FONT,
                      fontSize: 17,
                      fontWeight: 600,
                      color: C.white,
                      letterSpacing: "-.015em"
                    }}
                  >
                    {title as string}
                  </span>
                  <span
                    style={{
                      marginLeft: "auto",
                      fontFamily: MONO,
                      fontSize: 9,
                      letterSpacing: ".08em",
                      textTransform: "uppercase",
                      color: "rgba(255,255,255,.32)"
                    }}
                  >
                    {detail as string}
                  </span>
                </div>
              );
            })}
          </div>

          <div
            style={{
              ...rise(frame, 118, 22),
              marginTop: 30,
              display: "flex",
              gap: 10
            }}
          >
            <SourcePill
              label="Signed by Ridary demo"
              icon={<Signature size={14} strokeWidth={2} />}
            />
            <SourcePill
              label="Valid for 90 days"
              tone="soft"
              icon={<ShieldCheck size={14} strokeWidth={2} />}
            />
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            right: 106,
            top: 292,
            ...scaleIn(frame, 12, 32)
          }}
        >
          <BrowserFrame width={995} url="ridary-demo.web.app/app/credential">
            <div style={{ width: "100%", height: "100%", position: "relative" }}>
              <OffthreadVideo
                src={staticFile("recordings/web-proof.mp4")}
                muted
                style={{
                  width: "100%",
                  height: "100%",
                  objectFit: "cover",
                  opacity: 1
                }}
              />
              <div
                style={{
                  position: "absolute",
                  inset: 0,
                  opacity: insurer
                }}
              >
                <OffthreadVideo
                  src={staticFile("recordings/web-insurer.mp4")}
                  muted
                    style={{ width: "100%", height: "100%", objectFit: "cover" }}
                />
              </div>
            </div>
          </BrowserFrame>
          <div
            style={{
              position: "absolute",
              left: 28,
              top: -18,
              display: "flex",
              alignItems: "center",
              gap: 8,
              borderRadius: 999,
              background: "rgba(9,13,17,.82)",
              border: "1px solid rgba(255,255,255,.15)",
              padding: "8px 13px",
              color: C.sky,
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".09em",
              textTransform: "uppercase"
            }}
          >
            <span style={{ width: 6, height: 6, borderRadius: 99, background: C.sky }} />
            Live proof
          </div>
          <div
            style={{
              position: "absolute",
              right: 28,
              top: -18,
              display: "flex",
              alignItems: "center",
              gap: 8,
              borderRadius: 999,
              background: "rgba(9,13,17,.82)",
              border: "1px solid rgba(255,255,255,.15)",
              padding: "8px 13px",
              color: C.white,
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".09em",
              textTransform: "uppercase",
              opacity: insurerPill
            }}
          >
            <Sparkles size={12} color={C.sky} />
            Insurer view
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            left: 96,
            bottom: 150,
            display: "flex",
            alignItems: "center",
            gap: 12,
            fontFamily: MONO,
            fontSize: 10,
            letterSpacing: ".09em",
            textTransform: "uppercase",
            color: "rgba(255,255,255,.28)"
          }}
        >
          <LockKeyhole size={12} />
          Personal safety credential · not legal advice
        </div>
      </Backdrop>
    </AbsoluteFill>
  );
};
