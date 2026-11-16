import Foundation

final class MockAIService: AIService {
    func onDeviceAvailability() async -> OnDeviceAvailability {
        .deviceNotEligible
    }

    func generate(prompt: String, mode: AIMode) async throws -> AIResult {
        throw AIError.notConfigured
    }
}
