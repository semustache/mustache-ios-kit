
import Foundation

public enum EncodingType {
    
    case none
    case json
    case urlEncoded
    case multipartFormData
    case data
    
    var contentType: String {
        switch self {
            case .none: return ""
            case .json: return "application/json"
            case .urlEncoded: return "application/x-www-form-urlencoded"
            case .multipartFormData: return "multipart/form-data"
            case .data: return "application/data"
        }
    }
}
