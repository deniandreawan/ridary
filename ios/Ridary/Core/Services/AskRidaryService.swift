import Foundation

struct AskRidaryContextBuilder {
    func build(
        rides: [Ride],
        incidents: [Incident],
        credentials: [Credential],
        weeklyFeedback: WeeklyFeedback?,
        now: Date = Date()
    ) -> AskRidaryContext {
        let cutoff = now.addingTimeInterval(-7 * 24 * 60 * 60)
        let weekRides = rides.filter { $0.startedAt >= cutoff }
        let recentRides = rides
            .sorted { $0.startedAt > $1.startedAt }
            .prefix(4)
            .map(rideSummary)

        let weekEvents = weekRides
            .flatMap(\.events)
            .filter { $0.occurredAt >= cutoff }

        let eventCounts = weekEvents.reduce(into: [RideEventType: Int]()) {
            $0[$1.type, default: 0] += 1
        }
        let topEvent = eventCounts.max { $0.value < $1.value }?.key

        let modes = RideMode.allCases.compactMap { mode -> AskRidaryContext.ModeSummary? in
            let modeRides = rides.filter { $0.mode == mode }
            guard !modeRides.isEmpty else { return nil }
            return AskRidaryContext.ModeSummary(
                mode: mode.rawValue,
                rides: modeRides.count,
                distanceM: modeRides.reduce(0) { $0 + $1.distanceM }
            )
        }

        let latestCredential = credentials.first.map { credential in
            AskRidaryContext.CredentialSummary(
                band: credential.band,
                score: credential.score,
                rides: credential.rideCount,
                events: credential.eventCount,
                period: credential.periodText,
                expiresAt: credential.expiresAt,
                issuer: credential.issuer
            )
        }

        let note = weeklyFeedback.map {
            AskRidaryContext.WeeklyNote(
                headline: short($0.headline, 140),
                action: short($0.action, 200)
            )
        }

        return AskRidaryContext(
            generatedAt: now,
            weekly: AskRidaryContext.Weekly(
                rides: weekRides.count,
                distanceM: weekRides.reduce(0) { $0 + $1.distanceM },
                avgScore: averageScore(weekRides),
                onDevice: weekRides.filter { $0.inferenceSource == .onDevice }.count,
                topEvent: topEvent?.title
            ),
            allTime: AskRidaryContext.AllTime(
                rides: rides.count,
                distanceM: rides.reduce(0) { $0 + $1.distanceM },
                avgScore: averageScore(rides),
                proofs: credentials.count,
                modes: modes
            ),
            recentRides: Array(recentRides),
            recentIncidents: incidents
                .sorted { $0.lockedAt > $1.lockedAt }
                .prefix(3)
                .map { incident in
                    AskRidaryContext.IncidentSummary(
                        when: incident.lockedAt,
                        type: incident.eventType.title,
                        severity: incident.severity,
                        status: incident.status.title
                    )
                },
            credential: latestCredential,
            weeklyNote: note
        )
    }

    private func rideSummary(_ ride: Ride) -> AskRidaryContext.RideSummary {
        let events = ride.events
            .sorted {
                if $0.severity == $1.severity {
                    return $0.occurredAt > $1.occurredAt
                }
                return $0.severity > $1.severity
            }
            .prefix(2)
            .map { event in
                AskRidaryContext.EventSummary(
                    type: event.type.rawValue,
                    severity: event.severity,
                    atSeconds: max(
                        0,
                        Int(event.occurredAt.timeIntervalSince(ride.startedAt))
                    ),
                    summary: short(event.summary, 140)
                )
            }

        let snapshot = ride.snapshot
        return AskRidaryContext.RideSummary(
            when: ride.startedAt,
            mode: ride.mode.rawValue,
            distanceM: ride.distanceM,
            durationS: ride.durationS,
            avgSpeedKph: ride.avgSpeedKph,
            maxSpeedKph: ride.maxSpeedKph,
            score: ride.score,
            band: RideScoring.band(for: ride.score),
            headline: short(snapshot?.headline ?? "Ride captured", 90),
            summary: short(snapshot?.summary ?? ride.summary, 240),
            coachingTip: short(snapshot?.coachingTip ?? "", 180),
            rationale: short(snapshot?.scoreRationale ?? "", 200),
            events: Array(events)
        )
    }

    private func averageScore(_ rides: [Ride]) -> Int? {
        let valid = rides.filter { $0.distanceM > 0 || $0.score > 0 }
        let source = valid.isEmpty ? rides : valid
        guard !source.isEmpty else { return nil }
        return source.reduce(0) { $0 + $1.score } / source.count
    }

    private func short(_ value: String, _ limit: Int) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > limit else { return trimmed }
        return String(trimmed.prefix(limit)) + "…"
    }
}

final class AskRidaryService {
    private struct HistoryItem: Codable {
        let role: String
        let text: String
    }

    private let contextBuilder = AskRidaryContextBuilder()

    func ask(
        question: String,
        history: [AskRidaryTurn],
        rides: [Ride],
        incidents: [Incident],
        credentials: [Credential],
        weeklyFeedback: WeeklyFeedback?,
        ai: AIService
    ) async -> AskRidaryReply {
        let cleanQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let context = contextBuilder.build(
            rides: rides,
            incidents: incidents,
            credentials: credentials,
            weeklyFeedback: weeklyFeedback
        )
        let fallback = deterministicReply(question: cleanQuestion, context: context)

        guard !cleanQuestion.isEmpty else {
            return AskRidaryReply(text: fallback, source: .deterministic)
        }

        guard let contextJSON = try? RidaryJSON.string(context) else {
            return AskRidaryReply(text: fallback, source: .deterministic)
        }

        let historyItems = history.suffix(4).map { turn in
            HistoryItem(
                role: turn.role.rawValue,
                text: String(turn.text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(240))
            )
        }
        let historyJSON = (try? RidaryJSON.string(historyItems)) ?? "[]"

        let prompt = PromptTemplate.render(
            PromptTemplates.askRidary,
            values: [
                "context_json": contextJSON,
                "history_json": historyJSON,
                "question": String(cleanQuestion.prefix(500))
            ]
        )

        do {
            let result = try await ai.generate(prompt: prompt, mode: .preferOnDevice)
            let text = sanitize(result.text)
            guard !text.isEmpty else {
                return AskRidaryReply(text: fallback, source: .fallback)
            }
            return AskRidaryReply(text: text, source: result.source)
        } catch {
            return AskRidaryReply(
                text: fallback,
                source: fallbackSource(for: error)
            )
        }
    }

    private func sanitize(_ text: String) -> String {
        var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("```") {
            if let firstNewline = value.firstIndex(of: "\n") {
                value = String(value[value.index(after: firstNewline)...])
            }
            if value.hasSuffix("```") {
                value = String(value.dropLast(3))
            }
            value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard value.count > 1_200 else { return value }
        return String(value.prefix(1_200)) + "…"
    }

    private func fallbackSource(for error: Error) -> InferenceSource {
        if let aiError = error as? AIError, case .notConfigured = aiError {
            return .deterministic
        }
        return .fallback
    }

    private func deterministicReply(
        question: String,
        context: AskRidaryContext
    ) -> String {
        let normalized = question.lowercased()
        let hasRides = !context.recentRides.isEmpty

        if contains(normalized, ["proof", "credential", "band", "insur", "verif"]) {
            return proofReply(context)
        }

        if contains(normalized, ["privacy", "private", "route", "data", "upload", "cloud", "privasi"]) {
            return """
            Ridary keeps raw routes, sensor windows, evidence, and incident statements on this iPhone. \
            Only derived summaries can leave the device through Firebase AI Logic, and each answer is labeled \
            On device, In cloud, or Rules. You can review the privacy model in the web dashboard.
            """
        }

        if contains(normalized, ["incident", "lock", "near miss", "evidence", "insiden"]) {
            return incidentReply(context)
        }

        if contains(normalized, ["week", "7 day", "seven day", "minggu", "this week"]) {
            return weekReply(context)
        }

        if contains(normalized, ["how many", "total", "all time", "mode", "distance"]) {
            return allTimeReply(context)
        }

        if contains(normalized, ["why", "risk", "risky", "brake", "moment", "score", "kenapa", "risiko", "rem", "bahaya", "last ride", "terakhir"]) {
            return lastRideReply(context)
        }

        if contains(normalized, ["how", "what", "help", "can you", "ridary", "cara", "apa"]) {
            return aboutReply(context)
        }

        if hasRides {
            return lastRideReply(context) + "\n\nYou can also ask about this week, your Ridary Proof, or where your data is stored."
        }

        return """
        I can answer questions about your rides, weekly safety patterns, Ridary Proof, privacy, and locked incidents. \
        There are no rides recorded on this iPhone yet, so start a ride to build your private record.
        """
    }

    private func lastRideReply(_ context: AskRidaryContext) -> String {
        guard let ride = context.recentRides.first else {
            return "There are no rides recorded on this iPhone yet. Start a ride to build a private record you can ask about."
        }

        var lines: [String] = []
        lines.append(
            "Your last ride on \(RidaryFormatters.shortDate.string(from: ride.when)) was a \(RidaryFormatters.distance(meters: ride.distanceM)) \(ride.mode) ride with a safety score of \(ride.score)/100 (\(ride.band) band)."
        )

        if !ride.headline.isEmpty {
            lines.append(ride.headline + ".")
        }

        if ride.events.isEmpty {
            lines.append("No safety events were flagged.")
        } else {
            let moments = ride.events.prefix(2).map { event in
                let type = event.type.replacingOccurrences(of: "_", with: " ")
                return "\(type) at +\(RidaryFormatters.duration(seconds: Double(event.atSeconds))) (severity \(event.severity))"
            }
            lines.append("Flagged moments: " + moments.joined(separator: ", ") + ".")
        }

        if !ride.coachingTip.isEmpty {
            lines.append(ride.coachingTip)
        }

        return lines.joined(separator: " ")
    }

    private func weekReply(_ context: AskRidaryContext) -> String {
        let weekly = context.weekly
        guard weekly.rides > 0 else {
            return "You have no rides in the last 7 days. Start a ride when you are ready, then ask me for the pattern."
        }

        var text = "This week you recorded \(weekly.rides) \(weekly.rides == 1 ? "ride" : "rides") over \(RidaryFormatters.distance(meters: weekly.distanceM))."
        if let avg = weekly.avgScore {
            text += " Your average safety score is \(avg)/100."
        }
        if let top = weekly.topEvent {
            text += " The most flagged moment is \(top.lowercased())."
        } else {
            text += " No safety events were flagged this week."
        }
        text += " \(weekly.onDevice) of \(weekly.rides) \(weekly.rides == 1 ? "summary was" : "summaries were") generated on this iPhone."
        if let note = context.weeklyNote {
            text += " \(note.action)"
        }
        return text
    }

    private func allTimeReply(_ context: AskRidaryContext) -> String {
        let allTime = context.allTime
        guard allTime.rides > 0 else {
            return "There are no rides recorded on this iPhone yet. Start a ride to build your private record."
        }

        var text = "You have recorded \(allTime.rides) \(allTime.rides == 1 ? "ride" : "rides") over \(RidaryFormatters.distance(meters: allTime.distanceM))."
        if let avg = allTime.avgScore {
            text += " Your all-time average safety score is \(avg)/100."
        }
        if !allTime.modes.isEmpty {
            let modes = allTime.modes.prefix(3).map { mode in
                "\(mode.mode) \(mode.rides) × \(RidaryFormatters.distance(meters: mode.distanceM))"
            }
            text += " By mode: " + modes.joined(separator: ", ") + "."
        }
        if allTime.proofs > 0 {
            text += " You also have \(allTime.proofs) signed \(allTime.proofs == 1 ? "credential" : "credentials")."
        }
        return text
    }

    private func proofReply(_ context: AskRidaryContext) -> String {
        guard let credential = context.credential else {
            return "You do not have a signed Ridary Proof yet. Record at least three rides, then issue one from the Ridary Proof screen."
        }
        let expiry = CredentialDateParser.date(from: credential.expiresAt)
            .map { RidaryFormatters.shortDate.string(from: $0) }
            ?? credential.expiresAt
        return "Your current Ridary Proof is \(credential.band) band with a score of \(credential.score)/100. It covers \(credential.rides) rides and \(credential.events) moments, issued by \(credential.issuer), and expires on \(expiry). The proof never exposes your route or raw sensors."
    }

    private func incidentReply(_ context: AskRidaryContext) -> String {
        var text: String
        if let latest = context.recentIncidents.first {
            let date = RidaryFormatters.shortDate.string(from: latest.when)
            text = "You have \(context.recentIncidents.count) locked incident \(context.recentIncidents.count == 1 ? "record" : "records"). The latest is \(latest.type.lowercased()) on \(date), severity \(latest.severity), status \(latest.status)."
        } else {
            text = "You have no locked incidents yet."
        }
        text += " Tap Lock during a ride to preserve the last 30 seconds of sensor data locally. Evidence stays on this iPhone until you export it."
        return text
    }

    private func aboutReply(_ context: AskRidaryContext) -> String {
        var text = "Ridary is a private ride witness. It records a ride on this iPhone, explains what happened with on-device AI, and only shares derived summaries when you choose. You can ask about a recent ride, this week, your Ridary Proof, privacy, or locked incidents."
        if let ride = context.recentRides.first {
            text += " Your last ride scored \(ride.score)/100."
        }
        return text
    }

    private func contains(_ value: String, _ terms: [String]) -> Bool {
        terms.contains { value.contains($0) }
    }
}
