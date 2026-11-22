import SwiftUI

struct IncidentView: View {
    @EnvironmentObject private var app: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var current: Incident
    @State private var answers: [String: String]
    @State private var source: InferenceSource?
    @State private var isDrafting = false
    @State private var pdfURL: URL?
    @State private var showActivity = false

    init(incident: Incident) {
        self.incident = incident
        _current = State(initialValue: incident)
        _answers = State(initialValue: incident.answers)
        _source = State(initialValue: incident.statementSource)
    }

    let incident: Incident

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                if let error = app.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(RidaryTheme.warning)
                }
                evidenceCard
                questionsCard
                if let statement = current.statement {
                    statementCard(statement)
                }
                shareRow
                Text("This is a personal factual record. Ridary does not decide fault, coverage, or legal outcomes.")
                    .font(.caption2)
                    .foregroundStyle(RidaryTheme.textTertiary)
            }
            .padding(20)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationTitle("Incident")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .sheet(isPresented: $showActivity) {
            if let pdfURL {
                ActivityView(items: [pdfURL])
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Incident evidence")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Spacer()
                Text(current.status.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(RidaryTheme.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(RidaryTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
            Text("The sensor window is already preserved on this iPhone. Add answers to draft a statement.")
                .font(.footnote)
                .foregroundStyle(RidaryTheme.textSecondary)
        }
    }

    private var evidenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: current.eventType.icon)
                    .foregroundStyle(current.severity >= 4 ? RidaryTheme.danger : RidaryTheme.warning)
                VStack(alignment: .leading, spacing: 2) {
                    Text(current.eventType.title)
                        .font(.subheadline.weight(.semibold))
                    Text(RidaryFormatters.rideDate.string(from: current.lockedAt))
                        .font(.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
                Spacer()
                Text("Severity \(current.severity)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(RidaryTheme.warning)
            }

            Text(current.eventSummary)
                .font(.footnote)
                .foregroundStyle(RidaryTheme.textSecondary)

            Text("SHA-256 \(current.hash.prefix(24))…")
                .font(.caption2.monospaced())
                .foregroundStyle(RidaryTheme.textTertiary)
                .textSelection(.enabled)
        }
        .ridaryCard()
    }

    private var questionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            RidarySectionHeader(
                title: "What happened?",
                subtitle: "Answer what you remember. You can leave fields blank."
            )

            ForEach(current.questions) { question in
                VStack(alignment: .leading, spacing: 6) {
                    Text(question.prompt)
                        .font(.footnote.weight(.semibold))
                    if question.kind == "choice",
                       let choices = question.choices,
                       !choices.isEmpty {
                        Picker(question.prompt, selection: answerBinding(for: question.id)) {
                            Text("Select…").tag("")
                            ForEach(choices, id: \.self) { choice in
                                Text(choice).tag(choice)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(RidaryTheme.accent)
                    } else {
                        TextField(
                            "Your answer",
                            text: answerBinding(for: question.id),
                            axis: .vertical
                        )
                        .lineLimit(2...4)
                        .padding(12)
                        .background(RidaryTheme.backgroundLifted)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                    }
                }
            }

            Button {
                Task {
                    isDrafting = true
                    if let (updated, draftSource) = await app.draftStatement(
                        incident: current,
                        answers: answers
                    ) {
                        current = updated
                        source = draftSource
                        answers = updated.answers
                    }
                    isDrafting = false
                }
            } label: {
                if isDrafting {
                    ProgressView()
                        .tint(RidaryTheme.onSky)
                } else {
                    Label("Draft statement", systemImage: "text.quote")
                }
            }
            .buttonStyle(RidaryPrimaryButtonStyle())
            .disabled(isDrafting)
        }
        .ridaryCard()
    }

    private func statementCard(_ statement: IncidentStatement) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(statement.title)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                Spacer()
                if let source {
                    SourceBadge(source: source)
                }
            }

            Text(statement.statement)
                .font(.footnote)
                .foregroundStyle(RidaryTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if !statement.timeline.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Timeline")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(RidaryTheme.textSecondary)
                    ForEach(statement.timeline) { item in
                        Text("+\(item.atSeconds)s · \(item.text)")
                            .font(.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                }
            }

            if !statement.evidenceChecklist.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Evidence checklist")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(RidaryTheme.textSecondary)
                    ForEach(statement.evidenceChecklist, id: \.self) { item in
                        Label(item, systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                }
            }

            if let source, source == .fallback {
                Text("On-device AI was unavailable; the statement used local rules. Cloud was not used for this sensitive record.")
                    .font(.caption2)
                    .foregroundStyle(RidaryTheme.warning)
            }
        }
        .ridaryCard()
    }

    private var shareRow: some View {
        HStack(spacing: 10) {
            Button {
                guard current.statement != nil else { return }
                let data = IncidentPDFRenderer.render(current)
                let url = FileManager.default.temporaryDirectory
                    .appendingPathComponent("Ridary-Incident-\(current.id.uuidString).pdf")
                do {
                    try data.write(to: url, options: [.atomic])
                    pdfURL = url
                    showActivity = true
                } catch {
                    app.errorMessage = "Could not create the PDF: \(error.localizedDescription)"
                }
            } label: {
                Label("Share PDF", systemImage: "doc.richtext")
            }
            .buttonStyle(RidarySecondaryButtonStyle())
            .disabled(current.statement == nil)

            if let statement = current.statement {
                ShareLink(item: statement.statement) {
                    Label("Share text", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(RidarySecondaryButtonStyle())
            }
        }
    }

    private func answerBinding(for id: String) -> Binding<String> {
        Binding(
            get: { answers[id] ?? "" },
            set: { answers[id] = $0 }
        )
    }
}
