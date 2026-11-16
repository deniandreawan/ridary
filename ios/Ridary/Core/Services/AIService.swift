import Foundation

enum AIMode: String, Sendable {
    case preferOnDevice
    case onlyOnDevice
    case preferInCloud
    case onlyInCloud
}

enum OnDeviceAvailability: Equatable, Sendable {
    case available
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case unknown(String)

    var isAvailable: Bool {
        self == .available
    }

    var title: String {
        switch self {
        case .available: return "On-device AI ready"
        case .deviceNotEligible: return "On-device AI not supported"
        case .appleIntelligenceNotEnabled: return "Apple Intelligence is off"
        case .modelNotReady: return "On-device model downloading"
        case .unknown: return "On-device AI unavailable"
        }
    }

    var detail: String {
        switch self {
        case .available:
            return "Private summaries can run on this iPhone."
        case .deviceNotEligible:
            return "This iPhone does not support Apple Intelligence. Cloud fallback will be used when online."
        case .appleIntelligenceNotEnabled:
            return "Enable Apple Intelligence in Settings to run private on-device summaries."
        case .modelNotReady:
            return "Apple is still preparing the on-device model. Try again shortly."
        case .unknown(let reason):
            return reason
        }
    }
}

struct AIResult: Sendable {
    let text: String
    let modelVersion: String
    let source: InferenceSource
}

enum AIError: LocalizedError {
    case notConfigured
    case invalidResponse(String)
    case unavailable(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "AI is not configured. Add your Firebase configuration and try again."
        case .invalidResponse(let detail):
            return "The AI response could not be read: \(detail)"
        case .unavailable(let detail):
            return detail
        }
    }
}

protocol AIService: AnyObject {
    func generate(prompt: String, mode: AIMode) async throws -> AIResult
    func onDeviceAvailability() async -> OnDeviceAvailability
}

enum AIJSON {
    static func decode<T: Decodable>(_ type: T.Type, from text: String) throws -> T {
        guard let data = RidaryJSON.extractJSONObject(from: text) else {
            throw AIError.invalidResponse("no JSON object found")
        }
        do {
            return try RidaryJSON.decode(type, from: data)
        } catch {
            throw AIError.invalidResponse(error.localizedDescription)
        }
    }
}
