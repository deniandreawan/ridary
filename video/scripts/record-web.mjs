import { chromium } from "playwright";
import fs from "node:fs/promises";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const recordings = path.join(root, "public", "recordings");
const raw = path.join(root, ".raw");
await fs.mkdir(recordings, { recursive: true });
await fs.mkdir(raw, { recursive: true });

const executablePath =
  process.env.CHROME_PATH ??
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

const base = "https://ridary-demo.web.app";

const delay = (page, ms) => page.waitForTimeout(ms);

async function newRecordingPage() {
  const browser = await chromium.launch({
    executablePath,
    headless: true,
    args: ["--use-angle=metal", "--hide-scrollbars"]
  });
  const context = await browser.newContext({
    viewport: { width: 1600, height: 900 },
    deviceScaleFactor: 1,
    recordVideo: { dir: raw, size: { width: 1600, height: 900 } }
  });
  const page = await context.newPage();
  return { browser, context, page };
}

async function saveVideo(context, page, name) {
  const video = page.video();
  await context.close();
  await new Promise((resolve) => setTimeout(resolve, 600));
  const source = await video.path();
  const target = path.join(recordings, `${name}.webm`);
  await fs.copyFile(source, target);
  console.log(`saved ${target}`);
}

async function dashboard() {
  const { browser, context, page } = await newRecordingPage();
  await page.goto(`${base}/app?demo=1`, { waitUntil: "domcontentloaded" });
  await delay(page, 14000);
  await page.mouse.move(1180, 480);
  await delay(page, 800);
  const risk = page.getByRole("button", { name: "risk", exact: true });
  if (await risk.count()) {
    await risk.click();
    await delay(page, 6500);
  }
  await page.mouse.move(980, 560);
  await page.mouse.wheel(0, 110);
  await delay(page, 2200);
  await page.mouse.wheel(0, -80);
  await delay(page, 2200);
  await page.screenshot({ path: path.join(recordings, "web-dashboard.png") });
  await saveVideo(context, page, "web-dashboard");
  await browser.close();
}

async function proof() {
  const { browser, context, page } = await newRecordingPage();
  await page.goto(`${base}/app/credential?demo=1`, { waitUntil: "domcontentloaded" });
  await delay(page, 4500);
  await page.mouse.move(800, 500);
  await delay(page, 600);
  const verify = page.getByRole("button", { name: /Verify signature/i });
  if (await verify.count()) {
    await verify.first().click();
    await delay(page, 2500);
  }
  await page.screenshot({ path: path.join(recordings, "web-proof.png") });
  await saveVideo(context, page, "web-proof");
  await browser.close();
}

async function insurer() {
  const { browser, context, page } = await newRecordingPage();
  await page.goto(`${base}/insurer/demo`, { waitUntil: "domcontentloaded" });
  await delay(page, 5000);
  await page.mouse.move(800, 430);
  await delay(page, 400);
  await page.mouse.wheel(0, 420);
  await delay(page, 800);
  await page.mouse.wheel(0, -220);
  await delay(page, 600);
  await page.screenshot({ path: path.join(recordings, "web-insurer.png") });
  await saveVideo(context, page, "web-insurer");
  await browser.close();
}

async function landing() {
  const { browser, context, page } = await newRecordingPage();
  await page.goto(`${base}/`, { waitUntil: "domcontentloaded" });
  await delay(page, 2500);
  await page.mouse.wheel(0, 650);
  await delay(page, 1200);
  await page.mouse.wheel(0, 700);
  await delay(page, 1200);
  await page.mouse.wheel(0, 700);
  await delay(page, 1200);
  await page.screenshot({ path: path.join(recordings, "web-landing.png") });
  await saveVideo(context, page, "web-landing");
  await browser.close();
}

const scenes = { dashboard, proof, insurer, landing };
const scene = process.argv[2];
if (!scene || !scenes[scene]) {
  console.error("Usage: node scripts/record-web.mjs <dashboard|proof|insurer|landing>");
  process.exit(1);
}
await scenes[scene]();
