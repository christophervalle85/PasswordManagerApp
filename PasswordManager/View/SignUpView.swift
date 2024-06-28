import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showErrorMessage = false
    @State private var navigateToLogIn = false

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button(action: signUp) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 20)

                if showErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Sign Up")
            .navigationDestination(isPresented: $navigateToLogIn) {
                LogInView()
            }
        }
    }

    func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showErrorMessage = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorMessage = true
            } else {
                navigateToLogIn = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
