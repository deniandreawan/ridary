import React from "react";
import { Composition } from "remotion";
import { RidaryDemo } from "./RidaryDemo";
import { Thumbnail } from "./Thumbnail";
import { FPS, H, W } from "./theme";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="RidaryDemo"
        component={RidaryDemo}
        durationInFrames={162 * FPS}
        fps={FPS}
        width={W}
        height={H}
      />
      <Composition
        id="RidaryThumbnail"
        component={Thumbnail}
        durationInFrames={1}
        fps={30}
        width={1280}
        height={720}
      />
      <Composition
        id="RidaryThumbnailDevpost"
        component={Thumbnail}
        durationInFrames={1}
        fps={30}
        width={1200}
        height={800}
      />
    </>
  );
};
