import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var app: AppEnvironment

    @State private var email = ""
    @State private var password = ""
    @State private var isCreatingAccount = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(RidaryTheme.accent)
                    Text("RIDARY")
                        .font(.system(.title, design: .rounded, weight: .black))
                        .tracking(3)
                    Text("Private ride witness. Collective road safety.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
                .padding(.top, 36)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isCreatingAccount ? "Create an account" : "Sign in")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                        Text("Use the same account on iOS and the web dashboard.")
                            .font(.footnote)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(RidaryTheme.backgroundLifted)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding(14)
                        .background(RidaryTheme.backgroundLifted)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    if let authError = app.authError {
                        Text(authError)
                            .font(.footnote)
                            .foregroundStyle(RidaryTheme.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            if isCreatingAccount {
                                await app.auth.signUp(email: email, password: password)
                            } else {
                                await app.auth.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        if app.authBusy {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text(isCreatingAccount ? "Create account" : "Sign in")
                        }
                    }
                    .buttonStyle(RidaryPrimaryButtonStyle())
                    .disabled(app.authBusy)

                    Button(isCreatingAccount ? "I already have an account" : "Create an account") {
                        isCreatingAccount.toggle()
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(RidaryTheme.accent)

                    Divider()
                        .overlay(RidaryTheme.border)

                    Button("Continue as guest") {
                        Task {
                            await app.auth.signInAnonymously()
                        }
                    }
                    .buttonStyle(RidarySecondaryButtonStyle())

                    Button("Explore local demo") {
                        app.enterLocalDemo()
                    }
                    .font(.footnote)
                    .foregroundStyle(RidaryTheme.textSecondary)
                }
                .ridaryCard(padding: 20)

                if !app.isFirebaseConfigured {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Firebase setup needed", systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(RidaryTheme.warning)
                        Text(app.firebaseStatus.detail)
                            .font(.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                    .ridaryCard()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}
