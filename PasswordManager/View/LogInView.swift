import SwiftUI
import FirebaseAuth

struct LogInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.horizontal, 20)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                        .padding(.horizontal, 20)
                }
                
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign up")
                        .padding()
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Login")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $navigateToHome) {
                ContentView()
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showingAlert = true
            } else {
                navigateToHome = true
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
