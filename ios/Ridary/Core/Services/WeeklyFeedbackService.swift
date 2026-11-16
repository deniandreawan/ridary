import Foundation

final class WeeklyFeedbackService {
    func generate(
        stats: WeeklyStatsResponse,
        ai: AIService
    ) async -> (WeeklyFeedback, InferenceSource) {
        guard !stats.rides.isEmpty else {
            return (
                WeeklyFeedback(
                    headline: "No rides this week",
                    summary: "Record a ride to unlock a weekly safety pattern.",
                    insights: [],
                    action: "Start a ride when you are ready."
                ),
                .deterministic
            )
        }

        do {
            let ridesJSON = try RidaryJSON.string(stats.rides)
            let eventsJSON = try RidaryJSON.string(stats.events)
            let weekStart = ISO8601DateFormatter().string(from: Date())
            let prompt = PromptTemplate.render(
                PromptTemplates.weeklyFeedback,
                values: [
                    "mode": stats.mode.rawValue,
                    "week_start": weekStart,
                    "rides_json": ridesJSON,
                    "events_json": eventsJSON,
                    "community_json": "[]"
                ]
            )
            let result = try await ai.generate(prompt: prompt, mode: .preferInCloud)
            let decoded = try AIJSON.decode(WeeklyFeedback.self, from: result.text)
            return (sanitize(decoded, fallback: stats), result.source)
        } catch {
            return (deterministic(for: stats), fallbackSource(for: error))
        }
    }

    private func sanitize(
        _ feedback: WeeklyFeedback,
        fallback: WeeklyStatsResponse
    ) -> WeeklyFeedback {
        let headline = feedback.headline.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = feedback.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let action = feedback.action.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !headline.isEmpty, !summary.isEmpty, !action.isEmpty else {
            return deterministic(for: fallback)
        }
        return WeeklyFeedback(
            headline: String(headline.prefix(100)),
            summary: String(summary.prefix(800)),
            insights: feedback.insights.prefix(3).map {
                String($0.trimmingCharacters(in: .whitespacesAndNewlines).prefix(200))
            },
            action: String(action.prefix(240))
        )
    }

    private func deterministic(for stats: WeeklyStatsResponse) -> WeeklyFeedback {
        let eventCounts = stats.events.reduce(into: [RideEventType: Int]()) {
            $0[$1.type, default: 0] += 1
        }
        let top = eventCounts.max { $0.value < $1.value }?.key
        let insights: [String]
        if let top {
            insights = [
                "Most flagged moment: \(top.title.lowercased()) (\(eventCounts[top] ?? 0)).",
                "Rides reviewed: \(stats.rides.count)."
            ]
        } else {
            insights = ["No safety moments were flagged this week."]
        }

        return WeeklyFeedback(
            headline: "Your week in review",
            summary: "You recorded \(stats.rides.count) ride(s) and \(stats.events.count) safety moment(s).",
            insights: insights,
            action: top == nil
                ? "Keep the same smooth habits next week."
                : "Review the \(top?.title.lowercased() ?? "flagged") moments before your next ride."
        )
    }

    private func fallbackSource(for error: Error) -> InferenceSource {
        if let aiError = error as? AIError, case .notConfigured = aiError {
            return .deterministic
        }
        return .fallback
    }
}
