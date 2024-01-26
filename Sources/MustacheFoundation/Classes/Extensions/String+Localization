import Foundation

public extension String {
    
    func defaultsLocalized(_ table: String, bundle: Bundle, defaults: UserDefaults = UserDefaults.standard,_ args: [CVarArg]) -> String {
        if let overwrittenFormat = defaults.string(forKey: self) {
            return String(format: overwrittenFormat, locale: Locale.current, arguments: args)
        } else {
            let format = NSLocalizedString(self, tableName: table, bundle: bundle, comment: "")
            return String(format: format, locale: Locale.current, arguments: args)
        }
    }
}
