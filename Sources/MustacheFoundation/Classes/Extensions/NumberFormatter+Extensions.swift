
import Foundation

public extension NumberFormatter {

    static let integers: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .daDK

        formatter.groupingSeparator = "."
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true

        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1

        formatter.roundingMode = .down

        return formatter
    }()

    static let decimals: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .daDK

        formatter.maximumIntegerDigits = 0
        formatter.decimalSeparator = ""

        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let price: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .daDK
        formatter.minimumIntegerDigits = 1

        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter
    }()

    func string(from double: Double) -> String? {
        let number = NSNumber(value: double)
        return self.string(from: number)
    }

}