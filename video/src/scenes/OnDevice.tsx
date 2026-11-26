import React from "react";
import {
  AbsoluteFill,
  OffthreadVideo,
  staticFile,
  useCurrentFrame
} from "remotion";
import {
  BrainCircuit,
  CloudOff,
  Cpu,
  Fingerprint,
  LockKeyhole,
  Smartphone,
  Sparkles
} from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { DeviceFrame } from "../components/DeviceFrame";
import { Chapter, Hairline, Kicker, Micro, SourcePill, Stat } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { fade, rise, scaleIn } from "../lib/motion";

export const OnDevice: React.FC = () => {
  const frame = useCurrentFrame();

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
          <Chapter index="02" label="Reason on device" dark />
        </div>

        <div
          style={{
            position: "absolute",
            left: 92,
            top: 210,
            width: 780
          }}
        >
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker dark color={C.sky}>
              Sensitive reasoning, at the edge
            </Kicker>
          </div>
          <div
            style={{
              marginTop: 24,
              fontFamily: FONT,
              fontSize: 148,
              lineHeight: 0.9,
              letterSpacing: "-.08em",
              fontWeight: 660,
              color: C.white
            }}
          >
            <div style={{ ...rise(frame, 12, 22) }}>On</div>
            <div style={{ ...rise(frame, 20, 22), color: C.sky }}>device.</div>
          </div>
          <div
            style={{
              ...rise(frame, 34, 22),
              marginTop: 30,
              width: 610,
              fontFamily: FONT,
              fontSize: 26,
              lineHeight: 1.5,
              letterSpacing: "-.02em",
              color: "rgba(255,255,255,.64)"
            }}
          >
            Apple Foundation Models summarize the ride through Firebase AI
            Logic. The badge says <span style={{ color: C.white, fontWeight: 600 }}>On device</span>{" "}
            because the sensitive reasoning never leaves the phone.
          </div>

          <div
            style={{
              ...rise(frame, 48, 22),
              marginTop: 38,
              display: "flex",
              gap: 10,
              flexWrap: "wrap"
            }}
          >
            <SourcePill
              label="Apple Foundation Models"
              icon={<Cpu size={15} strokeWidth={1.9} />}
            />
            <SourcePill
              label="Firebase AI Logic"
              tone="soft"
              icon={<Sparkles size={15} strokeWidth={1.9} />}
            />
          </div>

          <div
            style={{
              ...rise(frame, 64, 22),
              marginTop: 42,
              display: "flex",
              gap: 38,
              alignItems: "flex-end"
            }}
          >
            <Stat value="84" label="Sample score" dark />
            <div style={{ height: 54, width: 1, background: C.nightLine }} />
            <Stat value="2" label="Risk moments" dark />
            <div style={{ height: 54, width: 1, background: C.nightLine }} />
            <Stat value="12.4 km" label="Sample ride" dark />
          </div>

          <div
            style={{
              ...rise(frame, 84, 22),
              marginTop: 36,
              display: "flex",
              alignItems: "center",
              gap: 10,
              color: "rgba(255,255,255,.38)",
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".09em",
              textTransform: "uppercase"
            }}
          >
            <CloudOff size={14} />
            If the model is unavailable, local rules answer — never a silent cloud upload.
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            right: 168,
            top: 108,
            ...scaleIn(frame, 8, 34),
            display: "flex",
            flexDirection: "column",
            alignItems: "center"
          }}
        >
          <div style={{ position: "relative" }}>
            <div
              style={{
                position: "absolute",
                inset: -36,
                borderRadius: 999,
                background:
                  "radial-gradient(circle, rgba(0,166,244,.25), rgba(0,166,244,0) 70%)",
                filter: "blur(18px)"
              }}
            />
            <DeviceFrame width={378}>
              <OffthreadVideo
                src={staticFile("recordings/ios-summary.mp4")}
                muted
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
              />
            </DeviceFrame>
            <div
              style={{
                position: "absolute",
                left: -76,
                top: 168,
                borderRadius: 18,
                border: "1px solid rgba(0,166,244,.22)",
                background: "rgba(9,13,17,.82)",
                boxShadow: "0 18px 50px rgba(0,0,0,.28)",
                padding: "12px 15px",
                display: "flex",
                alignItems: "center",
                gap: 9,
                opacity: fade(frame, 46, 20),
                transform: `translateX(${(1 - fade(frame, 46, 20)) * -10}px)`
              }}
            >
              <div
                style={{
                  width: 30,
                  height: 30,
                  borderRadius: 999,
                  background: "rgba(0,166,244,.16)",
                  color: C.sky,
                  display: "grid",
                  placeItems: "center"
                }}
              >
                <BrainCircuit size={16} strokeWidth={1.8} />
              </div>
              <div>
                <Micro style={{ color: C.sky }}>Inference source</Micro>
                <div
                  style={{
                    marginTop: 2,
                    fontFamily: FONT,
                    fontSize: 15,
                    fontWeight: 650,
                    color: C.white
                  }}
                >
                  On device
                </div>
              </div>
            </div>
            <div
              style={{
                position: "absolute",
                right: -38,
                bottom: 188,
                width: 96,
                height: 96,
                borderRadius: 999,
                background: "rgba(0,166,244,.12)",
                border: "1px solid rgba(0,166,244,.26)",
                display: "grid",
                placeItems: "center",
                color: C.sky,
                opacity: fade(frame, 62, 20)
              }}
            >
              <Fingerprint size={34} strokeWidth={1.4} />
            </div>
          </div>
          <div
            style={{
              marginTop: 18,
              display: "flex",
              alignItems: "center",
              gap: 7,
              color: "rgba(255,255,255,.38)",
              fontFamily: MONO,
              fontSize: 10,
              letterSpacing: ".09em",
              textTransform: "uppercase"
            }}
          >
            <LockKeyhole size={12} />
            Evidence stays local
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
            color: "rgba(255,255,255,.26)",
            fontFamily: MONO,
            fontSize: 10,
            letterSpacing: ".09em",
            textTransform: "uppercase"
          }}
        >
          <Smartphone size={13} />
          Sample ride · simulator
        </div>
      </Backdrop>
    </AbsoluteFill>
  );
};
