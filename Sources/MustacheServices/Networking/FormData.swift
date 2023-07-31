
import Foundation

public enum FormData {
    case text(key: String, value: String)
    case data(key: String, fileName: String, contentType: String, value: Data)
}
