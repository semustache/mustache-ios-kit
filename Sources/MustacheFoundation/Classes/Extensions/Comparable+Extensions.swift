
import Foundation

public func <<T: Comparable>(left: T?, right: T) -> Bool {
    if let left = left {
        return left < right
    }
    return false
}
