
import Foundation
import RxSwift

public extension FileManager {

    func observeCodable<T: Codable>(_ type: T.Type, _ keyPath: String) -> RxObservable<T?> {
        let name = self.notificationName(key: keyPath)        
        return NotificationCenter.default.rx.notification(name).map { [keyPath]_ -> T? in
            return self.decodeObject(forKey: keyPath)
        }
    }

}
