import FirebaseAI
import Foundation

final class FirebaseAIService: AIService {
    private let service: FirebaseAI
    private let cloudModelName: String

    init(cloudModelName: String = "gemini-3.5-flash-lite") {
        self.cloudModelName = cloudModelName
        self.service = FirebaseAI.firebaseAI(backend: .googleAI())
    }

    func onDeviceAvailability() async -> OnDeviceAvailability {
        let model = FirebaseAI.SystemLanguageModel.default
        switch model.availability {
        case .available:
            return .available
        case .unavailable(.deviceNotEligible):
            return .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            return .appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            return .modelNotReady
        case .unavailable(let reason):
            return .unknown(String(describing: reason))
        }
    }

    func generate(prompt: String, mode: AIMode) async throws -> AIResult {
        let cloudModel = service.geminiModel(name: cloudModelName)
        let systemModel = FirebaseAI.SystemLanguageModel.default

        let session: GenerativeModelSession
        switch mode {
        case .preferOnDevice:
            session = service.generativeModelSession(
                model: .hybridModel(primary: systemModel, secondary: cloudModel)
            )
        case .onlyOnDevice:
            session = service.generativeModelSession(model: systemModel)
        case .preferInCloud:
            session = service.generativeModelSession(
                model: .hybridModel(primary: cloudModel, secondary: systemModel)
            )
        case .onlyInCloud:
            session = service.generativeModelSession(model: cloudModel)
        }

        let response = try await session.respond(to: prompt)
        let modelVersion = response.rawResponse.modelVersion
        let source: InferenceSource = modelVersion
            .contains("apple-foundation-models") ? .onDevice : .inCloud

        return AIResult(
            text: response.content,
            modelVersion: modelVersion,
            source: source
        )
    }
}
