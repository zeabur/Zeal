import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
    }
    
    // accessGroup should match the one in entitlements (TeamID.Group)
    private let accessGroup = "BB726GNDGJ.com.zeabur.Zeal.SharedKeychain"
    
    func save(key: String, value: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessGroup as String: accessGroup
        ]
        
        // Try to add
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            
            if updateStatus != errSecSuccess {
                throw KeychainError.unknown(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: accessGroup
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unknown(status)
        }
    }
}
