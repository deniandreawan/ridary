import UIKit

enum IncidentPDFRenderer {
    static func render(_ incident: Incident) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            let writer = PDFWriter(context: context, pageRect: pageRect, margin: 44)
            writer.beginPage()

            writer.text(
                "RIDARY",
                font: .systemFont(ofSize: 11, weight: .black),
                color: .systemOrange,
                spacing: 4
            )
            writer.text(
                incident.statement?.title ?? "Incident note",
                font: .systemFont(ofSize: 22, weight: .bold),
                color: .black,
                spacing: 6
            )
            writer.text(
                "Locked \(RidaryFormatters.rideDate.string(from: incident.lockedAt)) · \(incident.mode.title)",
                font: .systemFont(ofSize: 10),
                color: .darkGray,
                spacing: 12
            )

            writer.text(
                "Event",
                font: .systemFont(ofSize: 14, weight: .semibold),
                color: .black,
                spacing: 4
            )
            writer.text(
                "\(incident.eventType.title) · severity \(incident.severity)",
                font: .systemFont(ofSize: 11),
                color: .black,
                spacing: 4
            )
            writer.text(
                incident.eventSummary,
                font: .systemFont(ofSize: 11),
                color: .darkGray,
                spacing: 12
            )

            writer.text(
                "Evidence hash",
                font: .systemFont(ofSize: 14, weight: .semibold),
                color: .black,
                spacing: 4
            )
            writer.text(
                incident.hash,
                font: .monospacedSystemFont(ofSize: 8, weight: .regular),
                color: .darkGray,
                spacing: 12
            )

            writer.text(
                "Statement",
                font: .systemFont(ofSize: 14, weight: .semibold),
                color: .black,
                spacing: 4
            )
            writer.text(
                incident.statement?.statement ?? incident.eventSummary,
                font: .systemFont(ofSize: 11),
                color: .black,
                spacing: 12
            )

            if let statement = incident.statement, !statement.timeline.isEmpty {
                writer.text(
                    "Timeline",
                    font: .systemFont(ofSize: 14, weight: .semibold),
                    color: .black,
                    spacing: 4
                )
                for item in statement.timeline {
                    writer.text(
                        "+\(item.atSeconds)s · \(item.text)",
                        font: .systemFont(ofSize: 10),
                        color: .black,
                        spacing: 3
                    )
                }
                writer.advance(9)
            }

            if let statement = incident.statement, !statement.evidenceChecklist.isEmpty {
                writer.text(
                    "Evidence checklist",
                    font: .systemFont(ofSize: 14, weight: .semibold),
                    color: .black,
                    spacing: 4
                )
                for item in statement.evidenceChecklist {
                    writer.text(
                        "• \(item)",
                        font: .systemFont(ofSize: 10),
                        color: .black,
                        spacing: 3
                    )
                }
                writer.advance(9)
            }

            writer.text(
                "This is a personal record, not legal advice or a court determination. Ridary does not decide fault or coverage.",
                font: .italicSystemFont(ofSize: 8),
                color: .darkGray,
                spacing: 0
            )
        }
    }
}

private final class PDFWriter {
    private let context: UIGraphicsPDFRendererContext
    private let pageRect: CGRect
    private let margin: CGFloat
    private let contentWidth: CGFloat
    private var y: CGFloat = 0

    init(context: UIGraphicsPDFRendererContext, pageRect: CGRect, margin: CGFloat) {
        self.context = context
        self.pageRect = pageRect
        self.margin = margin
        self.contentWidth = pageRect.width - margin * 2
    }

    func beginPage() {
        context.beginPage()
        context.cgContext.setFillColor(UIColor.white.cgColor)
        context.cgContext.fill(pageRect)
        y = margin
    }

    func advance(_ amount: CGFloat) {
        y += amount
    }

    func text(
        _ text: String,
        font: UIFont,
        color: UIColor,
        spacing: CGFloat
    ) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let bounding = (text as NSString).boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )

        if y + bounding.height > pageRect.height - margin {
            beginPage()
        }

        (text as NSString).draw(
            with: CGRect(
                x: margin,
                y: y,
                width: contentWidth,
                height: bounding.height
            ),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        y += bounding.height + spacing
    }
}
