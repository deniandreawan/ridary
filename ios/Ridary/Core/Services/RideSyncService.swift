import FirebaseAuth
import FirebaseFirestore
import Foundation

final class RideSyncService {
    private let db: Firestore

    init(db: Firestore = .firestore()) {
        self.db = db
    }

    func syncRide(_ ride: Ride, shareDerived: Bool, shareRoute: Bool) async {
        guard shareDerived,
              let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let batch = db.batch()
        let now = Timestamp(date: Date())

        var rideData: [String: Any] = [
            "uid": uid,
            "mode": ride.mode.rawValue,
            "startedAt": Timestamp(date: ride.startedAt),
            "endedAt": Timestamp(date: ride.endedAt),
            "distanceM": ride.distanceM,
            "durationS": ride.durationS,
            "avgSpeedKph": ride.avgSpeedKph,
            "maxSpeedKph": ride.maxSpeedKph,
            "score": ride.score,
            "summary": ride.summary,
            "inferenceSource": ride.inferenceSource.rawValue,
            "geohash": ride.geohash,
            "createdAt": now,
            "schemaVersion": 1
        ]

        if shareRoute {
            rideData["routePreview"] = ride.routePreview
        }

        let rideRef = db.collection("rides").document(ride.id.uuidString)
        batch.setData(rideData, forDocument: rideRef)

        for event in ride.events {
            let eventRef = db.collection("events").document(event.id.uuidString)
            let eventData: [String: Any] = [
                "uid": uid,
                "rideId": ride.id.uuidString,
                "mode": ride.mode.rawValue,
                "type": event.type.rawValue,
                "severity": event.severity,
                "confidence": event.confidence,
                "geohash": event.geohash,
                "occurredAt": Timestamp(date: event.occurredAt),
                "summary": event.summary,
                "source": event.source.rawValue,
                "createdAt": now,
                "schemaVersion": 1
            ]
            batch.setData(eventData, forDocument: eventRef)
        }

        do {
            try await batch.commit()
            RidaryLog.sync.info("Synced ride \(ride.id.uuidString, privacy: .public)")
        } catch {
            RidaryLog.sync.error(
                "Ride sync failed: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    func saveFeedback(
        _ feedback: WeeklyFeedback,
        weekStart: Date,
        source: InferenceSource
    ) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let weekID = ISO8601DateFormatter.ridaryDay.string(from: weekStart)
        let ref = db
            .collection("feedback")
            .document(uid)
            .collection("weeks")
            .document(weekID)

        let data: [String: Any] = [
            "uid": uid,
            "weekStart": Timestamp(date: weekStart),
            "summary": feedback.summary,
            "insights": feedback.insights,
            "action": feedback.action,
            "generatedAt": Timestamp(date: Date()),
            "inferenceSource": source.rawValue,
            "schemaVersion": 1
        ]

        do {
            try await ref.setData(data)
        } catch {
            RidaryLog.sync.error(
                "Feedback sync failed: \(error.localizedDescription, privacy: .public)"
            )
        }
    }
}

private extension ISO8601DateFormatter {
    static let ridaryDay: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
}
