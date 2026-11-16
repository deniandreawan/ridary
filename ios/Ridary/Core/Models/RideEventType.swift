import Foundation

enum RideEventType: String, Codable, CaseIterable, Identifiable, Equatable, Sendable {
    case hardBrake = "hard_brake"
    case sharpSwerve = "sharp_swerve"
    case impact
    case crashCandidate = "crash_candidate"
    case longStop = "long_stop"
    case routeDeviation = "route_deviation"
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hardBrake: return "Hard brake"
        case .sharpSwerve: return "Sharp swerve"
        case .impact: return "Impact"
        case .crashCandidate: return "Crash candidate"
        case .longStop: return "Long stop"
        case .routeDeviation: return "Route deviation"
        case .manual: return "Manual lock"
        }
    }

    var icon: String {
        switch self {
        case .hardBrake: return "exclamationmark.brakesignal"
        case .sharpSwerve: return "arrow.triangle.turn.up.right.diamond"
        case .impact: return "burst.fill"
        case .crashCandidate: return "car.side.rear.and.collision.and.car.side.front"
        case .longStop: return "pause.circle"
        case .routeDeviation: return "arrow.triangle.branch"
        case .manual: return "hand.raised.fill"
        }
    }

    var weight: Double {
        switch self {
        case .hardBrake: return 1.0
        case .sharpSwerve: return 1.2
        case .impact: return 4.0
        case .crashCandidate: return 5.0
        case .longStop: return 0.2
        case .routeDeviation: return 0.5
        case .manual: return 0.5
        }
    }
}
