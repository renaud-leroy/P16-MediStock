import Foundation
import Firebase

// MARK: - Protocol

@MainActor
protocol SessionStoreProtocol: ObservableObject {
    var session: User? { get }
    var authError: String? { get }
    func listen()
    func signUp(email: String, password: String) async
    func signIn(email: String, password: String) async
    func signOut()
    func unbind()
}

// MARK: - SessionStore

@MainActor
final class SessionStore: ObservableObject, SessionStoreProtocol {
    @Published var session: User?
    @Published var authError: String?

    private var handle: AuthStateDidChangeListenerHandle?

    // MARK: - Listener

    func listen() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    self?.session = User(uid: user.uid, email: user.email)
                } else {
                    self?.session = nil
                }
            }
        }
    }

    // MARK: - Authentication

    func signUp(email: String, password: String) async {
        authError = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            session = User(uid: result.user.uid, email: result.user.email)
        } catch {
            authError = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        authError = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            session = User(uid: result.user.uid, email: result.user.email)
        } catch {
            authError = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            session = nil
        } catch {
            authError = error.localizedDescription
        }
    }

    // MARK: - Cleanup

    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

