import SwiftUI
import UIKit

struct CredentialView: View {
    @EnvironmentObject private var app: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var isIssuing = false
    @State private var isSharing = false
    @State private var isVerifying = false
    @State private var verification: CredentialVerification?
    @State private var insurerView: InsurerView?
    @State private var scrollOffset: CGFloat = 0
    var isModal = false

    private var latest: Credential? {
        app.credentials.first
    }

    private var credentialReady: Bool {
        app.rides.count >= 3
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    heroCard

                    VStack(spacing: 0) {
                        if let latest {
                            editorialIntro(latest)
                                .padding(.horizontal, 28)
                                .padding(.top, 26)
                                .padding(.bottom, 24)

                            sectionDivider

                            highlightStrip(latest)
                                .padding(.horizontal, 24)

                            sectionDivider

                            highlightsSection(latest)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 24)

                            if let verification {
                                sectionDivider
                                verificationRow(verification)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                            }

                            if app.credentials.count > 1 {
                                sectionDivider
                                pastCredentials
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 24)
                            }
                        } else {
                            emptySection
                                .padding(.horizontal, 28)
                                .padding(.top, 26)
                                .padding(.bottom, 24)
                        }

                        sectionDivider

                        Text("Ridary Proof is a personal safety credential, not legal proof, a court record, or an insurance guarantee.")
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
                .accessibilityIdentifier("credential-screen")
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
        .sheet(item: $insurerView) { view in
            InsurerShareSheet(view: view)
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
                .accessibilityLabel(isModal ? "Close Ridary Proof" : "Back")

                Spacer()

                if isTopBarSolid {
                    Text(latest.map { "Ridary Proof · \($0.mode.title)" } ?? "Ridary Proof")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .transition(.opacity)

                    Spacer()
                }

                if let latest {
                    Button {
                        share(latest)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(RidaryTheme.textPrimary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Share proof")
                } else {
                    Color.clear
                        .frame(width: 42, height: 28)
                }
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
        scrollOffset > 120
    }

    private var heroCard: some View {
        VStack(spacing: 14) {
            if let latest {
                Text("Valid until \(formatDate(latest.expiresAt))")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.skyDeep)

                ZStack {
                    Circle()
                        .fill(RidaryTheme.surface)
                        .frame(width: 56, height: 56)
                        .shadow(color: RidaryTheme.sky.opacity(0.14), radius: 12, x: 0, y: 4)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(RidaryTheme.sky)
                }
                .padding(.vertical, 2)

                VStack(spacing: 4) {
                    Text("\(latest.band) Band")
                        .font(.system(size: 32, weight: .semibold, design: .default))
                        .tracking(-0.7)
                        .foregroundStyle(RidaryTheme.textPrimary)

                    Text("\(latest.periodText) · \(latest.rideCount) rides")
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            } else {
                Text("30-day window")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.skyDeep)

                ZStack {
                    Circle()
                        .fill(RidaryTheme.surface)
                        .frame(width: 56, height: 56)
                        .shadow(color: RidaryTheme.sky.opacity(0.14), radius: 12, x: 0, y: 4)

                    Image(systemName: "seal.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(RidaryTheme.sky)
                }

                VStack(spacing: 4) {
                    Text("Build your proof")
                        .font(.system(size: 26, weight: .semibold, design: .default))
                        .tracking(-0.5)
                        .foregroundStyle(RidaryTheme.textPrimary)

                    Text("\(min(app.rides.count, 3)) of 3 rides recorded")
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            }
        }
        .padding(.top, 88)
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    RidaryTheme.skySoft,
                    RidaryTheme.skySoft.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func editorialIntro(_ credential: Credential) -> some View {
        VStack(spacing: 10) {
            Text("Proof, not surveillance")
                .font(.system(size: 23, weight: .semibold, design: .default))
                .tracking(-0.35)
                .foregroundStyle(RidaryTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("A cryptographic summary of your recent rides. Share your safety band with an insurer without exposing routes or raw GPS.")
                .font(.system(size: 15, weight: .regular, design: .default))
                .lineSpacing(3)
                .foregroundStyle(RidaryTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 5) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)

                Text("Signed by \(credential.issuer)")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text("· Ed25519 verified")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }

    private func highlightStrip(_ credential: Credential) -> some View {
        HStack(spacing: 0) {
            CenteredProofMetric(
                value: "\(credential.band) Band",
                label: "Safety tier",
                valueColor: RidaryTheme.skyDeep
            )

            proofDivider

            CenteredProofMetric(
                value: "\(credential.score)",
                label: "Out of 100"
            )

            proofDivider

            CenteredProofMetric(
                value: "\(credential.rideCount) rides",
                label: "\(credential.eventCount) moments"
            )
        }
        .padding(.vertical, 18)
    }

    private func highlightsSection(_ credential: Credential) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("What this credential proves")
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundStyle(RidaryTheme.textPrimary)

            highlightRow(
                icon: "checkmark.seal.fill",
                title: "Signed by \(credential.issuer)",
                subtitle: "Cryptographic Ed25519 signature verifying your safety band and ride count."
            )

            highlightRow(
                icon: "lock.shield.fill",
                title: "Zero raw GPS shared",
                subtitle: "Insurers see only your aggregate score and period—never routes or timestamps."
            )

            highlightRow(
                icon: "calendar.badge.clock",
                title: "Valid until \(formatDate(credential.expiresAt))",
                subtitle: "Covers your \(credential.mode.title.lowercased()) sessions from \(credential.periodText)."
            )

            highlightRow(
                icon: "key.fill",
                title: "Key \(credential.publicKeyId)",
                subtitle: credential.payloadHash,
                monospacedSubtitle: true
            )
        }
    }

    private func highlightRow(
        icon: String,
        title: String,
        subtitle: String,
        monospacedSubtitle: Bool = false
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RidaryTheme.sky)
                .frame(width: 34, height: 34)
                .background(RidaryTheme.skySoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text(subtitle)
                    .font(monospacedSubtitle ? RidaryType.mono : .system(size: 13, weight: .regular))
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .lineLimit(monospacedSubtitle ? 1 : 3)
                    .truncationMode(monospacedSubtitle ? .middle : .tail)
                    .fixedSize(horizontal: false, vertical: !monospacedSubtitle)
            }

            Spacer(minLength: 0)
        }
    }

    private var proofDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border.opacity(0.65))
            .frame(width: 1, height: 28)
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border.opacity(0.65))
            .frame(height: 1)
            .padding(.horizontal, 24)
    }

    private func verificationRow(_ verification: CredentialVerification) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: verification.valid ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(verification.valid ? RidaryTheme.sky : RidaryTheme.danger)
                .frame(width: 34, height: 34)
                .background(verification.valid ? RidaryTheme.skySoft : RidaryTheme.danger.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(verification.valid ? "Signature valid" : "Verification failed")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(RidaryTheme.textPrimary)

                if let reason = verification.reason {
                    Text(reason)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(RidaryTheme.textSecondary)
                } else if verification.valid {
                    Text("The credential hash and Ed25519 signature match.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            }
        }
    }

    private var pastCredentials: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Earlier proofs")
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundStyle(RidaryTheme.textPrimary)
                .padding(.bottom, 10)

            ForEach(Array(app.credentials.dropFirst().enumerated()), id: \.element.id) { index, credential in
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(credential.periodText)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(RidaryTheme.textPrimary)

                        Text("Score \(credential.score) · \(credential.rideCount) rides")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }

                    Spacer()

                    Text(credential.band)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(RidaryTheme.skyDeep)
                }
                .padding(.vertical, 13)

                if index < app.credentials.count - 2 {
                    Divider().overlay(RidaryTheme.border.opacity(0.65))
                }
            }
        }
    }

    private var emptySection: some View {
        VStack(spacing: 14) {
            Text("Proof, not surveillance")
                .font(.system(size: 23, weight: .semibold, design: .default))
                .tracking(-0.35)
                .foregroundStyle(RidaryTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Record at least three rides in the last 30 days, then issue a signed credential that an insurer can verify without seeing your routes.")
                .font(.system(size: 15, weight: .regular, design: .default))
                .lineSpacing(3)
                .foregroundStyle(RidaryTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            ProgressView(value: Double(min(app.rides.count, 3)), total: 3)
                .tint(RidaryTheme.sky)
                .padding(.top, 4)

            if !app.isFirebaseConfigured {
                Text("Credential issuance needs a configured Firebase project and sign-in.")
                    .font(RidaryType.caption)
                    .foregroundStyle(RidaryTheme.warning)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var actionBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(RidaryTheme.border.opacity(0.65))
                .frame(height: 1)

            Group {
                if let latest {
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(latest.band) Band")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(RidaryTheme.textPrimary)

                                Text("· \(latest.score) / 100")
                                    .font(.system(size: 13, weight: .regular, design: .default))
                                    .foregroundStyle(RidaryTheme.textSecondary)
                            }

                            Text("Expires \(formatDate(latest.expiresAt))")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundStyle(RidaryTheme.textTertiary)
                        }

                        Spacer(minLength: 8)

                        Button {
                            verify(latest)
                        } label: {
                            Group {
                                if isVerifying {
                                    ProgressView()
                                        .tint(RidaryTheme.textPrimary)
                                } else {
                                    Text("Verify")
                                }
                            }
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundStyle(RidaryTheme.textPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.glass)
                        .buttonBorderShape(.capsule)
                        .disabled(isVerifying)

                        Button {
                            share(latest)
                        } label: {
                            Group {
                                if isSharing {
                                    ProgressView()
                                        .tint(RidaryTheme.onAccent)
                                } else {
                                    HStack(spacing: 6) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 13, weight: .semibold))
                                        Text("Share")
                                    }
                                }
                            }
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundStyle(RidaryTheme.onAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.capsule)
                        .tint(RidaryTheme.sky)
                        .disabled(isSharing)
                    }
                } else {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(min(app.rides.count, 3)) / 3 rides")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(RidaryTheme.textPrimary)

                            Text("30-day window")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundStyle(RidaryTheme.textTertiary)
                        }

                        Spacer(minLength: 8)

                        Button {
                            issue()
                        } label: {
                            Group {
                                if isIssuing {
                                    ProgressView()
                                        .tint(RidaryTheme.onAccent)
                                } else {
                                    HStack(spacing: 6) {
                                        Image(systemName: "seal.fill")
                                            .font(.system(size: 13, weight: .semibold))
                                        Text("Issue proof")
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
                        .tint(credentialReady ? RidaryTheme.sky : RidaryTheme.textTertiary)
                        .disabled(isIssuing || !credentialReady)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 11)
            .padding(.bottom, 8)
        }
        .background(RidaryTheme.surface.ignoresSafeArea(edges: .bottom))
    }

    private func issue() {
        Task {
            isIssuing = true
            _ = await app.issueCredential()
            isIssuing = false
        }
    }

    private func verify(_ credential: Credential) {
        Task {
            isVerifying = true
            verification = await app.verifyCredential(credentialID: credential.credentialId)
            isVerifying = false
        }
    }

    private func share(_ credential: Credential) {
        Task {
            isSharing = true
            insurerView = await app.createInsurerView(credentialID: credential.credentialId)
            isSharing = false
        }
    }

    private func formatDate(_ raw: String) -> String {
        guard let date = CredentialDateParser.date(from: raw) else { return raw }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .none
        return display.string(from: date)
    }
}

private struct CenteredProofMetric: View {
    let value: String
    let label: String
    var valueColor: Color = RidaryTheme.textPrimary

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(label)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(RidaryTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct InsurerShareSheet: View {
    let view: InsurerView
    @Environment(\.dismiss) private var dismiss

    private var url: URL? {
        URL(string: view.url)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Share with an insurer")
                    .font(RidaryType.title)

                Text("This link shows only the signed credential. It never exposes your route, sensor data, or account identity.")
                    .font(RidaryType.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)

                Text(view.url)
                    .font(RidaryType.mono)
                    .textSelection(.enabled)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RidaryTheme.backgroundLifted)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                if let url {
                    ShareLink(item: url) {
                        Label("Open share sheet", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(RidaryPrimaryButtonStyle())
                }

                Button("Copy link") {
                    UIPasteboard.general.string = view.url
                }
                .buttonStyle(RidarySecondaryButtonStyle())

                Spacer()
            }
            .padding(20)
            .background(RidaryTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
