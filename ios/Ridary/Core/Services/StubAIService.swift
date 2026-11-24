#if DEBUG
import Foundation

final class StubAIService: AIService {
    func onDeviceAvailability() async -> OnDeviceAvailability {
        .available
    }

    func generate(prompt: String, mode: AIMode) async throws -> AIResult {
        AIResult(
            text: "Your last ride scored 96 out of 100. One hard brake was flagged near a junction, so keep a little more following distance next time.",
            modelVersion: "apple-foundation-models-stub",
            source: .onDevice
        )
    }
}
#endif
