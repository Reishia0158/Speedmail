import Foundation
import Security

/// Keychain'de güvenli veri saklama yardımcısı
final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    /// Gmail credentials'ı kaydet
    func saveGmailCredentials(_ credentials: GoogleCredentials, for email: String) -> Bool {
        guard let data = try? JSONEncoder().encode(credentials) else {
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: "com.yunuskaynarpinar.Speedmail.gmail",
            kSecValueData as String: data
        ]
        
        // Önce var olanı sil
        SecItemDelete(query as CFDictionary)
        
        // Yeni kaydı ekle
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Gmail credentials'ı yükle
    func loadGmailCredentials(for email: String) -> GoogleCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: "com.yunuskaynarpinar.Speedmail.gmail",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let credentials = try? JSONDecoder().decode(GoogleCredentials.self, from: data)
        else {
            return nil
        }
        
        return credentials
    }
    
    /// Gmail credentials'ı sil
    func deleteGmailCredentials(for email: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: "com.yunuskaynarpinar.Speedmail.gmail"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Tüm kayıtlı email'leri listele
    func listSavedEmails() -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.yunuskaynarpinar.Speedmail.gmail",
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let items = result as? [[String: Any]]
        else {
            return []
        }
        
        return items.compactMap { $0[kSecAttrAccount as String] as? String }
    }
}

