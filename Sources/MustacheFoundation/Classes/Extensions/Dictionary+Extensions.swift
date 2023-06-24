import Foundation

public extension Dictionary {

    func stringRecursive(key: Key) -> String? {

        if let foundValue = self[key] as? String {
            return foundValue
        } else {
            for value in self.values {
                if let value = value as? [AnyHashable: Any], let result = value.stringRecursive(key: key) {
                    return result
                }
            }
            return nil
        }
    }


    func intRecursive(key: Key) -> Int? {

        if let foundValue = self[key] as? Int {
            return foundValue
        } else {
            for value in self.values {
                if let value = value as? [AnyHashable: Any], let result = value.intRecursive(key: key) {
                    return result
                }
            }
            return nil
        }
    }
}
