import Security
import SwiftUI
import CryptoKit

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private let keychainService = "Com.ChristopherValle.PasswordManager"
    private let keychainAccount = "encryptionKey"
    
    func saveKey(_ key: SymmetricKey) {
        let keyData = key.withUnsafeBytes { Data(Array($0)) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func loadKey() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status != errSecSuccess {
            if let errorString = SecCopyErrorMessageString(status, nil) {
                print("Keychain error: \(errorString)")
            } else {
                print("Keychain error code: \(status)")
            }
            return nil
        }
        
        guard let keyData = dataTypeRef as? Data else {
            print("Keychain data retrieval error.")
            return nil
        }
        
        return SymmetricKey(data: keyData)
    }
}
