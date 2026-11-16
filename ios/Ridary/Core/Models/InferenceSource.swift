import Foundation

enum InferenceSource: String, Codable, CaseIterable, Equatable, Sendable {
    case onDevice = "on_device"
    case inCloud = "in_cloud"
    case fallback
    case deterministic

    var label: String {
        switch self {
        case .onDevice: return "On device"
        case .inCloud: return "In cloud"
        case .fallback: return "Fallback"
        case .deterministic: return "Rules"
        }
    }

    var icon: String {
        switch self {
        case .onDevice: return "iphone"
        case .inCloud: return "cloud"
        case .fallback: return "arrow.triangle.2.circlepath"
        case .deterministic: return "function"
        }
    }
}
