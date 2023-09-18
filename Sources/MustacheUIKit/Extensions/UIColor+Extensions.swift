
import Foundation
import UIKit
import MustacheFoundation

public extension UIColor {

  var colorAsUInt32: UInt {
       var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
       self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

       var colorAsUInt32: UInt32 = 0
       colorAsUInt32 += UInt32(red * 255.0) << 16
       colorAsUInt32 += UInt32(green * 255.0) << 8
       colorAsUInt32 += UInt32(blue * 255.0)

       let colorAsUInt = UInt(colorAsUInt32)
       return colorAsUInt
   }

}
