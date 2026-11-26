import { Easing, interpolate, spring } from "remotion";
import { EASE, FPS } from "../theme";

export const clamp = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp"
} as const;

export function rise(frame: number, delay = 0, duration = 18) {
  const p = interpolate(frame - delay, [0, duration], [0, 1], {
    ...clamp,
    easing: Easing.bezier(...EASE)
  });
  return {
    opacity: p,
    transform: `translateY(${(1 - p) * 28}px)`
  };
}

export function fade(frame: number, start = 0, duration = 14) {
  return interpolate(frame - start, [0, duration], [0, 1], {
    ...clamp,
    easing: Easing.out(Easing.cubic)
  });
}

export function fadeOut(frame: number, at: number, duration = 14) {
  return interpolate(frame, [at, at + duration], [1, 0], {
    ...clamp,
    easing: Easing.in(Easing.cubic)
  });
}

export function scaleIn(frame: number, delay = 0, duration = 28) {
  const p = spring({
    frame: frame - delay,
    fps: FPS,
    config: { damping: 22, stiffness: 110, mass: 0.9 }
  });
  return {
    opacity: Math.min(1, p * 1.5),
    transform: `scale(${0.94 + p * 0.06})`
  };
}

export function reveal(frame: number, start = 0, duration = 26) {
  return interpolate(frame - start, [0, duration], [0, 1], {
    ...clamp,
    easing: Easing.bezier(...EASE)
  });
}

export function breathe(frame: number, offset = 0) {
  return Math.sin((frame + offset) / 38) * 0.5 + 0.5;
}

export function progress(frame: number, start: number, end: number) {
  return interpolate(frame, [start, end], [0, 1], clamp);
}
