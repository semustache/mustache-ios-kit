
import Foundation

public struct AuthToken: Codable {
    
    var accessToken: String
    var accessTokenExpiration: Date?
    var refreshToken: String?
    var refreshTokenExpiration: Date?
    
}

public extension AuthToken {
    
    var isValid: Bool { return !self.accessTokenExpired }
    
    var accessTokenExpired: Bool { return (self.accessTokenExpiration ?? .distantFuture) < .now }
    var refreshTokenExpired: Bool { return (self.refreshTokenExpiration ?? .distantFuture) < .now }
    
}

public extension Optional where Wrapped == AuthToken {
    
    var isValid: Bool {
        switch self {
            case .none:
                return false
            case .some(let token):
                return token.isValid
        }
    }
}
