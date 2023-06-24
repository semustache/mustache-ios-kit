import Foundation
import UIKit

public extension Double {

    var int: Int { return Int(self) }

    var cgfloat: CGFloat { return CGFloat(self) }

    var float: Float { return Float(self) }

    var number: NSNumber { return NSNumber(value: self) }

    func format(format: String) -> String {
        return String(format: "%\(format)f", self)
    }
}

public extension Int {

    var odd: Bool { return self % 2 != 0 }

    var even: Bool { return !odd }

    var double: Double { return Double(self) }

    var cgfloat: CGFloat { return CGFloat(self) }

    var float: Float { return Float(self) }

    var uint: UInt { return UInt(self) }

    var number: NSNumber { return NSNumber(value: self) }

    func format(format: String) -> String {
        return String(format: "%\(format)d", self)
    }

    func roundUp(divisor: Int) -> Int {
        let rem = self % divisor
        return rem == 0 ? self : self + divisor - rem
    }

    var string: String { return "\(self)" }
}

public extension UInt {

    var int: Int { return Int(self) }

    var float: Float { return Float(self) }

    var number: NSNumber { return NSNumber(value: self) }

    var string: String { return "\(self)" }
}

extension Int32 {
    
    var int: Int { return Int(self) }
    
}

public extension Float {

    var double: Double { return Double(self) }

    var cgfloat: CGFloat { return CGFloat(self) }

    var uint: UInt { return UInt(self) }

    var number: NSNumber { return NSNumber(value: self) }

    var string: String { return "\(self)" }
}

public extension String {

    var int: Int { return Int(self) ?? 0 }

    var double: Double { return Double(self) ?? 0 }

    var float: Float { return Float(self) ?? 0 }

    var cgfloat: CGFloat { return CGFloat(self.float) }

    var uint: UInt { return UInt(self) ?? 0 }

    var number: NSNumber {
        let double = Double(self) ?? 0
        let number = NSNumber(value: double)
        return number
    }

}

infix operator &=

public func &=(lhs: inout Bool, rhs: Bool) {
    lhs = lhs && rhs
}
