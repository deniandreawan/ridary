import { KokoroTTS } from "kokoro-js";
import fs from "node:fs/promises";
import path from "node:path";

const out = path.resolve(import.meta.dirname, "..", "public", "audio", "kokoro");
await fs.mkdir(out, { recursive: true });

const model = await KokoroTTS.from_pretrained("onnx-community/Kokoro-82M-v1.0-ONNX", {
  dtype: "q8",
  device: "cpu"
});
const text =
  "Every ride. On record. Ridary keeps the sensitive parts on your phone, then turns them into proof you can share.";
const voices = ["af_heart", "am_michael", "bf_emma", "bm_george"];
for (const voice of voices) {
  console.log("generating", voice);
  const audio = await model.generate(text, { voice });
  await audio.save(path.join(out, `${voice}.wav`));
  console.log("saved", voice);
}
