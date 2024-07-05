import Foundation
import CryptoKit

struct EncryptionHelper {
    
    static func encryptPassword(_ password: String) -> String {
        guard let symmetricKey = KeychainHelper.shared.loadKey() else {
            print("Failed to load encryption key")
            return ""
        }
        let data = Data(password.utf8)
        let encrypted = try! ChaChaPoly.seal(data, using: symmetricKey).combined
        return encrypted.base64EncodedString()
    }
    
    static func decryptPassword(_ encrypted: String) -> String? {
        guard let symmetricKey = KeychainHelper.shared.loadKey() else {
            print("Failed to load encryption key")
            return nil
        }
        let data = Data(base64Encoded: encrypted)!
        
        do {
            let sealedBox = try ChaChaPoly.SealedBox(combined: data)
            let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
    
    static func setupKey() {
        if KeychainHelper.shared.loadKey() == nil {
            let symmetricKey = SymmetricKey(size: .bits256)
            KeychainHelper.shared.saveKey(symmetricKey)
            print("Encryption key generated and saved")
        } else {
            print("Encryption key already exists in Keychain")
        }
    }
}
