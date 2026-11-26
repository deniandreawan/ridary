export const W = 1920;
export const H = 1080;
export const FPS = 30;

export const C = {
  canvas: "#fafafa",
  canvasSoft: "#f5f5f5",
  ink: "#171717",
  inkSoft: "#f5f5f5",
  card: "#ffffff",
  line: "#e5e5e5",
  muted: "#737373",
  subtle: "#a1a1a1",
  sky: "#00a6f4",
  skyDeep: "#0084d1",
  skySoft: "#dff2fe",
  accent: "#0084d1",
  accentStrong: "#006eb0",
  safety: "#fb2c36",
  danger: "#e7000b",
  warning: "#e17100",
  teal: "#0084d1",
  night: "#0b0b0d",
  nightSoft: "#151518",
  nightLine: "rgba(255,255,255,0.10)",
  white: "#ffffff"
} as const;

export const FONT =
  '-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Helvetica Neue", sans-serif';

export const MONO =
  '"SF Mono", "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, monospace';

export const EASE = [0.22, 1, 0.36, 1] as const;

export const pad = (n: number) => String(n).padStart(2, "0");

export const abs = (path: string) => {
  return path;
};
