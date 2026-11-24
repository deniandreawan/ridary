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
    @State private var scrollOffset: CGFloat = 0

    var isModal = false

    init(incident: Incident, isModal: Bool = false) {
        _current = State(initialValue: incident)
        _answers = State(initialValue: incident.answers)
        _source = State(initialValue: incident.statementSource)
        self.isModal = isModal
    }

    private var relatedRide: Ride? {
        app.rides.first { $0.id == current.rideID }
    }

    private var severityColor: Color {
        current.severity >= 4 ? RidaryTheme.danger : RidaryTheme.warning
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    incidentHero

                    VStack(spacing: 0) {
                        editorialIntro
                            .padding(.horizontal, 28)
                            .padding(.top, 26)
                            .padding(.bottom, 24)

                        if let error = app.errorMessage {
                            Text(error)
                                .font(RidaryType.caption)
                                .foregroundStyle(RidaryTheme.warning)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 16)
                        }

                        sectionDivider

                        highlightStrip
                            .padding(.horizontal, 24)

                        sectionDivider

                        evidenceSection
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)

                        sectionDivider

                        questionsSection
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)

                        if let statement = current.statement {
                            sectionDivider

                            statementSection(statement)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 24)
                        }

                        sectionDivider

                        Text("This is a personal factual record. Ridary does not decide fault, coverage, or legal outcomes.")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundStyle(RidaryTheme.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(RidaryTheme.surface)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 26,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 26
                        )
                    )
                    .padding(.top, -26)
                }
                .accessibilityIdentifier("incident-screen")
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newValue in
                scrollOffset = newValue
            }
            .safeAreaInset(edge: .bottom) {
                actionBar
            }

            topBar
        }
        .background(RidaryTheme.surface.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showActivity) {
            if let pdfURL {
                ActivityView(items: [pdfURL])
            }
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: isModal ? "xmark" : "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityLabel(isModal ? "Close incident" : "Back")

                Spacer()

                if isTopBarSolid {
                    Text("Incident · \(current.mode.title)")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .transition(.opacity)

                    Spacer()
                }

                Color.clear
                    .frame(width: 42, height: 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)

            if isTopBarSolid {
                Rectangle()
                    .fill(RidaryTheme.border.opacity(0.65))
                    .frame(height: 1)
            }
        }
        .background(
            RidaryTheme.surface
                .opacity(isTopBarSolid ? 1 : 0)
                .ignoresSafeArea(edges: .top)
        )
        .animation(.easeOut(duration: 0.18), value: isTopBarSolid)
    }

    private var isTopBarSolid: Bool {
        scrollOffset > 170
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border.opacity(0.65))
            .frame(height: 1)
            .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var incidentHero: some View {
        Group {
            if let ride = relatedRide, !ride.routePreview.isEmpty {
                RideMapView(route: ride.routePreview, height: 330, interactive: true)
            } else {
                ZStack {
                    LinearGradient(
                        colors: [RidaryTheme.skySoft, RidaryTheme.skySoft.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(spacing: 10) {
                        Image(systemName: current.eventType.icon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(severityColor)

                        Text("Sensor window locked")
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundStyle(RidaryTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                }
                .frame(height: 330)
            }
        }
    }

    private var editorialIntro: some View {
        VStack(spacing: 10) {
            Text(current.eventType.title)
                .font(.system(size: 23, weight: .semibold, design: .default))
                .tracking(-0.35)
                .foregroundStyle(RidaryTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text(current.eventSummary)
                .font(.system(size: 15, weight: .regular, design: .default))
                .lineSpacing(3)
                .foregroundStyle(RidaryTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 5) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)

                Text("Severity \(current.severity)")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text("· \(RidaryFormatters.rideDate.string(from: current.lockedAt))")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }

    private var highlightStrip: some View {
        HStack(spacing: 0) {
            incidentMetric(
                value: "Severity \(current.severity)",
                label: "Impact level",
                color: severityColor
            )

            Rectangle()
                .fill(RidaryTheme.border.opacity(0.65))
                .frame(width: 1, height: 28)

            incidentMetric(
                value: current.status.title,
                label: "Record state",
                color: RidaryTheme.textPrimary
            )

            Rectangle()
                .fill(RidaryTheme.border.opacity(0.65))
                .frame(width: 1, height: 28)

            incidentMetric(
                value: "SHA-256",
                label: "Locked hash",
                color: RidaryTheme.skyDeep
            )
        }
        .padding(.vertical, 18)
    }

    private func incidentMetric(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(label)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(RidaryTheme.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Evidence summary")
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundStyle(RidaryTheme.textPrimary)

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: current.eventType.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(severityColor)
                    .frame(width: 34, height: 34)
                    .background(severityColor.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("Sensor window")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(RidaryTheme.textPrimary)

                    Text(current.eventSummary)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(RidaryTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)
                    .frame(width: 34, height: 34)
                    .background(RidaryTheme.skySoft)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("Integrity hash")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(RidaryTheme.textPrimary)

                    Text(current.hash)
                        .font(RidaryType.mono)
                        .foregroundStyle(RidaryTheme.textTertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
            }
        }
    }

    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("What happened?")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text("Answer what you remember. You can leave fields blank.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(RidaryTheme.textSecondary)
            }

            ForEach(current.questions) { question in
                VStack(alignment: .leading, spacing: 7) {
                    Text(question.prompt)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

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
                        .tint(RidaryTheme.sky)
                    } else {
                        TextField(
                            "Your answer",
                            text: answerBinding(for: question.id),
                            axis: .vertical
                        )
                        .font(.system(size: 14, weight: .regular))
                        .lineLimit(2...4)
                        .padding(12)
                        .background(RidaryTheme.backgroundLifted)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
    }

    private func statementSection(_ statement: IncidentStatement) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(statement.title)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Spacer(minLength: 8)

                if let source {
                    SourceBadge(source: source)
                }
            }

            Text(statement.statement)
                .font(.system(size: 15, weight: .regular))
                .lineSpacing(2)
                .foregroundStyle(RidaryTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if !statement.timeline.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Timeline")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(RidaryTheme.textSecondary)

                    ForEach(statement.timeline) { item in
                        Text("+\(item.atSeconds)s · \(item.text)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                }
                .padding(.top, 2)
            }

            if !statement.evidenceChecklist.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Evidence checklist")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(RidaryTheme.textSecondary)

                    ForEach(statement.evidenceChecklist, id: \.self) { item in
                        Label(item, systemImage: "checkmark.circle")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                }
                .padding(.top, 2)
            }

            if let source, source == .fallback {
                Text("On-device AI was unavailable; the statement used local rules. Cloud was not used for this sensitive record.")
                    .font(RidaryType.caption)
                    .foregroundStyle(RidaryTheme.warning)
            }
        }
    }

    private var actionBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(RidaryTheme.border.opacity(0.65))
                .frame(height: 1)

            Group {
                if current.statement == nil {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Severity \(current.severity)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(RidaryTheme.textPrimary)

                            Text(current.status.title)
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundStyle(RidaryTheme.textTertiary)
                        }

                        Spacer(minLength: 8)

                        Button {
                            draftStatement()
                        } label: {
                            Group {
                                if isDrafting {
                                    ProgressView()
                                        .tint(RidaryTheme.onAccent)
                                } else {
                                    HStack(spacing: 6) {
                                        Image(systemName: "text.quote")
                                            .font(.system(size: 13, weight: .medium))
                                        Text("Draft statement")
                                    }
                                }
                            }
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundStyle(RidaryTheme.onAccent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.capsule)
                        .tint(RidaryTheme.sky)
                        .disabled(isDrafting)
                    }
                } else {
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Statement ready")
                                .font(.system(size: 15, weight: .semibold, design: .default))
                                .foregroundStyle(RidaryTheme.textPrimary)

                            Text("Severity \(current.severity)")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundStyle(RidaryTheme.textTertiary)
                        }

                        Spacer(minLength: 6)

                        if let statement = current.statement {
                            ShareLink(item: statement.statement) {
                                Text("Text")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundStyle(RidaryTheme.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                        }

                        Button {
                            sharePDF()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.richtext")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("PDF")
                            }
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundStyle(RidaryTheme.onAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.capsule)
                        .tint(RidaryTheme.sky)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 11)
            .padding(.bottom, 8)
        }
        .background(RidaryTheme.surface.ignoresSafeArea(edges: .bottom))
    }

    private func draftStatement() {
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
    }

    private func sharePDF() {
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
    }

    private func answerBinding(for id: String) -> Binding<String> {
        Binding(
            get: { answers[id] ?? "" },
            set: { answers[id] = $0 }
        )
    }
}
