import {
  getGenerativeModel,
  InferenceMode,
  type HybridParams,
  type ModelParams
} from "firebase/ai";
import { promptTemplates } from "../generated/prompts";
import { ai } from "../firebase";
import type {
  AIMode,
  CommunityInsight,
  InferenceSource,
  Ride,
  RideEvent,
  RideSnapshot,
  RiskCell
} from "../types";
import { renderPrompt } from "./prompts";
import { localCommunityInsight, parseCommunityInsight } from "./communityInsight";
import { parseSnapshot } from "./snapshot";

export const CLOUD_MODEL = "gemini-3.5-flash-lite";

export interface AIResult {
  text: string;
  source: InferenceSource;
}

export interface SnapshotResult extends AIResult {
  snapshot: RideSnapshot | null;
}

function mapSource(value: string | undefined, mode: AIMode): InferenceSource {
  if (value === "on_device") return "on_device";
  if (value === "in_cloud") return "in_cloud";
  if (mode === "only_on_device" || mode === "prefer_on_device") {
    return "on_device";
  }
  if (mode === "only_in_cloud" || mode === "prefer_in_cloud") {
    return "in_cloud";
  }
  return "fallback";
}

export async function generateText(
  prompt: string,
  mode: AIMode
): Promise<AIResult> {
  if (!ai) {
    throw new Error("Firebase AI Logic is not configured.");
  }

  if (mode === "only_in_cloud") {
    const params: ModelParams = { model: CLOUD_MODEL };
    const model = getGenerativeModel(ai, params);
    const result = await model.generateContent(prompt);
    const response = result.response;
    return {
      text: response.text(),
      source: mapSource(response.inferenceSource, mode)
    };
  }

  const params: HybridParams = {
    mode: mode as InferenceMode,
    inCloudParams: { model: CLOUD_MODEL }
  };
  const model = getGenerativeModel(ai, params);
  const result = await model.generateContent(prompt);
  const response = result.response;
  return {
    text: response.text(),
    source: mapSource(response.inferenceSource, mode)
  };
}

export async function onDeviceAvailability(): Promise<string> {
  const globalWindow = globalThis as typeof globalThis & {
    LanguageModel?: { availability?: () => Promise<string> };
    ai?: { languageModel?: { availability?: () => Promise<string> } };
  };
  const languageModel =
    globalWindow.LanguageModel ?? globalWindow.ai?.languageModel;
  if (!languageModel?.availability) {
    return "unavailable";
  }
  try {
    return await languageModel.availability();
  } catch {
    return "unavailable";
  }
}

export async function generateRideSnapshot(
  ride: Ride,
  events: RideEvent[]
): Promise<SnapshotResult> {
  const prompt = renderPrompt(promptTemplates.rideSnapshot, {
    mode: ride.mode,
    ride_json: JSON.stringify({
      mode: ride.mode,
      startedAt: new Date(ride.startedAtMs).toISOString(),
      durationS: ride.durationS,
      distanceM: ride.distanceM,
      avgSpeedKph: ride.avgSpeedKph,
      maxSpeedKph: ride.maxSpeedKph,
      eventCount: events.length
    }),
    events_json: JSON.stringify(
      events.slice(0, 8).map((event) => ({
        type: event.type,
        severity: event.severity,
        confidence: event.confidence,
        atSeconds: Math.max(
          0,
          Math.round((event.occurredAtMs - ride.startedAtMs) / 1000)
        ),
        summary: event.summary
      }))
    )
  });

  const result = await generateText(prompt, "prefer_on_device");
  return {
    ...result,
    snapshot: parseSnapshot(result.text)
  };
}


export async function generateCommunityInsight(
  cells: RiskCell[]
): Promise<{ insight: CommunityInsight; source: InferenceSource }> {
  const payload = cells
    .slice(0, 24)
    .map((cell) => ({
      geohash: cell.geohash,
      mode: cell.mode,
      count: cell.count,
      severityAverage:
        cell.count > 0 ? Number((cell.severitySum / cell.count).toFixed(2)) : 0,
      topTypes: cell.topTypes
    }));

  const prompt = renderPrompt(promptTemplates.communityInsight, {
    cells_json: JSON.stringify(payload)
  });

  try {
    const result = await generateText(prompt, "only_in_cloud");
    return {
      insight: parseCommunityInsight(result.text) ?? localCommunityInsight(cells),
      source: result.source
    };
  } catch {
    return {
      insight: localCommunityInsight(cells),
      source: "fallback"
    };
  }
}
