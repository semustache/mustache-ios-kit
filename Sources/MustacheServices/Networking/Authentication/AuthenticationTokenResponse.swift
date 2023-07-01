
import Foundation

struct AuthenticationTokenResponse: Codable {
    
    var accessToken: String
    
    var refreshToken: String?
    
    var accessTokenExpiry: Double?
    
    var refreshTokenExpiry: Double?
    
}
