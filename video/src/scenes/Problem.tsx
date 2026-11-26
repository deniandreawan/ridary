import React from "react";
import { AbsoluteFill, Easing, interpolate, useCurrentFrame } from "remotion";
import {
  ArrowRight,
  Cloud,
  Fingerprint,
  LockKeyhole,
  MapPin,
  ShieldCheck,
  Smartphone,
  Sparkles
} from "lucide-react";
import { Backdrop } from "../components/Backdrop";
import { BrandMark } from "../components/BrandMark";
import { Chapter, Hairline, Kicker, Micro, SourcePill } from "../components/Type";
import { C, FONT, MONO } from "../theme";
import { clamp, fade, rise } from "../lib/motion";

export const Problem: React.FC = () => {
  const frame = useCurrentFrame();
  const boundary = interpolate(frame, [80, 160], [0, 1], {
    ...clamp,
    easing: Easing.bezier(0.22, 1, 0.36, 1)
  });
  const summary = interpolate(frame, [250, 340], [0, 1], {
    ...clamp,
    easing: Easing.bezier(0.22, 1, 0.36, 1)
  });

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
          <Chapter index="00" label="The trust boundary" />
        </div>

        <div style={{ position: "absolute", left: 92, top: 210, width: 840 }}>
          <div style={{ ...rise(frame, 4, 20) }}>
            <Kicker>Privacy is the product</Kicker>
          </div>
          <div
            style={{
              marginTop: 28,
              fontFamily: FONT,
              fontSize: 88,
              lineHeight: 1.01,
              letterSpacing: "-.065em",
              fontWeight: 650,
              color: C.ink
            }}
          >
            <div style={{ ...rise(frame, 10, 22) }}>Your route is the</div>
            <div style={{ ...rise(frame, 17, 22) }}>most sensitive</div>
            <div style={{ ...rise(frame, 24, 22), color: C.skyDeep }}>
              data you own.
            </div>
          </div>
          <div
            style={{
              ...rise(frame, 34, 22),
              marginTop: 32,
              width: 660,
              fontFamily: FONT,
              fontSize: 25,
              lineHeight: 1.47,
              letterSpacing: "-.02em",
              color: C.muted
            }}
          >
            It reveals home, work, habits, and the moments that went wrong.
            Sending it to a server first is a design choice — and a bad one.
          </div>
          <div
            style={{
              ...rise(frame, 48, 22),
              marginTop: 40,
              display: "flex",
              alignItems: "center",
              gap: 12
            }}
          >
            <SourcePill
              label="Raw data stays on the iPhone"
              tone="ink"
              icon={<LockKeyhole size={15} strokeWidth={2} />}
            />
            <SourcePill
              label="Only derived context leaves"
              icon={<Sparkles size={15} strokeWidth={2} />}
            />
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            right: 92,
            top: 178,
            width: 790,
            height: 724,
            borderRadius: 34,
            border: "1px solid rgba(255,255,255,.92)",
            background: "rgba(255,255,255,.54)",
            boxShadow: "0 36px 80px rgba(23,23,23,.06)",
            overflow: "hidden"
          }}
        >
          <div
            style={{
              position: "absolute",
              top: 26,
              left: 30,
              right: 30,
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center"
            }}
          >
            <Micro>Old model / upload first</Micro>
            <Micro style={{ color: C.safety }}>raw route</Micro>
          </div>

          <div
            style={{
              position: "absolute",
              left: 30,
              right: 30,
              top: 66,
              height: 286,
              borderRadius: 24,
              background:
                "linear-gradient(145deg, rgba(251,44,54,.075), rgba(255,255,255,.5))",
              border: "1px solid rgba(251,44,54,.12)",
              padding: 24
            }}
          >
            <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
              <div
                style={{
                  width: 42,
                  height: 42,
                  borderRadius: 999,
                  background: "rgba(251,44,54,.10)",
                  color: C.safety,
                  display: "grid",
                  placeItems: "center"
                }}
              >
                <Cloud size={22} strokeWidth={1.8} />
              </div>
              <div>
                <div style={{ fontFamily: FONT, fontSize: 18, fontWeight: 650, color: C.ink }}>
                  Upload the ride
                </div>
                <Micro style={{ marginTop: 3 }}>the cloud sees everything</Micro>
              </div>
            </div>
            <div style={{ marginTop: 23, display: "flex", flexDirection: "column", gap: 10 }}>
              {[
                ["GPS track", "every turn, every stop"],
                ["Motion window", "accelerometer + gyro"],
                ["Incident notes", "the sensitive context"]
              ].map(([label, detail], index) => (
                <div
                  key={label}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    padding: "9px 12px",
                    borderRadius: 12,
                    background: "rgba(255,255,255,.55)",
                    opacity: fade(frame, 18 + index * 8, 16)
                  }}
                >
                  <span
                    style={{
                      fontFamily: FONT,
                      fontSize: 15,
                      fontWeight: 600,
                      color: C.ink
                    }}
                  >
                    {label}
                  </span>
                  <span
                    style={{
                      fontFamily: MONO,
                      fontSize: 9,
                      letterSpacing: ".08em",
                      color: C.safety,
                      textTransform: "uppercase"
                    }}
                  >
                    {detail}
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div
            style={{
              position: "absolute",
              left: 56,
              right: 56,
              top: 366,
              height: 1,
              background: C.line
            }}
          />

          <div
            style={{
              position: "absolute",
              left: 30,
              right: 30,
              top: 392,
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center"
            }}
          >
            <Micro>Ridary / reason first</Micro>
            <Micro style={{ color: C.skyDeep }}>trust boundary</Micro>
          </div>

          <div
            style={{
              position: "absolute",
              left: 30,
              right: 30,
              top: 434,
              height: 236,
              borderRadius: 24,
              background:
                "linear-gradient(145deg, rgba(223,242,254,.95), rgba(255,255,255,.72))",
              border: "1px solid rgba(0,166,244,.16)",
              padding: 24
            }}
          >
            <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
              <div
                style={{
                  width: 42,
                  height: 42,
                  borderRadius: 999,
                  background: "rgba(255,255,255,.8)",
                  color: C.skyDeep,
                  display: "grid",
                  placeItems: "center"
                }}
              >
                <Smartphone size={21} strokeWidth={1.8} />
              </div>
              <div>
                <div style={{ fontFamily: FONT, fontSize: 18, fontWeight: 650, color: C.ink }}>
                  Reason locally
                </div>
                <Micro style={{ marginTop: 3 }}>the record stays put</Micro>
              </div>
            </div>
            <div
              style={{
                marginTop: 20,
                display: "flex",
                gap: 10,
                alignItems: "center"
              }}
            >
              <div
                style={{
                  flex: 1,
                  display: "flex",
                  flexDirection: "column",
                  gap: 8
                }}
              >
                {[
                  [MapPin, "GPS", "local"],
                  [Fingerprint, "Motion", "local"],
                  [ShieldCheck, "Evidence", "local"]
                ].map(([Icon, label, value], index) => {
                  const RowIcon = Icon as React.ComponentType<{
                    size?: number;
                    strokeWidth?: number;
                  }>;
                  return (
                    <div
                      key={label as string}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: 9,
                        fontFamily: FONT,
                        fontSize: 14,
                        color: C.ink,
                        opacity: fade(frame, 38 + index * 7, 16)
                      }}
                    >
                      <RowIcon size={15} strokeWidth={1.9} />
                      <span style={{ fontWeight: 600 }}>{label as string}</span>
                      <span
                        style={{
                          marginLeft: "auto",
                          fontFamily: MONO,
                          fontSize: 9,
                          letterSpacing: ".08em",
                          color: C.subtle,
                          textTransform: "uppercase"
                        }}
                      >
                        {value as string}
                      </span>
                    </div>
                  );
                })}
              </div>
              <div
                style={{
                  width: 1,
                  height: 120,
                  background: "rgba(0,132,209,.18)",
                  position: "relative"
                }}
              >
                <div
                  style={{
                    position: "absolute",
                    left: -5,
                    top: "44%",
                    width: 11,
                    height: 11,
                    borderRadius: 999,
                    background: C.sky,
                    transform: `translateY(${Math.sin(frame / 15) * 4}px)`,
                    opacity: summary
                  }}
                />
              </div>
              <div
                style={{
                  width: 190,
                  borderRadius: 14,
                  border: "1px solid rgba(0,132,209,.15)",
                  background: "rgba(255,255,255,.66)",
                  padding: "12px 12px",
                  opacity: summary,
                  transform: `translateX(${(1 - summary) * 8}px)`
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <Sparkles size={14} color={C.skyDeep} />
                  <Micro style={{ color: C.skyDeep }}>Derived summary</Micro>
                </div>
                <div
                  style={{
                    marginTop: 7,
                    fontFamily: FONT,
                    fontSize: 15,
                    lineHeight: 1.3,
                    fontWeight: 600,
                    color: C.ink
                  }}
                >
                  score · period · signature
                </div>
                <div
                  style={{
                    marginTop: 5,
                    fontFamily: MONO,
                    fontSize: 9,
                    letterSpacing: ".07em",
                    color: C.subtle,
                    textTransform: "uppercase"
                  }}
                >
                  no raw route
                </div>
              </div>
            </div>
          </div>

          <div
            style={{
              position: "absolute",
              left: 30,
              right: 30,
              bottom: 24,
              display: "flex",
              alignItems: "center",
              gap: 12
            }}
          >
            <div style={{ height: 1, flex: 1, background: C.line }} />
            <Micro>Privacy is the architecture</Micro>
            <div style={{ height: 1, flex: 1, background: C.line }} />
          </div>
          <div
            style={{
              position: "absolute",
              left: 30,
              width: `${boundary * 100}%`,
              top: 344,
              height: 2,
              background: `linear-gradient(90deg, ${C.skySoft}, ${C.sky}, ${C.skyDeep})`,
              opacity: 0.8
            }}
          />
        </div>

        <div
          style={{
            position: "absolute",
            right: 108,
            bottom: 48,
            display: "flex",
            alignItems: "center",
            gap: 54,
            opacity: fade(frame, 300, 20)
          }}
        >
          <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
            <ArrowRight size={16} color={C.safety} />
            <Micro>old: upload first</Micro>
          </div>
          <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
            <ArrowRight size={16} color={C.skyDeep} />
            <Micro>Ridary: reason first</Micro>
          </div>
        </div>
      </Backdrop>
    </AbsoluteFill>
  );
};
