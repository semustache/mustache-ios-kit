
import Foundation

public extension NSObject {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
    
    func isNot<T>(_ type: T.Type) -> Bool {
        return !(self is T)
    }
    
}
