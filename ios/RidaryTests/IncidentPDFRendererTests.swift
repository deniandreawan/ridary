import XCTest
@testable import Ridary

final class IncidentPDFRendererTests: XCTestCase {
    func testRendersAPDF() {
        let incident = Incident(
            id: UUID(),
            rideID: UUID(),
            eventID: UUID(),
            mode: .motorcycle,
            eventType: .hardBrake,
            severity: 3,
            eventSummary: "Hard braking detected near a wet junction.",
            lockedAt: Date(timeIntervalSince1970: 500),
            hash: String(repeating: "a", count: 64),
            summary: "I braked before a wet junction.",
            status: .draft,
            questions: IncidentInterviewService.defaultQuestions,
            answers: ["action": "I braked"],
            statement: IncidentStatement(
                title: "Incident note — hard brake",
                timeline: [
                    IncidentTimelineItem(atSeconds: 0, text: "Hard braking detected.")
                ],
                statement: "I braked before a wet junction. This is my factual record.",
                evidenceChecklist: ["Photo of the road", "Time and location saved"]
            ),
            statementSource: .onDevice,
            createdAt: Date(timeIntervalSince1970: 500),
            schemaVersion: 1
        )

        let data = IncidentPDFRenderer.render(incident)

        XCTAssertGreaterThan(data.count, 1_000)
        XCTAssertEqual(String(data: data.prefix(4), encoding: .ascii), "%PDF")
    }
}
