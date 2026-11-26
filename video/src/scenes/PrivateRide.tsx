import React from "react";
import {
  AbsoluteFill,
  OffthreadVideo,
  Sequence,
  staticFile,
  useCurrentFrame
} from "remotion";
import {
  CameraOff,
  LockKeyhole,
  MapPin,
  MicOff,
  Radio,
  ShieldCheck,
  Smartphone
} from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { DeviceFrame } from "../components/DeviceFrame";
import { Chapter, Hairline, Kicker, Micro, SourcePill } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { fade, rise, scaleIn } from "../lib/motion";

const features = [
  {
    icon: MapPin,
    title: "GPS and motion",
    detail: "captured locally",
    tone: C.sky
  },
  {
    icon: CameraOff,
    title: "Camera and mic",
    detail: "off by design",
    tone: C.ink
  },
  {
    icon: Radio,
    title: "Ride upload",
    detail: "none",
    tone: C.ink
  }
] as const;

export const PrivateRide: React.FC = () => {
  const frame = useCurrentFrame();
  const sample = fade(frame, 380, 22);

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
          <Chapter index="01" label="Record privately" dark />
        </div>

        <div
          style={{
            position: "absolute",
            left: 92,
            top: 224,
            width: 790
          }}
        >
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker dark>Phone in pocket. Eyes on the road.</Kicker>
          </div>
          <div
            style={{
              marginTop: 28,
              fontFamily: FONT,
              fontSize: 94,
              lineHeight: 0.95,
              letterSpacing: "-.072em",
              fontWeight: 650,
              color: C.white
            }}
          >
            <div style={{ ...rise(frame, 10, 22) }}>The ride</div>
            <div style={{ ...rise(frame, 18, 22), color: C.sky }}>stays yours.</div>
          </div>
          <div
            style={{
              ...rise(frame, 30, 22),
              marginTop: 30,
              width: 650,
              fontFamily: FONT,
              fontSize: 25,
              lineHeight: 1.5,
              letterSpacing: "-.018em",
              color: "rgba(255,255,255,.62)"
            }}
          >
            One tap starts a private ride. The screen goes dark, the sensors
            stay local, and the deterministic detector watches for the moments
            that matter.
          </div>

          <div
            style={{
              marginTop: 44,
              display: "flex",
              flexDirection: "column",
              gap: 0,
              width: 610
            }}
          >
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div
                  key={feature.title}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 16,
                    padding: "17px 0",
                    borderTop: `1px solid ${C.nightLine}`,
                    opacity: fade(frame, 56 + index * 12, 20),
                    transform: `translateY(${(1 - fade(frame, 56 + index * 12, 20)) * 10}px)`
                  }}
                >
                  <div
                    style={{
                      width: 38,
                      height: 38,
                      borderRadius: 999,
                      display: "grid",
                      placeItems: "center",
                      background:
                        index === 0 ? "rgba(0,166,244,.17)" : "rgba(255,255,255,.07)",
                      color: index === 0 ? C.sky : "rgba(255,255,255,.6)"
                    }}
                  >
                    <Icon size={18} strokeWidth={1.8} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <div
                      style={{
                        fontFamily: FONT,
                        fontSize: 19,
                        fontWeight: 600,
                        color: C.white,
                        letterSpacing: "-.02em"
                      }}
                    >
                      {feature.title}
                    </div>
                    <div
                      style={{
                        marginTop: 3,
                        fontFamily: MONO,
                        fontSize: 10,
                        letterSpacing: ".09em",
                        textTransform: "uppercase",
                        color: "rgba(255,255,255,.36)"
                      }}
                    >
                      {feature.detail}
                    </div>
                  </div>
                  {index === 2 ? (
                    <LockKeyhole size={15} color={C.sky} strokeWidth={2} />
                  ) : (
                    <ShieldCheck
                      size={15}
                      color="rgba(255,255,255,.28)"
                      strokeWidth={1.8}
                    />
                  )}
                </div>
              );
            })}
            <Hairline dark style={{ marginTop: 2 }} />
          </div>

          <div
            style={{
              ...rise(frame, 106, 22),
              marginTop: 34,
              display: "flex",
              gap: 10,
              alignItems: "center"
            }}
          >
            <SourcePill
              label="Lock last 30 seconds"
              icon={<LockKeyhole size={14} strokeWidth={2} />}
            />
            <SourcePill
              label="No camera · no audio"
              tone="soft"
              icon={<CameraOff size={14} strokeWidth={2} />}
            />
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            right: 190,
            top: 98,
            ...scaleIn(frame, 14, 34)
          }}
        >
          <DeviceFrame width={370}>
            <Sequence from={0} durationInFrames={180} premountFor={30}>
              <OffthreadVideo
                src={staticFile("recordings/ios-home.mp4")}
                muted
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
              />
            </Sequence>
            <Sequence from={180} durationInFrames={180} premountFor={30}>
              <OffthreadVideo
                src={staticFile("recordings/ios-live-route.mp4")}
                muted
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
              />
            </Sequence>
            <Sequence from={360} durationInFrames={120} premountFor={30}>
              <OffthreadVideo
                src={staticFile("recordings/ios-timer.mp4")}
                muted
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
              />
            </Sequence>
            <Sequence from={480} durationInFrames={180} premountFor={30}>
              <OffthreadVideo
                src={staticFile("recordings/ios-lock.mp4")}
                muted
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
              />
            </Sequence>
          </DeviceFrame>
          <div
            style={{
              position: "absolute",
              left: 58,
              top: 660,
              width: 56,
              height: 56,
              borderRadius: 999,
              border: "2px solid rgba(0,166,244,.9)",
              background: "rgba(0,166,244,.16)",
              opacity: Math.max(0, Math.min(1, (frame - 420) / 8)) * Math.max(0, Math.min(1, (474 - frame) / 8)),
              transform: `scale(${0.75 + Math.max(0, Math.min(1, (frame - 416) / 22)) * 0.45})`,
              pointerEvents: "none"
            }}
          />
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginTop: 18,
              padding: "0 8px",
              opacity: sample
            }}
          >
            <Micro dark>Sample ride · simulator</Micro>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
                color: C.sky,
                fontFamily: MONO,
                fontSize: 10,
                letterSpacing: ".08em",
                textTransform: "uppercase"
              }}
            >
              <Smartphone size={12} />
              On this iPhone
            </div>
          </div>
        </div>

      </Backdrop>
    </AbsoluteFill>
  );
};
