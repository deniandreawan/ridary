import SwiftUI

struct AskRidaryView: View {
    @EnvironmentObject private var app: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var draft = ""
    @State private var messages: [AskRidaryMessage] = []
    @State private var isSending = false
    @State private var askTask: Task<Void, Never>?
    @FocusState private var composerFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if messages.isEmpty {
                            emptyIntro
                            suggestionsCard
                        } else {
                            ForEach(messages) { message in
                                messageRow(message)
                            }

                            if isSending {
                                typingRow
                            }
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: isSending) { _, _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }

            composer
        }
        .background(RidaryTheme.surface.ignoresSafeArea())
        .accessibilityIdentifier("ask-ridary-screen")
        .onDisappear {
            askTask?.cancel()
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityLabel("Close Ask Ridary")

                Spacer()

                Text("Ask Ridary")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)

                Spacer()

                if messages.isEmpty {
                    Color.clear
                        .frame(width: 42, height: 28)
                } else {
                    Button {
                        clearConversation()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(RidaryTheme.textPrimary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Clear conversation")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)

            Rectangle()
                .fill(RidaryTheme.border.opacity(0.65))
                .frame(height: 1)
        }
        .background(RidaryTheme.surface)
    }

    private var emptyIntro: some View {
        VStack(spacing: 10) {
            Text("Ask about your rides")
                .font(.system(size: 23, weight: .semibold, design: .default))
                .tracking(-0.35)
                .foregroundStyle(RidaryTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Ride summaries, weekly patterns, and proof — answered privately.")
                .font(.system(size: 15, weight: .regular, design: .default))
                .lineSpacing(3)
                .foregroundStyle(RidaryTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 5) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)

                Text("On-device first · cloud sees summaries only")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textTertiary)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 14)
    }

    private var suggestionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try asking")
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundStyle(RidaryTheme.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                    Button {
                        send(suggestion)
                    } label: {
                        HStack(spacing: 12) {
                            Text(suggestion)
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundStyle(RidaryTheme.textPrimary)
                                .multilineTextAlignment(.leading)

                            Spacer(minLength: 8)

                            Image(systemName: "arrow.up.left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(RidaryTheme.textTertiary)
                        }
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < suggestions.count - 1 {
                        Divider().overlay(RidaryTheme.border.opacity(0.65))
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(RidaryTheme.backgroundLifted)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(.top, 6)
    }

    private var suggestions: [String] {
        if app.rides.isEmpty {
            return [
                "How does Ridary record a ride?",
                "Where does my ride data go?",
                "What is Ridary Proof?"
            ]
        }

        var items = [
            "Why was my last ride marked risky?",
            "How did my week look?"
        ]
        if app.credentials.first == nil {
            items.append("What is Ridary Proof?")
        } else {
            items.append("What does my Ridary Proof mean?")
        }
        return items
    }

    private var typingRow: some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                    .tint(RidaryTheme.sky)

                Text("Thinking…")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RidaryTheme.backgroundLifted)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer(minLength: 48)
        }
    }

    private func messageRow(_ message: AskRidaryMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user {
                Spacer(minLength: 48)
            }

            VStack(
                alignment: message.role == .user ? .trailing : .leading,
                spacing: 6
            ) {
                Text(message.text)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .lineSpacing(2)
                    .foregroundStyle(RidaryTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .user
                            ? RidaryTheme.skySoft
                            : RidaryTheme.backgroundLifted
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                if let source = message.source {
                    HStack(spacing: 4) {
                        Image(systemName: source.icon)
                            .font(.system(size: 10, weight: .medium))

                        Text(source.label)
                            .font(.system(size: 11, weight: .medium, design: .default))
                    }
                    .foregroundStyle(RidaryTheme.textTertiary)
                    .padding(.horizontal, 4)
                }
            }

            if message.role == .assistant {
                Spacer(minLength: 48)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var composer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(RidaryTheme.border.opacity(0.65))
                .frame(height: 1)

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Ask about your rides", text: $draft, axis: .vertical)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)
                    .lineLimit(1...4)
                    .focused($composerFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        send(draft)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(RidaryTheme.backgroundLifted)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                Button {
                    send(draft)
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(canSend ? RidaryTheme.onAccent : RidaryTheme.textTertiary)
                        .frame(width: 42, height: 42)
                        .background(canSend ? RidaryTheme.sky : RidaryTheme.backgroundLifted)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
                .accessibilityLabel("Send question")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)
        }
        .background(RidaryTheme.surface)
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    private func send(_ raw: String) {
        let question = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isSending else { return }

        let history = messages.suffix(4).map { message in
            AskRidaryTurn(role: message.role, text: message.text)
        }

        messages.append(AskRidaryMessage(role: .user, text: question))
        draft = ""
        isSending = true
        composerFocused = false

        askTask?.cancel()
        askTask = Task { @MainActor in
            let reply = await app.askRidary(question: question, history: history)
            guard !Task.isCancelled else { return }
            messages.append(
                AskRidaryMessage(
                    role: .assistant,
                    text: reply.text,
                    source: reply.source
                )
            )
            isSending = false
        }
    }

    private func clearConversation() {
        askTask?.cancel()
        isSending = false
        messages.removeAll()
        draft = ""
    }
}
