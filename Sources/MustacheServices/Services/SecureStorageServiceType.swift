
import Foundation
import MustacheFoundation
import Resolver
import LocalAuthentication

protocol SecureStorageServiceType {
    
    var passcodeSet: Bool { get }
    
    var biometricsEnabled: Bool { get }
    
    var isBiometricsLocked: Bool { get }
    
    var isFaceIdSupported: Bool { get }
    
    var isTouchIdSupported: Bool { get }
    
    var tokenStoredWithPin: Bool { get }
    
    var tokenStoredWithBiometry: Bool { get }
    
    func store(data: Data, with pin: String) throws
    
    func enableBiometrics() async throws
    
    func store(data: Data) throws
    
    func getData(with pin: String) async throws -> Data
    
    func getData() async throws -> Data
    
    func clearToken(from: UIDStorageMode)
    
    func reset()
    
}

class SecureStorageService: SecureStorageServiceType {
    
    var passcodeSet: Bool {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return error?.code != LAError.passcodeNotSet.rawValue
    }
    
    var biometricsEnabled: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    var isBiometricsLocked: Bool {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return error?.code == LAError.biometryLockout.rawValue
    }
    
    var isFaceIdSupported: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && context.biometryType == .faceID
    }
    
    var isTouchIdSupported: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && context.biometryType == .touchID
    }
    
    var localizedReason: String {
        let localizedReason = "biometric_login".localized
        return localizedReason
    }
    
    var tokenStoredWithPin: Bool {
        let context = LAContext()
        context.interactionNotAllowed = true
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: SecureStorageService.service,
            kSecAttrAccount: "\(UIDStorageMode.pin.rawValue)",
            kSecUseAuthenticationContext: context
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecInteractionNotAllowed
    }
    
    var tokenStoredWithBiometry: Bool {
        let context = LAContext()
        context.interactionNotAllowed = true
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: SecureStorageService.service,
            kSecAttrAccount: "\(UIDStorageMode.biometric.rawValue)",
            kSecUseAuthenticationContext: context
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecInteractionNotAllowed // Second option is if biometrics have been locked due to many attempts
    }
    
    var pinAttempts: Int {
        get {
            return KeychainWrapper.standard.integer(forKey: "pinAttempts", withAccessibility: .afterFirstUnlockThisDeviceOnly) ?? 0
        }
        set {
            KeychainWrapper.standard.set(newValue, forKey: "pinAttempts", withAccessibility: .afterFirstUnlockThisDeviceOnly)
        }
    }
    
    @Injected(name: .maxPinAttempt)
    private var maxPinAttempts: Int
    
    init() {
        self.configure()
    }
    
    private func configure() { }
    
    func store(data: Data, with pin: String) throws {
            
        var query = self.queryFor(mode: .pin, accessControl: self.accessControl(flags: [.applicationPassword]), context: self.context(pin: pin))
        
        query[kSecValueData] = data as Any
        
        var result: AnyObject?
        var status = SecItemAdd(query as CFDictionary, &result)
        
        if status == errSecDuplicateItem {
            
            status = SecItemDelete(self.queryFor(mode: .pin) as CFDictionary)
            
            var replaceQuery = self.queryFor(mode: .pin, accessControl: self.accessControl(flags: [.applicationPassword]), context: self.context(pin: pin))
            replaceQuery[kSecValueData] = data as Any
            
            status = SecItemAdd(replaceQuery as CFDictionary, &result)
        }
        
        guard status == errSecSuccess else {
            // po SecCopyErrorMessageString(status, nil)
            throw SecureStorageError.unhandled
            
        }
            
    }
    
    func enableBiometrics() async throws {
        
        let context = LAContext()
        let result = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: self.localizedReason)
        if !result { throw SecureStorageError.biometricsNotEnabled }
        
    }
    
    func store(data: Data) throws {
        
        var query = self.queryFor(mode: .biometric, accessControl: self.accessControl(flags: [.biometryAny]))
        
        query[kSecValueData] = data as Any
        
        var result: AnyObject?
        var status = SecItemAdd(query as CFDictionary, &result)
        
        if status == errSecDuplicateItem {
            let searchQuery = self.queryFor(mode: .biometric)
            status = SecItemDelete(searchQuery as CFDictionary)
            
            status = SecItemAdd(query as CFDictionary, &result)
        }
        
        guard status == errSecSuccess else {
            // po SecCopyErrorMessageString(status, nil)
            throw SecureStorageError.unhandled
        }
            
    }
    
    func getData(with pin: String) throws -> Data  {
        
        var searchQuery = self.queryFor(mode: .pin, context: self.context(pin: pin))
        searchQuery[kSecReturnData] = kCFBooleanTrue as Any
        
        var searchResult: AnyObject?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &searchResult)
        
        if status == errSecSuccess, let data = searchResult as? Data {
            self.pinAttempts = 0
            return data
        } else if status == errSecAuthFailed || status == errSecInteractionNotAllowed {
            var attempts = self.pinAttempts
            attempts += 1
            if attempts >= 10 {
                self.clearToken(from: .pin)
                self.clearToken(from: .biometric)
                self.pinAttempts = 0
                throw SecureStorageError.toManyAttempts
            } else {
                self.pinAttempts = attempts
            }
            throw SecureStorageError.pinNotMatched
        } else {
            // po SecCopyErrorMessageString(status, nil)
            throw SecureStorageError.unhandled
        }
        
    }
    
    func getData() async throws -> Data {
        
        let context = LAContext()
        context.interactionNotAllowed = true
        // https://stackoverflow.com/questions/28108232/secitemcopymatching-for-touch-id-without-passcode-fallback
        // Not allowed
        // context.localizedFallbackTitle = Strings.Localizable.shoppingLocalAuthenticationFallBackMessage
        do {
            let result =  try await context.evaluateAccessControl(self.accessControl(flags: [.biometryAny])!,
                                                                  operation: .useItem, localizedReason: self.localizedReason)
            var query = self.queryFor(mode: .biometric, accessControl: self.accessControl(flags: [.biometryAny]), context: context)
            query[kSecReturnData] = kCFBooleanTrue as Any
            query[kSecMatchLimit] = kSecMatchLimitOne
            query[kSecUseAuthenticationUI] = kSecUseAuthenticationUISkip
            
            var searchResult: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &searchResult)
            
            if status == errSecSuccess, let data = searchResult as? Data {
                return data
            } else {
                // po SecCopyErrorMessageString(status, nil)
                throw SecureStorageError.unhandled
            }
        } catch {
            if let error = error as? LAError {
                switch error.code {
                    case .userCancel:
                        throw SecureStorageError.userCancelled
                    case .biometryLockout:
                        throw SecureStorageError.biometricsLocked
                    case .biometryNotAvailable:
                        throw SecureStorageError.userCancelled
                    default:
                        throw error
                }
                
            } else {
                throw error
            }
        }
        
    }
    
    func clearToken(from mode: UIDStorageMode) {
        let status = SecItemDelete(self.queryFor(mode: mode) as CFDictionary)
    }
    
    fileprivate func context(pin: String) -> LAContext {
        let context = LAContext()
        context.localizedReason = self.localizedReason
        context.interactionNotAllowed = true
        context.setCredential(pin.data(using: .utf8), type: LACredentialType.applicationPassword)
        return context
    }
    
    fileprivate func accessControl(flags: SecAccessControlCreateFlags) -> SecAccessControl? {
        var accessError: Unmanaged<CFError>?
        let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, flags, &accessError)
        return access
    }
    
    fileprivate func queryFor(mode: UIDStorageMode, accessControl: SecAccessControl? = nil, context: LAContext? = nil) -> [CFString: Any] {
        var query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: SecureStorageService.service,
                                kSecAttrAccount: "\(mode.rawValue)"]
        
        if let accessControl = accessControl {
            query[kSecAttrAccessControl] = accessControl
        }
        if let context = context {
            query[kSecUseAuthenticationContext] = context
        }
        return query
    }
    
    func reset() {
        self.clearToken(from: .pin)
        self.clearToken(from: .biometric)
        self.pinAttempts = 0
    }
    
    @objc
    func clearState() {
        
    }
    
    deinit {
        debugPrint("deinit: \(self)")
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension SecureStorageService {
    
    static let service: String = "SecureStorageService.Service"
    
}

extension Resolver.Name {
    
    static let maxPinAttempt = Resolver.Name("\(#file)-\(#function)")
    
}

enum UIDStorageMode: String {
    case pin
    case biometric
}

enum SecureStorageError: Error {
    case uncodable, userCancelled, biometricsNotEnabled, biometricsLocked, unhandled, toManyAttempts, pinNotMatched
}
