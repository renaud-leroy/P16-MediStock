import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Branding
            VStack(alignment: .center) {
                Image(systemName: "pills.circle.fill")
                    .resizable()
                    .frame(width: 140, height: 140)
                    .foregroundStyle(.pink)

                Text("MediStock")
                    .font(.title)
                    .fontWeight(.bold)
            }
            // MARK: - Error display
            if let error = session.authError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .accessibilityLabel("Erreur d'authentification : \(error)")
            }

            // MARK: - Fields
            TextField("Email", text: $email)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.primary.opacity(0.25), lineWidth: 1)
                )
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .accessibilityLabel("Adresse e-mail")
                .accessibilityHint("Saisir votre adresse e-mail")
            SecureField("Password", text: $password)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.primary.opacity(0.25), lineWidth: 1)
                )
                .autocapitalization(.none)
                .accessibilityLabel("Mot de passe")
                .accessibilityHint("Saisir votre mot de passe")
                .textContentType(.password)


            // MARK: - Buttons
            VStack(spacing: 30) {
                PrimaryButton(title: "Login") {
                    Task {
                        await session.signIn(email: email, password: password)
                    }
                }
                .accessibilityLabel("Se connecter")
                PrimaryButton(title: "SignUp") {
                    Task {
                        await session.signUp(email: email, password: password)
                    }
                }
                .accessibilityLabel("Créer un compte")
            }
        }
        .padding()
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () async -> Void
    var isLoading: Bool = false

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Text(title)
                    .frame(maxWidth: 80)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.pink)
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(SessionStore())
    }
}

