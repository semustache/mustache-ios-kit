//
// Created by Tommy Hinrichsen on 2019-05-06.
//

import Foundation
import RxSwift
import RxCocoa

public extension UserDefaults {

    func observeCodable<T: Codable>(_ type: T.Type, _ keyPath: String) -> Observable<T?> {

        let string = "\(UserDefaults.didChangeNotification.rawValue)-\(keyPath)"
        let name = NSNotification.Name(rawValue: string)

        return NotificationCenter.default.rx.notification(name).map { [keyPath]_ -> T? in
            guard let data = self.value(forKey: keyPath) as? Data else { return nil }
            let decoder = JSONDecoder()
            let loaded = try? decoder.decode([T].self, from: data).first
            return loaded
        }
    }

}
