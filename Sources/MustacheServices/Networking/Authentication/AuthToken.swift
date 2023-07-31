
import Foundation

public struct AuthToken: Codable {
    
    public var accessToken: String
    
    public var accessTokenExpiration: Date?
    
    public var refreshToken: String?
    
    public var refreshTokenExpiration: Date?
    
    public init(accessToken: String, accessTokenExpiration: Date? = nil, refreshToken: String? = nil, refreshTokenExpiration: Date? = nil) {
        self.accessToken = accessToken
        self.accessTokenExpiration = accessTokenExpiration
        self.refreshToken = refreshToken
        self.refreshTokenExpiration = refreshTokenExpiration
    }
    
}

public extension AuthToken {
    
    var isValid: Bool {
        return !self.accessTokenExpired
    }
    
    var accessTokenExpired: Bool {
        return (self.accessTokenExpiration ?? .distantFuture) < .nowSafe
    }
    
    var refreshTokenExpired: Bool {
        return (self.refreshTokenExpiration ?? .distantFuture) < .nowSafe
    }
    
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
