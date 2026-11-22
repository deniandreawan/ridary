import SwiftUI
import UIKit

struct CredentialView: View {
    @EnvironmentObject private var app: AppEnvironment

    @State private var isIssuing = false
    @State private var isSharing = false
    @State private var isVerifying = false
    @State private var verification: CredentialVerification?
    @State private var insurerView: InsurerView?

    private var latest: Credential? {
        app.credentials.first
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                header
                if let latest {
                    certificate(latest)
                    if let verification {
                        verificationCard(verification)
                    }
                    if app.credentials.count > 1 {
                        pastCredentials
                    }
                } else {
                    emptyCard
                }
                disclaimer
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 32)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(RidaryTheme.background, for: .navigationBar)
        .sheet(item: $insurerView) { view in
            InsurerShareSheet(view: view)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Proof, not surveillance")
                .font(RidaryType.display)
                .tracking(-0.8)
                .foregroundStyle(RidaryTheme.textPrimary)
            Text("A signed safety credential. Share the pattern, never the route.")
                .font(RidaryType.caption)
                .foregroundStyle(RidaryTheme.textSecondary)
        }
    }

    private func certificate(_ credential: Credential) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("RIDARY PROOF")
                    .font(.system(size: 11, weight: .black, design: .default))
                    .tracking(2.2)
                    .foregroundStyle(RidaryTheme.accent)
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(RidaryTheme.skyDeep)
            }

            HStack(spacing: 16) {
                ScoreRing(score: credential.score, size: 112, lineWidth: 9)
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(credential.band) band")
                        .font(.system(size: 28, weight: .heavy, design: .default))
                        .tracking(-0.7)
                    Label("Signed by \(credential.issuer)", systemImage: "checkmark.seal.fill")
                        .font(RidaryType.caption)
                        .foregroundStyle(RidaryTheme.skyDeep)
                    Text(credential.periodText)
                        .font(RidaryType.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                    Text(credential.mode.title)
                        .font(RidaryType.micro)
                        .foregroundStyle(RidaryTheme.accent)
                        .textCase(.uppercase)
                }
            }

            Rectangle()
                .fill(RidaryTheme.border)
                .frame(height: 1)

            HStack(spacing: 0) {
                ProofMetric(value: "\(credential.rideCount)", label: "rides")
                proofDivider
                ProofMetric(value: "\(credential.eventCount)", label: "moments")
                proofDivider
                ProofMetric(value: credential.band, label: "band")
                proofDivider
                ProofMetric(value: formatDate(credential.expiresAt), label: "expires")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("KEY \(credential.publicKeyId)")
                    .font(RidaryType.micro)
                    .foregroundStyle(RidaryTheme.textTertiary)
                Text(credential.payloadHash)
                    .font(RidaryType.mono)
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RidaryTheme.backgroundLifted)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 10) {
                Button {
                    Task {
                        isVerifying = true
                        verification = await app.verifyCredential(
                            credentialID: credential.credentialId
                        )
                        isVerifying = false
                    }
                } label: {
                    if isVerifying {
                        ProgressView()
                            .tint(RidaryTheme.onSky)
                    } else {
                        Label("Verify", systemImage: "checkmark.shield")
                    }
                }
                .buttonStyle(RidarySecondaryButtonStyle())

                Button {
                    Task {
                        isSharing = true
                        insurerView = await app.createInsurerView(
                            credentialID: credential.credentialId
                        )
                        isSharing = false
                    }
                } label: {
                    if isSharing {
                        ProgressView()
                            .tint(RidaryTheme.onSky)
                    } else {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                .buttonStyle(RidaryPrimaryButtonStyle())
            }
        }
        .padding(20)
        .background(RidaryTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(RidaryTheme.heroGradient)
                .frame(height: 5)
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.top, 8)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(RidaryTheme.border, lineWidth: 1)
        )
        .shadow(color: RidaryTheme.shadow, radius: 22, x: 0, y: 12)
    }

    private var proofDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border)
            .frame(width: 1, height: 34)
    }

    private func verificationCard(_ verification: CredentialVerification) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: verification.valid ? "checkmark.seal.fill" : "xmark.seal.fill")
                .foregroundStyle(verification.valid ? RidaryTheme.skyDeep : RidaryTheme.danger)
            VStack(alignment: .leading, spacing: 4) {
                Text(verification.valid ? "Signature valid" : "Verification failed")
                    .font(RidaryType.bodyStrong)
                if let reason = verification.reason {
                    Text(reason)
                        .font(RidaryType.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                } else if verification.valid {
                    Text("The credential hash and Ed25519 signature match.")
                        .font(RidaryType.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            }
        }
        .ridaryCard(padding: 15)
    }

    private var pastCredentials: some View {
        VStack(alignment: .leading, spacing: 10) {
            RidarySectionHeader(title: "Earlier proofs")
            ForEach(app.credentials.dropFirst()) { credential in
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(credential.periodText)
                            .font(RidaryType.bodyStrong)
                        Text("Score \(credential.score) · \(credential.rideCount) rides")
                            .font(RidaryType.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                    Spacer()
                    Text(credential.band)
                        .font(.system(size: 18, weight: .heavy, design: .default))
                        .foregroundStyle(RidaryTheme.skyDeep)
                }
                .ridaryCard(padding: 14)
            }
        }
    }

    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: "seal")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(RidaryTheme.accent)
                    .frame(width: 52, height: 52)
                    .background(RidaryTheme.accentSoft)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Build your proof")
                        .font(RidaryType.title)
                    Text("\(min(app.rides.count, 3)) of 3 rides recorded.")
                        .font(RidaryType.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            }

            ProgressView(value: Double(min(app.rides.count, 3)), total: 3)
                .tint(RidaryTheme.accent)

            Text("Record at least three rides in the last 30 days, then issue a signed credential that an insurer can verify.")
                .font(RidaryType.caption)
                .foregroundStyle(RidaryTheme.textSecondary)

            if !app.isFirebaseConfigured {
                Text("Credential issuance needs a configured Firebase project and sign-in.")
                    .font(RidaryType.caption)
                    .foregroundStyle(RidaryTheme.warning)
            }

            Button {
                Task {
                    isIssuing = true
                    _ = await app.issueCredential()
                    isIssuing = false
                }
            } label: {
                if isIssuing {
                    ProgressView()
                        .tint(RidaryTheme.onSky)
                } else {
                    Label("Issue credential", systemImage: "seal.fill")
                }
            }
            .buttonStyle(RidaryPrimaryButtonStyle())
            .disabled(isIssuing)
        }
        .ridaryCard()
    }

    private var disclaimer: some View {
        Text("Ridary Proof is a personal safety credential, not legal proof, a court record, or an insurance guarantee.")
            .font(RidaryType.micro)
            .foregroundStyle(RidaryTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private func formatDate(_ raw: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: raw) else { return raw }
        let display = DateFormatter()
        display.dateStyle = .short
        display.timeStyle = .none
        return display.string(from: date)
    }
}

private struct ProofMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(RidaryTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(RidaryType.micro)
                .foregroundStyle(RidaryTheme.textTertiary)
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
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
