
import Foundation

public extension FileManager {

    func decodeObject<T>(forKey key: String) -> T? where T: Decodable {
        let url = self.url(forKey: key)
        guard self.fileExists(atPath: url.path),
              let saved = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        let loaded = try? decoder.decode([T].self, from: saved).first
        return loaded
    }
    
    func encode<T>(_ value: T?, forKey key: String) where T: Encodable {
        let name = self.notificationName(key: key)
        
        let url = self.url(forKey: key)
        let encoder = JSONEncoder()
        guard let value, let encoded = try? encoder.encode([value]) else {
            try? self.removeItem(at: url)
            NotificationCenter.default.post(name: name, object: nil)
            return
        }
        try? encoded.write(to: url, options: .atomic)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func hasValue(forKey key: String) -> Bool {
        let url = self.url(forKey: key)
        return self.fileExists(atPath: url.path)
    }
    
    // MARK: - Notification

    private static let didChangeNotification = "MFileManagerDidChangeNotification"
    
    func notificationName(key: String) -> NSNotification.Name {
        let rawValue = "\(FileManager.didChangeNotification)-\(key)"
        let notificationName = NSNotification.Name(rawValue: rawValue)
        return notificationName
    }

    // MARK: - File URL/path
    
    private func url(forKey key: String) -> URL {
        return self.applicationSupportDirectoryURL.appendingPathComponent(key)
    }
    
    private var applicationSupportDirectoryURL: URL {
        return self.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
    
}
