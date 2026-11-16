import Foundation

enum RideScoring {
    static func rideScore(events: [RideEvent]) -> Int {
        let penalty = events.reduce(0.0) { partial, event in
            partial
                + Double(clamp(event.severity, min: 1, max: 5))
                * clamp(event.confidence, min: 0, max: 1)
                * event.type.weight
        }
        return Int(clamp(round(100 - penalty * 3), min: 0, max: 100))
    }

    static func credentialScore(rides: [Ride], events: [RideEvent]) -> Int {
        guard !rides.isEmpty else { return 0 }
        let rideIDs = Set(rides.map(\.id))
        let relevant = events.filter { rideIDs.contains($0.rideID) }
        let total = relevant.reduce(0.0) { partial, event in
            partial
                + Double(clamp(event.severity, min: 1, max: 5))
                * clamp(event.confidence, min: 0, max: 1)
                * event.type.weight
        }
        let average = total / Double(rides.count)
        return Int(clamp(round(100 - average * 3), min: 0, max: 100))
    }

    static func band(for score: Int) -> String {
        if score >= 90 { return "A" }
        if score >= 75 { return "B" }
        if score >= 60 { return "C" }
        return "D"
    }

    private static func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        Swift.min(max, Swift.max(min, value))
    }
}
