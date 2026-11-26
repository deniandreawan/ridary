import React from "react";
import { AbsoluteFill, Audio, Series, staticFile } from "remotion";
import { CaptionTrack, ProgressRail } from "./components/Captions";
import { Ask } from "./scenes/Ask";
import { CloudMap } from "./scenes/CloudMap";
import { Impact } from "./scenes/Impact";
import { Intro } from "./scenes/Intro";
import { OnDevice } from "./scenes/OnDevice";
import { Outro } from "./scenes/Outro";
import { PrivateRide } from "./scenes/PrivateRide";
import { Problem } from "./scenes/Problem";
import { Proof } from "./scenes/Proof";
import { TrustBoundary } from "./scenes/TrustBoundary";

const scenes = [
  { component: Intro, frames: 360 },
  { component: Problem, frames: 480 },
  { component: PrivateRide, frames: 660 },
  { component: OnDevice, frames: 480 },
  { component: Ask, frames: 420 },
  { component: CloudMap, frames: 720 },
  { component: Proof, frames: 420 },
  { component: TrustBoundary, frames: 660 },
  { component: Impact, frames: 390 },
  { component: Outro, frames: 270 }
] as const;

export const RidaryDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: "#fafafa" }}>
      <Series>
        {scenes.map(({ component: Scene, frames }, index) => (
          <Series.Sequence key={index} durationInFrames={frames}>
            <Scene />
          </Series.Sequence>
        ))}
      </Series>
      <Audio src={staticFile("audio/voiceover.wav")} />
      <CaptionTrack />
      <ProgressRail />
    </AbsoluteFill>
  );
};
