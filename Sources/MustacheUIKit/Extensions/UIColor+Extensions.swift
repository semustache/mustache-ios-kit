
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

    convenience init(hex: String) {
        var hex = hex
        var alpha: CGFloat = 100

        if !(hex.count == 7 || hex.count == 9) {
            // A hex must be either 7 or 9 characters (#RRGGBBAA)
            print("improper call to 'colorFromHex', hex length must be 7 or 9 chars (#GGRRBBAA)")
            self.init(white: 0, alpha: 1)
            return
        }

        if hex.count == 9 {
            // Note: this uses String subscripts as given below
            alpha = hex[7...8].cgfloat
            hex = hex[0...6]
        }

        // Establishing the rgb color
        var rgb: UInt32 = 0
        let scanner: Scanner = Scanner(string: hex)

        // Setting the scan location to ignore the leading `#`
        scanner.scanLocation = 1
        // Scanning the int into the rgb colors
        scanner.scanHexInt32(&rgb)

        // Creating the UIColor from hex int
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        alpha = CGFloat(alpha / 100)

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
