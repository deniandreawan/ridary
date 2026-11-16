import Foundation

final class RideSummaryService {
    func enrich(_ ride: Ride, ai: AIService) async -> Ride {
        let events = promptEvents(for: ride)
        let ridePayload = RidePromptPayload(
            mode: ride.mode.rawValue,
            startedAt: ride.startedAt,
            durationS: ride.durationS,
            distanceM: ride.distanceM,
            avgSpeedKph: ride.avgSpeedKph,
            maxSpeedKph: ride.maxSpeedKph,
            eventCount: ride.events.count
        )

        do {
            let rideJSON = try RidaryJSON.string(ridePayload)
            let eventsJSON = try RidaryJSON.string(events)
            let prompt = PromptTemplate.render(
                PromptTemplates.rideSnapshot,
                values: [
                    "mode": ride.mode.rawValue,
                    "ride_json": rideJSON,
                    "events_json": eventsJSON
                ]
            )
            let result = try await ai.generate(prompt: prompt, mode: .preferOnDevice)
            let decoded = try AIJSON.decode(RideSnapshot.self, from: result.text)
            let snapshot = try validated(decoded, for: ride)

            var updated = ride
            updated.snapshot = snapshot
            updated.score = snapshot.score
            updated.summary = snapshot.summary
            updated.inferenceSource = result.source
            return updated
        } catch {
            var updated = ride
            let snapshot = deterministicSnapshot(for: ride)
            updated.snapshot = snapshot
            updated.score = snapshot.score
            updated.summary = snapshot.summary
            updated.inferenceSource = fallbackSource(for: error)
            return updated
        }
    }

    private func promptEvents(for ride: Ride) -> [EventPromptPayload] {
        ride.events
            .sorted {
                if $0.severity == $1.severity {
                    return $0.occurredAt < $1.occurredAt
                }
                return $0.severity > $1.severity
            }
            .prefix(8)
            .map { event in
                EventPromptPayload(
                    type: event.type.rawValue,
                    severity: event.severity,
                    confidence: event.confidence,
                    atSeconds: max(
                        0,
                        Int(event.occurredAt.timeIntervalSince(ride.startedAt))
                    ),
                    summary: event.summary
                )
            }
    }

    private func validated(_ snapshot: RideSnapshot, for ride: Ride) throws -> RideSnapshot {
        let headline = snapshot.headline.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = snapshot.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let rationale = snapshot.scoreRationale.trimmingCharacters(in: .whitespacesAndNewlines)
        let tip = snapshot.coachingTip.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !headline.isEmpty, !summary.isEmpty, !rationale.isEmpty, !tip.isEmpty else {
            throw AIError.invalidResponse("empty snapshot fields")
        }

        let moments = snapshot.riskMoments
            .prefix(5)
            .map { moment in
                RiskMoment(
                    type: moment.type,
                    atSeconds: max(0, min(moment.atSeconds, Int(ride.durationS) + 60)),
                    severity: min(5, max(1, moment.severity)),
                    explanation: moment.explanation.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                )
            }

        return RideSnapshot(
            headline: String(headline.prefix(80)),
            summary: String(summary.prefix(600)),
            riskMoments: Array(moments),
            score: min(100, max(0, snapshot.score)),
            scoreRationale: String(rationale.prefix(300)),
            coachingTip: String(tip.prefix(200))
        )
    }

    func deterministicSnapshot(for ride: Ride) -> RideSnapshot {
        let score = RideScoring.rideScore(events: ride.events)
        let band = RideScoring.band(for: score)
        let moments = ride.events
            .sorted { $0.severity > $1.severity }
            .prefix(3)
            .map { event in
                RiskMoment(
                    type: event.type,
                    atSeconds: max(
                        0,
                        Int(event.occurredAt.timeIntervalSince(ride.startedAt))
                    ),
                    severity: min(5, max(1, event.severity)),
                    explanation: event.summary
                )
            }

        let eventText = ride.events.isEmpty
            ? "No safety moments were flagged."
            : "\(ride.events.count) safety moment(s) were flagged."
        let summary = "You rode \(RidaryFormatters.distance(meters: ride.distanceM)) in \(ride.durationText). \(eventText)"
        let headline = "\(band) ride · \(RidaryFormatters.distance(meters: ride.distanceM))"
        let rationale = "The score is based on the number and severity of flagged moments in this ride."
        let tip = coachingTip(for: ride.events)

        return RideSnapshot(
            headline: headline,
            summary: summary,
            riskMoments: Array(moments),
            score: score,
            scoreRationale: rationale,
            coachingTip: tip
        )
    }

    private func coachingTip(for events: [RideEvent]) -> String {
        guard let mostCommon = events
            .groupedByType()
            .max(by: { $0.value < $1.value })?.key else {
            return "Keep the same smooth, predictable habits on your next ride."
        }
        switch mostCommon {
        case .hardBrake:
            return "Leave a little more following distance so you can brake earlier."
        case .sharpSwerve:
            return "Scan further ahead and make smaller, earlier direction changes."
        case .impact, .crashCandidate:
            return "Review the locked evidence and check the road surface before riding again."
        case .longStop:
            return "Plan a shorter route or a safer rest stop next time."
        case .routeDeviation:
            return "Set your route before you leave and keep the phone mounted or untouched."
        case .manual:
            return "Lock evidence when it matters, then add a short note while it is fresh."
        }
    }

    private func fallbackSource(for error: Error) -> InferenceSource {
        if let aiError = error as? AIError, case .notConfigured = aiError {
            return .deterministic
        }
        return .fallback
    }
}

private struct RidePromptPayload: Codable {
    let mode: String
    let startedAt: Date
    let durationS: Double
    let distanceM: Double
    let avgSpeedKph: Double
    let maxSpeedKph: Double
    let eventCount: Int
}

private struct EventPromptPayload: Codable {
    let type: String
    let severity: Int
    let confidence: Double
    let atSeconds: Int
    let summary: String
}

private extension Array where Element == RideEvent {
    func groupedByType() -> [RideEventType: Int] {
        reduce(into: [:]) { result, event in
            result[event.type, default: 0] += 1
        }
    }
}
