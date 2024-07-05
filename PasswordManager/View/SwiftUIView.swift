import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                if let key = KeychainHelper.shared.loadKey() {
                    print("Key loaded from Keychain: \(key)")
                    // Use the key for encryption or decryption
                } else {
                    print("Failed to load key from Keychain")
                }
            }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
