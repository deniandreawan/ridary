import fs from "node:fs/promises";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const script = JSON.parse(await fs.readFile(path.join(root, "script.json"), "utf8"));

const stamp = (seconds) => {
  const ms = Math.round(seconds * 1000);
  const h = Math.floor(ms / 3_600_000);
  const m = Math.floor((ms % 3_600_000) / 60_000);
  const s = Math.floor((ms % 60_000) / 1000);
  const milli = ms % 1000;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")},${String(milli).padStart(3, "0")}`;
};

const captions = script.scenes.flatMap((scene) => scene.captions);
const srt = captions
  .map(([start, end, text], index) => `${index + 1}\n${stamp(start)} --> ${stamp(end)}\n${text}\n`)
  .join("\n");

await fs.writeFile(path.join(root, "captions.srt"), srt);

const guide = `# Ridary demo · voiceover guide

Record dry, close, and calm. WAV or M4A is fine; do not add music or effects.
The final cut is ${script.totalSeconds} seconds. Read at a measured pace and
leave the natural pauses at the end of each section.

${script.scenes
  .map(
    (scene) =>
      `## ${scene.id.toUpperCase()} · ${String(Math.floor(scene.start / 60)).padStart(2, "0")}:${String(scene.start % 60).padStart(2, "0")}–${String(Math.floor(scene.end / 60)).padStart(2, "0")}:${String(scene.end % 60).padStart(2, "0")}\n\n${scene.narration}\n`
  )
  .join("\n")}
## Pronunciation

Ridary: RID-uh-ree. Firebase: FIRE-base. Ed25519: E-D-25519.
`;
await fs.writeFile(path.join(root, "scripts", "voiceover.md"), guide);
console.log(`Wrote captions.srt (${captions.length} cues) and scripts/voiceover.md`);
