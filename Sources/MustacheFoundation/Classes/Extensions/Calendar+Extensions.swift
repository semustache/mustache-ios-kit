
import Foundation

public extension Calendar {

    static var daDK: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .daDK
        calendar.locale = .daDK
        return calendar
    }
    
    func startOfMonth(for date: Date) -> Date {
        let startOfDay = self.startOfDay(for: date)
        guard let startOfMonth = self.date(bySetting: .day, value: 1, of: startOfDay) else { return date }
        return startOfMonth
    }

    func endOfDay(for date: Date) -> Date {
        let start = self.startOfDay(for: date)
        let components = DateComponents(day: 1, second: -1)
        guard let dateAtEnd = self.date(byAdding: components, to: start) else { return date }
        return dateAtEnd
    }
    
    func within(_ date: Date, within component: Calendar.Component, value: UInt) -> Bool {
        let start = Date.nowSafe
        guard let end = self.date(byAdding: component, value: value.int, to: start) else { return false }
        return start...end ~= date
    }

}


