import Foundation

public extension UserDefaults {

    func decodeObject<T>(forKey key: String) -> T? where T: Decodable {
        guard let saved = self.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        let loaded = try? decoder.decode([T].self, from: saved).first
        return loaded
    }

    func encode<T>(_ value: T?, forKey key: String) where T: Encodable {

        let string = "\(UserDefaults.didChangeNotification.rawValue)-\(key)"
        let name = NSNotification.Name(rawValue: string)

        let encoder = JSONEncoder()
        guard let value = value, let encoded = try? encoder.encode([value]) else {
            self.removeObject(forKey: key)
            NotificationCenter.default.post(name: name, object: nil)
            return
        }
        self.set(encoded, forKey: key)
        NotificationCenter.default.post(name: name, object: nil)
    }

    func hasValue(forKey key: String) -> Bool {
        return nil != object(forKey: key)
    }
}
