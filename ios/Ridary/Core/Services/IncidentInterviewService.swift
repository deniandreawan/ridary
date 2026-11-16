import Foundation

final class IncidentInterviewService {
    static let defaultQuestions: [IncidentQuestion] = [
        IncidentQuestion(
            id: "before",
            prompt: "What happened just before the event?",
            kind: "text",
            choices: nil
        ),
        IncidentQuestion(
            id: "action",
            prompt: "Did you brake, swerve, or stop?",
            kind: "text",
            choices: nil
        ),
        IncidentQuestion(
            id: "environment",
            prompt: "What was the road or weather like?",
            kind: "text",
            choices: nil
        ),
        IncidentQuestion(
            id: "others",
            prompt: "Was anyone else involved?",
            kind: "text",
            choices: nil
        )
    ]

    func questions(
        for event: RideEvent,
        note: String,
        ai: AIService
    ) async -> ([IncidentQuestion], InferenceSource) {
        do {
            let eventJSON = try RidaryJSON.string(EventPromptPayload(event: event))
            let prompt = PromptTemplate.render(
                PromptTemplates.incidentQuestions,
                values: [
                    "mode": event.type.rawValue,
                    "event_json": eventJSON,
                    "note": note
                ]
            )
            let result = try await ai.generate(prompt: prompt, mode: .onlyOnDevice)
            let response = try AIJSON.decode(QuestionsResponse.self, from: result.text)
            let questions = sanitize(response.questions)
            if questions.count >= 3 {
                return (Array(questions.prefix(5)), result.source)
            }
            return (Self.defaultQuestions, result.source)
        } catch {
            return (Self.defaultQuestions, fallbackSource(for: error))
        }
    }

    func statement(
        for event: RideEvent,
        answers: [String: String],
        ai: AIService
    ) async -> (IncidentStatement, InferenceSource) {
        do {
            let eventJSON = try RidaryJSON.string(EventPromptPayload(event: event))
            let answersJSON = try RidaryJSON.string(answers)
            let windowJSON = try RidaryJSON.string(WindowSummary(event: event))
            let prompt = PromptTemplate.render(
                PromptTemplates.incidentStatement,
                values: [
                    "mode": event.type.rawValue,
                    "event_json": eventJSON,
                    "answers_json": answersJSON,
                    "window_json": windowJSON
                ]
            )
            let result = try await ai.generate(prompt: prompt, mode: .onlyOnDevice)
            let decoded = try AIJSON.decode(IncidentStatement.self, from: result.text)
            return (sanitize(decoded), result.source)
        } catch {
            return (
                deterministicStatement(for: event, answers: answers),
                fallbackSource(for: error)
            )
        }
    }

    private func sanitize(_ questions: [IncidentQuestion]) -> [IncidentQuestion] {
        questions.compactMap { question in
            let prompt = question.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            let id = question.id.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !prompt.isEmpty, !id.isEmpty else { return nil }
            let kind = question.kind == "choice" ? "choice" : "text"
            return IncidentQuestion(
                id: String(id.prefix(40)),
                prompt: String(prompt.prefix(140)),
                kind: kind,
                choices: kind == "choice" ? question.choices?.prefix(5).map { String($0.prefix(40)) } : nil
            )
        }
    }

    private func sanitize(_ statement: IncidentStatement) -> IncidentStatement {
        let title = statement.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let text = statement.statement.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeTitle = title.isEmpty ? "Incident note" : String(title.prefix(120))
        let safeText = text.isEmpty
            ? "I recorded an incident and locked the available evidence."
            : String(text.prefix(2000))

        let timeline = statement.timeline.prefix(8).map {
            IncidentTimelineItem(
                atSeconds: max(0, $0.atSeconds),
                text: String($0.text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(200))
            )
        }
        let checklist = statement.evidenceChecklist.prefix(8).map {
            String($0.trimmingCharacters(in: .whitespacesAndNewlines).prefix(120))
        }.filter { !$0.isEmpty }

        return IncidentStatement(
            title: safeTitle,
            timeline: Array(timeline),
            statement: safeText,
            evidenceChecklist: Array(checklist)
        )
    }

    private func deterministicStatement(
        for event: RideEvent,
        answers: [String: String]
    ) -> IncidentStatement {
        let answerText = answers
            .sorted { $0.key < $1.key }
            .map { "- \($0.key): \($0.value)" }
            .joined(separator: "\n")
        let statement = """
        I recorded a \(event.type.title.lowercased()) at \(RidaryFormatters.rideDate.string(from: event.occurredAt)).
        The app preserved the sensor window around the event.
        \(answerText.isEmpty ? "I did not add extra notes yet." : answerText)

        This is my own factual record, not a legal conclusion.
        """

        return IncidentStatement(
            title: "Incident note — \(event.type.title)",
            timeline: [
                IncidentTimelineItem(
                    atSeconds: 0,
                    text: event.summary
                )
            ],
            statement: String(statement.prefix(2000)),
            evidenceChecklist: [
                "Photo of the scene, if it is safe to take one",
                "Photo of any damage",
                "Time and location saved by Ridary",
                "Witness details, if you choose to share them"
            ]
        )
    }

    private func fallbackSource(for error: Error) -> InferenceSource {
        if let aiError = error as? AIError, case .notConfigured = aiError {
            return .deterministic
        }
        return .fallback
    }
}

private struct QuestionsResponse: Codable {
    let questions: [IncidentQuestion]
}

private struct EventPromptPayload: Codable {
    let type: String
    let severity: Int
    let confidence: Double
    let occurredAt: Date
    let geohash: String
    let summary: String

    init(event: RideEvent) {
        self.type = event.type.rawValue
        self.severity = event.severity
        self.confidence = event.confidence
        self.occurredAt = event.occurredAt
        self.geohash = event.geohash
        self.summary = event.summary
    }
}

private struct WindowSummary: Codable {
    let sampleCount: Int
    let maxAccelG: Double
    let maxSpeedKph: Double
    let minSpeedKph: Double

    init(event: RideEvent) {
        let accels = event.window.map(\.accelMagnitudeG)
        let speeds = event.window.compactMap(\.speedKph)
        self.sampleCount = event.window.count
        self.maxAccelG = accels.max() ?? 0
        self.maxSpeedKph = speeds.max() ?? 0
        self.minSpeedKph = speeds.min() ?? 0
    }
}
