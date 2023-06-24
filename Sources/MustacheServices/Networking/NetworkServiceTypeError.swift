
import Foundation

public enum NetworkServiceTypeError: Error {
    
    case decodingError(URLResponse?, Data?, Error)
    case invalidResponseType(URLResponse?, Data?)
    case unSuccessful(URLResponse?, Data?, Int, Error?)
    
    case unauthorized(data: Data?)
    
}
