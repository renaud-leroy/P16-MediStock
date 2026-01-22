import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .accessibilityLabel("Adresse e-mail")
                .accessibilityHint("Saisir votre adresse e-mail")
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .accessibilityLabel("Mot de passe")
                .accessibilityHint("Saisir votre mot de passe")
                .textContentType(.password)
            VStack(spacing: 20) {
                Button("Login") {
                    session.signIn(email: email, password: password)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.automatic)
                .accessibilityLabel("Se connecter")
                Button("SignUp") {
                    session.signUp(email: email, password: password)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Créer un compte")
            }
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(SessionStore())
    }
}
