
import Foundation

public extension Bool {
    
    static func <(lhs: Bool, rhs: Bool) -> Bool {
        return Int(bool: lhs) < Int(bool: rhs)
    }
    
    static func >(lhs: Bool, rhs: Bool) -> Bool {
        return Int(bool: lhs) > Int(bool: rhs)
    }
}

public extension Int {
    
    init(bool: Bool) {
        self = bool ? 1 : 0
    }
}
