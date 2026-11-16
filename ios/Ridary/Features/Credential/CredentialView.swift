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
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ridary Proof")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("A signed safety credential built from your private ride summaries.")
                        .font(.footnote)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }

                if let latest {
                    credentialCard(latest)
                    if let verification {
                        verificationCard(verification)
                    }
                    if app.credentials.count > 1 {
                        pastCredentials
                    }
                } else {
                    emptyCard
                }

                Text("Ridary Proof is a personal safety credential, not legal proof, a court record, or an insurance guarantee.")
                    .font(.caption2)
                    .foregroundStyle(RidaryTheme.textTertiary)
            }
            .padding(20)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationTitle("Credential")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $insurerView) { view in
            InsurerShareSheet(view: view)
        }
    }

    private func credentialCard(_ credential: Credential) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ScoreRing(score: credential.score, size: 110)
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(credential.band) band")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Label("Signed by \(credential.issuer)", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(RidaryTheme.teal)
                    Text(credential.periodText)
                        .font(.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                    Text(credential.mode.title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(RidaryTheme.accent)
                }
            }

            HStack(spacing: 10) {
                StatTile(
                    icon: "road.lanes",
                    value: "\(credential.rideCount)",
                    label: "rides"
                )
                StatTile(
                    icon: "exclamationmark.triangle",
                    value: "\(credential.eventCount)",
                    label: "moments",
                    tint: RidaryTheme.warning
                )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Key \(credential.publicKeyId)")
                    .font(.caption2.monospaced())
                    .foregroundStyle(RidaryTheme.textTertiary)
                Text("Payload \(credential.payloadHash.prefix(20))…")
                    .font(.caption2.monospaced())
                    .foregroundStyle(RidaryTheme.textTertiary)
            }

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
                            .tint(.black)
                    } else {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                .buttonStyle(RidaryPrimaryButtonStyle())
            }
        }
        .ridaryCard(padding: 20)
    }

    private func verificationCard(_ verification: CredentialVerification) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: verification.valid ? "checkmark.seal.fill" : "xmark.seal.fill")
                .foregroundStyle(verification.valid ? RidaryTheme.teal : RidaryTheme.danger)
            VStack(alignment: .leading, spacing: 4) {
                Text(verification.valid ? "Signature valid" : "Verification failed")
                    .font(.footnote.weight(.semibold))
                if let reason = verification.reason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                } else if verification.valid {
                    Text("The credential hash and Ed25519 signature match.")
                        .font(.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            }
        }
        .ridaryCard(padding: 14)
    }

    private var pastCredentials: some View {
        VStack(alignment: .leading, spacing: 10) {
            RidarySectionHeader(title: "Past credentials")
            ForEach(app.credentials.dropFirst()) { credential in
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(credential.periodText)
                            .font(.subheadline.weight(.semibold))
                        Text("Score \(credential.score) · \(credential.rideCount) rides")
                            .font(.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                    Spacer()
                    Text(credential.band)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(RidaryTheme.teal)
                }
                .padding(14)
                .background(RidaryTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            RidaryEmptyState(
                icon: "checkmark.shield",
                title: "No credential yet",
                message: "Record at least 3 rides in the last 30 days, then issue a signed Ridary Proof."
            )
            if !app.isFirebaseConfigured {
                Text("Credential issuance needs a configured Firebase project and sign-in.")
                    .font(.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
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
                        .tint(.black)
                } else {
                    Label("Issue credential", systemImage: "seal.fill")
                }
            }
            .buttonStyle(RidaryPrimaryButtonStyle())
            .disabled(isIssuing)
        }
        .ridaryCard()
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
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("This link shows only the signed credential. It does not expose your route, sensor data, or account identity.")
                    .font(.footnote)
                    .foregroundStyle(RidaryTheme.textSecondary)

                Text(view.url)
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RidaryTheme.cardElevated)
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
