import { KokoroTTS } from "kokoro-js";
import fs from "node:fs/promises";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const script = JSON.parse(await fs.readFile(path.join(root, "script.json"), "utf8"));
const voice = process.env.KOKORO_VOICE ?? "af_heart";
const out = path.join(root, "public", "audio", "kokoro");
await fs.mkdir(out, { recursive: true });

const model = await KokoroTTS.from_pretrained("onnx-community/Kokoro-82M-v1.0-ONNX", {
  dtype: "q8",
  device: "cpu"
});

for (const scene of script.scenes) {
  console.log(`generating ${scene.id}`);
  const audio = await model.generate(scene.narration, { voice });
  await audio.save(path.join(out, `${scene.id}.wav`));
}
console.log(`voiceover generated with ${voice}`);
