import Foundation

public struct Environment {

    public static var config: Configuration {
        guard let info = infoForKey("ENVIRONMENT_CONFIGURATION") else {
            fatalError("ENVIRONMENT_CONFIGURATION not present in plist")
        }
        guard let config = Configuration(rawValue: info) else {
            fatalError("illegal value for ENVIRONMENT_CONFIGURATION \(info)")
        }
        return config
    }
    
    public static var clientId: String? {
        let info = infoForKey("ENVIRONMENT_CLIENT_ID")
        return info
    }
    
    public static var clientSecret: String? {
        let info = infoForKey("ENVIRONMENT_CLIENT_SECRET")
        return info
    }
    
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

}

public enum Configuration: String {
    case development, staging, production
}

public func infoForKey(_ key: String) -> String? {
    return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
}

public func pListValue<T>(_ key: String, name: String) -> T? {
    guard let plistPath = Bundle.main.path(forResource: name, ofType: "plist") else { return nil }
    guard let plistData = FileManager.default.contents(atPath: plistPath) else { return nil }
    var format = PropertyListSerialization.PropertyListFormat.xml
    guard let plistDict = try? PropertyListSerialization.propertyList(from: plistData,
                                                                      options: .mutableContainersAndLeaves,
                                                                      format: &format) as? [String: AnyObject] else { return nil }
    let myValue = plistDict[key] as? T
    return myValue
}
