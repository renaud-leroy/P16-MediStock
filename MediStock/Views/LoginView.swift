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
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            VStack(spacing: 20) {
                Button("Login") {
                    session.signIn(email: email, password: password)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.automatic)
                Button("SignUp") {
                    session.signUp(email: email, password: password)
                }
                .buttonStyle(.borderedProminent)
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
