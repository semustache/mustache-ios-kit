
import Foundation
import MustacheFoundation
import Combine
import Resolver

private var singletonMemoryContainer: [String: Any] = [:]
private var sharedMemoryKeyContainer = NSHashTable<AnyObject>.weakObjects()
private var sharedMemoryValueContainer = NSMapTable<NSString, AnyObject>.weakToWeakObjects()

@available(iOS 13.0, *)
@propertyWrapper
public class StorageCombine<T: Codable>: NSObject {
    
    public var wrappedValue: T? {
        get {
            switch self.mode {
                case .userDefaults(let defaults):
                    return self.getUserDefaults(defaults: defaults)
                case .keychain(let accessibility):
                    return self.getKeychain(accessibility: accessibility)
                case .memory(let scope):
                    return self.getMemory(scope: scope)
            }

        }
        set {
            switch self.mode {
                case .userDefaults(let defaults):
                    self.setUserDefaults(defaults: defaults, value: newValue)
                case .keychain(let accessibility):
                    self.setKeychain(accessibility: accessibility, value: newValue)
                case .memory(let scope):
                    self.setMemory(scope: scope, value: newValue)
            }
        }
    }
    
    // MARK: Configuraation
    
    private let key: String
    private let mode: StorageMode
    private let cacheExpiration: Double?
    
    // MARK: Combine
    
    private var subject: CurrentValueSubject<T?, Never>
    private var localeChangeObserver: NSObjectProtocol!
    
    // MARK: Helpers
    
    private let valueUserInfoKey: String = "\(#file)-\(#function)"
    
    // MARK: propertyWrapper variables
    
    public var projectedValue: AnyPublisher<T?, Never>? {
        return subject.eraseToAnyPublisher()
    }
    
    public init(_ key: String, mode: StorageMode, defaultValue: T? = nil, cacheExpiration: Double? = nil) {
        self.key = key
        self.mode = mode
        self.cacheExpiration = cacheExpiration
        self.subject = CurrentValueSubject(defaultValue)

        super.init()
        
        self.configurePublisher()
        self.configureInitialValue(defaultValue: defaultValue)
        self.configureInMemory()
    }
    
    func configurePublisher() {
        
        let object: Any? = switch mode {
            case .memory(let scope) where scope == .unique:
                self
            default:
                nil
        }
        
        self.localeChangeObserver = NotificationCenter.default.addObserver(forName: notificationName(key: key),
                                                                           object: object,
                                                                           queue: .main) { [unowned self] notification in
            
            // Sets the value and sends an event downstream
            let value = notification.userInfo?[self.valueUserInfoKey] as? T
            self.subject.value = value
            
        }
    }
    
    func configureInitialValue(defaultValue: T?) {
        if let defaultValue, self.wrappedValue == nil {
            // Sets the initial default value and sends an event downstream if no other value is previuosly stored
            self.wrappedValue = defaultValue
        } else if let wrappedValue = self.wrappedValue {
            // Sends an event if the initial value is present
            self.wrappedValue = wrappedValue
        } else {
            // Sends an event with an empty value
            self.wrappedValue = nil
        }
    }
    
    func configureInMemory() {
        guard case .memory(let scope) = self.mode, scope == .shared else { return }
        
        if let sharedKey = sharedMemoryKeyContainer.allObjects
            .compactMap({ $0 as? NSString })
            .first(where: { $0.isEqual(to: self.key) }){
            self.sharedMemoryKey = sharedKey
        } else {
            self.sharedMemoryKey = NSString(string: self.key)
            sharedMemoryKeyContainer.add(self.sharedMemoryKey)
        }
    }
    
    // MARK: StorageMode.userDefaults
    
    // MARK: StorageMode.keychain
    
    // MARK: StorageMode.memory
    
    private var uniqueMemoryStorage: CacheContainer<T>? = nil
    private var sharedMemoryKey: NSString? = nil
    
    // MARK: Lifecycle deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self.localeChangeObserver as Any)
    }
    
}

// MARK: StorageMode.userDefaults
@available(iOS 13.0, *)
extension StorageCombine {
    
    func getUserDefaults(defaults: UserDefaults) -> T? {
        
        guard let data = defaults.data(forKey: self.key) else { return nil }
        guard let cache = try? JSONDecoder().decode(CacheContainer<T>.self, from: data) else { return nil }
        
        /// Object has expired, so we remove it from the cache
        if let expiration = self.cacheExpiration, Date().timeIntervalSince(cache.createdAt) > expiration {
            
            defaults.removeObject(forKey: self.key)
            
            NotificationCenter.default.post(name: notificationName(key: self.key), object: nil)
            
            return nil
        } else {
            return cache.value
        }
        
    }
    
    func setUserDefaults(defaults: UserDefaults, value: T?) {
        if let value = value {
            let cache = CacheContainer(value: value, createdAt: Date())
            if let encoded: Data = try? JSONEncoder().encode(cache) {
                /// Store object
                defaults.set(encoded, forKey: self.key)
            }
        } else {
            defaults.removeObject(forKey: self.key)
        }
        
        // Sends notification so that subscribers of CurrentValueSubject gets the newest object
        NotificationCenter.default.post(name: notificationName(key: self.key),
                                        object: nil,
                                        userInfo: [self.valueUserInfoKey: value as Any])
    }
    
}

// MARK: StorageMode.keychain
@available(iOS 13.0, *)
extension StorageCombine {
    
    func getKeychain(accessibility: KeychainItemAccessibility) -> T? {
        
        guard let data = KeychainWrapper.standard.data(forKey: self.key, withAccessibility: accessibility) else { return nil }
        guard let cache = try? JSONDecoder().decode(CacheContainer<T>.self, from: data) else { return nil }
        
        /// Object has expired, so we remove it from the cache
        if let expiration = self.cacheExpiration, Date().timeIntervalSince(cache.createdAt) > expiration {
            
            KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: accessibility)
            
            NotificationCenter.default.post(name: notificationName(key: self.key), object: nil)
            
            return nil
        } else {
            return cache.value
        }
    }
    
    func setKeychain(accessibility: KeychainItemAccessibility, value: T?) {
        
        if let value = value {
            let cache = CacheContainer(value: value, createdAt: Date())
            if let encoded: Data = try? JSONEncoder().encode(cache) {
                
                /// Store object
                KeychainWrapper.standard.set(encoded, forKey: self.key)
                
            }
        } else {
            KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: accessibility)
        }
        
        // Sends notification so that subscribers of CurrentValueSubject gets the newest object
        NotificationCenter.default.post(name: notificationName(key: self.key),
                                        object: nil,
                                        userInfo: [self.valueUserInfoKey: value as Any])
    }
    
}

// MARK: StorageMode.memory
@available(iOS 13.0, *)
extension StorageCombine {
    
    func getMemory(scope: MemoryScope) -> T? {
        switch scope {
            case .singleton:
            
                let key = String(describing: T.self)
                guard let cache = singletonMemoryContainer[key] as? CacheContainer<T> else { return nil }
                
                /// Object has expired, so we remove it from the cache
                if let expiration = self.cacheExpiration, Date().timeIntervalSince(cache.createdAt) > expiration {
                    
                    NotificationCenter.default.post(name: notificationName(key: self.key), object: nil)
                    singletonMemoryContainer[key] = nil
                    
                    return nil
                } else {
                    return cache.value
                }
                
            case .unique:
                
                guard let cache = self.uniqueMemoryStorage else { return nil }
                
                /// Object has expired, so we remove it from the cache
                if let expiration = self.cacheExpiration, Date().timeIntervalSince(cache.createdAt) > expiration {
                    
                    NotificationCenter.default.post(name: notificationName(key: self.key), object: self)
                    
                    return nil
                    
                } else {
                    return cache.value
                }
                
            case .shared:

                guard let cache = sharedMemoryValueContainer.object(forKey: self.sharedMemoryKey) as? CacheContainer<T> else { return nil }
                
                /// Object has expired, so we remove it from the cache
                if let expiration = self.cacheExpiration, Date().timeIntervalSince(cache.createdAt) > expiration {
                    
                    NotificationCenter.default.post(name: notificationName(key: self.key), object: nil)
                    sharedMemoryValueContainer.removeObject(forKey: self.sharedMemoryKey)
                    
                    return nil
                } else {
                    return cache.value
                }
        }
    }
    
    func setMemory(scope: MemoryScope, value: T?) {
        switch scope {
            case .singleton:
                
                let key = String(describing: T.self)
                singletonMemoryContainer[key] = value
                
                // Sends notification so that subscribers of CurrentValueSubject gets the newest object
                NotificationCenter.default.post(name: notificationName(key: self.key),
                                                object: nil,
                                                userInfo: [self.valueUserInfoKey: value as Any])
                
            case .unique:
                
                if let value = value {
                    let cache = CacheContainer(value: value, createdAt: Date())
                    self.uniqueMemoryStorage = cache
                } else {
                    self.uniqueMemoryStorage = nil
                }
                
                // Sends notification so that subscribers of CurrentValueSubject gets the newest object
                NotificationCenter.default.post(name: notificationName(key: self.key),
                                                object: self,
                                                userInfo: [self.valueUserInfoKey: value as Any])
                
            case .shared:
                
                if let value = value {
                    let cache = CacheContainer(value: value, createdAt: Date())
                    sharedMemoryValueContainer.setObject(cache, forKey: self.sharedMemoryKey)
                } else {
                    sharedMemoryValueContainer.removeObject(forKey: self.sharedMemoryKey)
                }
                
                // Sends notification so that subscribers of CurrentValueSubject gets the newest object
                NotificationCenter.default.post(name: notificationName(key: self.key),
                                                object: self,
                                                userInfo: [self.valueUserInfoKey: value as Any])
                
                
        }
    }
    
}

/// Defines the storage mode to be used
public enum StorageMode {
    
    /// Uses UserDefaults, default if not specified.
    case userDefaults(defaults: UserDefaults = .standard)
    
    /// Uses Keychain.
    case keychain(accessibility: KeychainItemAccessibility = .afterFirstUnlock)
    
    /// Uses Memory.
    case memory(scope: MemoryScope = .unique)
        
}

/// Defines the life cycle of the memory storage.
public enum MemoryScope {
    
    /// Shared acros the apps lifetime, never deallocated unless app is killed.
    case singleton
    
    /// Each instance is unique, default if not specified.
    case unique
    
    /// Shared acros the app, dealocated when no longer used.
    case shared
}

/// Container used to handle expiration of cached objects
private class CacheContainer<T: Codable>: Codable {
    
    var value: T
    var createdAt: Date
    
    init(value: T, createdAt: Date) {
        self.value = value
        self.createdAt = createdAt
    }
    
    static func < (lhs: CacheContainer, rhs: CacheContainer) -> Bool {
        return lhs.createdAt < rhs.createdAt
    }
}

public extension Double {
    
    static var minute: Double { 60 }
    
    static var hour: Double { .minute * 60 }
    
    static var day: Double { .hour * 24 }
    
    static var week: Double { .day * 7 }
    
}
