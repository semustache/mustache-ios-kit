
import Foundation

@propertyWrapper
open class FileSystem<Value: Codable> {
    
    private var key: String
    private var defaultValue: Value
    
    public init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    open var wrappedValue: Value {
        get { FileManager.default.decodeObject(forKey: key) ?? self.defaultValue }
        set { FileManager.default.encode(newValue, forKey: key) }
    }
}

@propertyWrapper
open class FileSystemOptional<Value: Codable> {

    private var key: String

    public init(_ key: String) {
        self.key = key
    }

    open var wrappedValue: Value? {
        get { FileManager.default.decodeObject(forKey: key) }
        set { FileManager.default.encode(newValue, forKey: key) }
    }
}
