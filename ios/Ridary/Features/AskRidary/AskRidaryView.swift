import SwiftUI

struct AskRidaryView: View {
    @State private var draft = ""
    @FocusState private var composerFocused: Bool

    private let suggestions = [
        "Why was this ride marked risky?",
        "How did my week look?",
        "What should I capture after a near miss?"
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    intro
                    previewNotice
                    suggestionsBlock
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            composer
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationTitle("Ask Ridary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(RidaryTheme.background, for: .navigationBar)
        .toolbar(.visible, for: .navigationBar)
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(RidaryTheme.accent)
                .frame(width: 54, height: 54)
                .background(RidaryTheme.skySoft)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

            VStack(alignment: .leading, spacing: 7) {
                Text("Ask about your rides")
                    .font(RidaryType.display)
                    .tracking(-0.7)
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text("Ride summaries, weekly patterns, and proof—answered privately.")
                    .font(RidaryType.body)
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var previewNotice: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(RidaryTheme.accent)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text("Chat preview")
                    .font(RidaryType.bodyStrong)
                    .foregroundStyle(RidaryTheme.textPrimary)
                Text("Replies aren’t live yet. You can still explore the questions below.")
                    .font(RidaryType.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RidaryTheme.skySoft)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var suggestionsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try asking")
                .font(RidaryType.section)
                .foregroundStyle(RidaryTheme.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                    Button {
                        draft = suggestion
                        composerFocused = true
                    } label: {
                        HStack(spacing: 12) {
                            Text(suggestion)
                                .font(RidaryType.body)
                                .foregroundStyle(RidaryTheme.textPrimary)
                                .multilineTextAlignment(.leading)

                            Spacer(minLength: 8)

                            Image(systemName: "arrow.up.left")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(RidaryTheme.textTertiary)
                        }
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < suggestions.count - 1 {
                        Divider().overlay(RidaryTheme.border)
                    }
                }
            }
            .padding(.horizontal, 15)
            .background(RidaryTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(RidaryTheme.border, lineWidth: 1)
            )
        }
    }

    private var composer: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 10) {
                TextField("Ask Ridary", text: $draft, axis: .vertical)
                    .font(RidaryType.body)
                    .foregroundStyle(RidaryTheme.textPrimary)
                    .lineLimit(1...4)
                    .focused($composerFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        composerFocused = false
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(RidaryTheme.backgroundLifted)
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

                Button(action: {}) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(RidaryTheme.textTertiary)
                        .frame(width: 42, height: 42)
                        .background(RidaryTheme.backgroundLifted)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(true)
                .accessibilityLabel("Send")
                .accessibilityHint("Chat preview. Replies are not live yet.")
            }

            Text("Preview only · replies aren’t live yet")
                .font(RidaryType.micro)
                .foregroundStyle(RidaryTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 3)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(RidaryTheme.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(RidaryTheme.border)
                .frame(height: 1)
        }
    }
}
