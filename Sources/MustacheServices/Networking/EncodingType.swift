
import Foundation

public enum EncodingType {
    
    case none
    case json(JSONEncoder? = nil)
    case urlEncoded
    case multipartFormData
    case data
    case text
    
    var contentType: String {
        switch self {
            case .none: return ""
            case .json: return "application/json"
            case .urlEncoded: return "application/x-www-form-urlencoded"
            case .multipartFormData: return "multipart/form-data"
            case .data: return "application/data"
            case .text: return "text/plain"
        }
    }
}
