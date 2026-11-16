import Combine
import FirebaseAuth
import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var userID: String?
    @Published private(set) var email: String?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isBusy = false
    @Published private(set) var isLocalDemo = false

    let isConfigured: Bool
    private var authHandle: AuthStateDidChangeListenerHandle?

    init(isConfigured: Bool) {
        self.isConfigured = isConfigured
        if isConfigured {
            listen()
        }
    }

    func enterLocalDemo() {
        isLocalDemo = true
        userID = "local-demo-user"
        email = nil
        errorMessage = nil
    }

    func signIn(email: String, password: String) async {
        guard isConfigured else {
            errorMessage = "Firebase is not configured."
            return
        }
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            errorMessage = "Enter an email and password."
            return
        }

        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            userID = result.user.uid
            self.email = result.user.email
            isLocalDemo = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        guard isConfigured else {
            errorMessage = "Firebase is not configured."
            return
        }
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              password.count >= 6 else {
            errorMessage = "Use a valid email and a password with at least 6 characters."
            return
        }

        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            userID = result.user.uid
            self.email = result.user.email
            isLocalDemo = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInAnonymously() async {
        guard isConfigured else {
            errorMessage = "Firebase is not configured."
            return
        }

        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let result = try await Auth.auth().signInAnonymously()
            userID = result.user.uid
            email = nil
            isLocalDemo = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        if isConfigured {
            try? Auth.auth().signOut()
        }
        userID = nil
        email = nil
        errorMessage = nil
        isLocalDemo = false
    }

    private func listen() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.userID = user?.uid
                self?.email = user?.email
                if user != nil {
                    self?.isLocalDemo = false
                }
            }
        }
    }
}
