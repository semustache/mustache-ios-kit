import Foundation

public extension Sequence {

    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }

    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        return sorted { a, b in
            if ascending {
                return a[keyPath: keyPath] < b[keyPath: keyPath]
            } else {
                return a[keyPath: keyPath] > b[keyPath: keyPath]
            }
        }
    }
}
