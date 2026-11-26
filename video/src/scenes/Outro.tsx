import React from "react";
import { AbsoluteFill, Img, staticFile, useCurrentFrame } from "remotion";
import { ArrowUpRight, Globe2, LockKeyhole, Sparkles } from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { Kicker, Micro } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { fade, rise, scaleIn } from "../lib/motion";

export const Outro: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill>
      <Backdrop soft>
        <div
          style={{
            position: "absolute",
            inset: 0,
            opacity: fade(frame, 0, 18)
          }}
        >
          <div
            style={{
              position: "absolute",
              left: 92,
              top: 70,
              display: "flex",
              alignItems: "center",
              gap: 13
            }}
          >
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

          <div
            style={{
              position: "absolute",
              left: 92,
              top: 236,
              width: 1180
            }}
          >
            <div style={{ ...rise(frame, 4, 20) }}>
              <Kicker>Private by design. Proof on demand.</Kicker>
            </div>
            <div
              style={{
                marginTop: 26,
                fontFamily: FONT,
                fontSize: 142,
                lineHeight: 0.88,
                letterSpacing: "-.08em",
                fontWeight: 660,
                color: C.ink
              }}
            >
              <div style={{ ...rise(frame, 10, 22) }}>Every ride.</div>
              <div style={{ ...rise(frame, 18, 22), color: C.skyDeep }}>
                On record.
              </div>
            </div>
            <div
              style={{
                ...rise(frame, 30, 22),
                marginTop: 32,
                display: "flex",
                alignItems: "center",
                gap: 12
              }}
            >
              <div
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: 999,
                  background: "rgba(255,255,255,.85)",
                  border: "1px solid rgba(229,229,229,.9)",
                  display: "grid",
                  placeItems: "center",
                  color: C.skyDeep
                }}
              >
                <Globe2 size={21} strokeWidth={1.7} />
              </div>
              <div>
                <Micro>Live demo</Micro>
                <div
                  style={{
                    marginTop: 3,
                    fontFamily: FONT,
                    fontSize: 25,
                    fontWeight: 650,
                    letterSpacing: "-.03em",
                    color: C.ink
                  }}
                >
                  ridary-demo.web.app
                </div>
              </div>
              <ArrowUpRight size={20} color={C.skyDeep} style={{ marginLeft: 2 }} />
            </div>
          </div>

          <div
            style={{
              position: "absolute",
              right: 92,
              top: 186,
              ...scaleIn(frame, 12, 32)
            }}
          >
            <div
              style={{
                width: 390,
                height: 390,
                borderRadius: 88,
                background: "rgba(255,255,255,.42)",
                border: "1px solid rgba(255,255,255,.9)",
                boxShadow: "0 36px 90px rgba(0,132,209,.12)",
                display: "grid",
                placeItems: "center"
              }}
            >
              <Img
                src={staticFile("brand/icon.png")}
                style={{
                  width: 260,
                  height: 260,
                  borderRadius: 64,
                  boxShadow: "0 28px 60px rgba(0,132,209,.18)"
                }}
              />
            </div>
            <div
              style={{
                marginTop: 22,
                display: "flex",
                justifyContent: "space-between",
                width: 390,
                color: C.subtle,
                fontFamily: MONO,
                fontSize: 10,
                letterSpacing: ".1em",
                textTransform: "uppercase"
              }}
            >
              <span>iOS + web</span>
              <span>Build Hybrid AI 2026</span>
            </div>
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
              borderTop: `1px solid ${C.line}`,
              paddingTop: 20,
              color: C.subtle,
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".09em",
              textTransform: "uppercase",
              opacity: fade(frame, 44, 22)
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
              <span style={{ display: "flex", alignItems: "center", gap: 7 }}>
                <Sparkles size={13} color={C.skyDeep} />
                Apple Foundation Models
              </span>
              <span>Firebase AI Logic</span>
              <span>Firebase App Check</span>
            </div>
            <span style={{ display: "flex", alignItems: "center", gap: 7 }}>
              <LockKeyhole size={13} />
              Demo data · no real rider
            </span>
          </div>
        </div>
        <div
          style={{
            position: "absolute",
            inset: 0,
            background: C.white,
            opacity: 1 - fade(frame, 0, 12)
          }}
        />
      </Backdrop>
    </AbsoluteFill>
  );
};
