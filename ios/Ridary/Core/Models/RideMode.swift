import Foundation

enum RideMode: String, Codable, CaseIterable, Identifiable, Equatable, Sendable {
    case motorcycle
    case bicycle
    case car
    case running
    case transit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .motorcycle: return "Motorcycle"
        case .bicycle: return "Bicycle"
        case .car: return "Car"
        case .running: return "Running"
        case .transit: return "Transit"
        }
    }

    var icon: String {
        switch self {
        case .motorcycle: return "figure.outdoor.cycle"
        case .bicycle: return "bicycle"
        case .car: return "car"
        case .running: return "figure.run"
        case .transit: return "tram"
        }
    }
}
