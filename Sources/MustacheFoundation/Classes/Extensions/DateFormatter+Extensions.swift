
import Foundation

public extension DateFormatter {

    func string(optional date: Date?) -> String? {
        guard let date else { return nil }
        return self.string(for: date)
    }

}
