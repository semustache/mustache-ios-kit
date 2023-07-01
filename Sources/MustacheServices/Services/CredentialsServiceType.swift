import Foundation
import MustacheFoundation

public protocol CredentialsServiceType: AnyObject {
    
    var username: String? { get set }
    
    var password: String? { get set }
    
    var bearer: String? { get set }
    
    var oauthToken: OAuthTokenType? { get set }
    
    var oauthToken2: OAuthTokenType? { get set }
    
    func clearState()
    
}

public class CredentialsService: CredentialsServiceType {
    
    public static var accessibility: KeychainItemAccessibility = .whenUnlocked
    
    @KeychainOptional(CredentialsConstants.username.rawValue, accessibility: CredentialsService.accessibility)
    public var username: String?
    
    @KeychainOptional(CredentialsConstants.password.rawValue, accessibility: CredentialsService.accessibility)
    public var password: String?
    
    @KeychainOptional(CredentialsConstants.bearer.rawValue, accessibility: CredentialsService.accessibility)
    public var bearer: String?
    
    @KeychainOptional(CredentialsConstants.oauth.rawValue, accessibility: CredentialsService.accessibility)
    public var oauthToken: OAuthTokenType?
    
    @KeychainOptional(CredentialsConstants.oauth2.rawValue, accessibility: CredentialsService.accessibility)
    public var oauthToken2: OAuthTokenType?
    
    public init() {}
    
    public func clearState() {
        
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialsConstants.username.rawValue, withAccessibility: accessibility)
        }
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialsConstants.password.rawValue, withAccessibility: accessibility)
        }
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialsConstants.bearer.rawValue, withAccessibility: accessibility)
        }
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialsConstants.oauth.rawValue, withAccessibility: accessibility)
        }
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialsConstants.oauth2.rawValue, withAccessibility: accessibility)
        }
        
    }
    
    public enum CredentialsConstants: String {
        case username, password, bearer, oauth, oauth2
    }
    
}

public struct OAuthTokenType: Codable {
    
    public var accessToken: String
    public var accessTokenExpiration: Date
    public var refreshToken: String?
    public var refreshTokenExpiration: Date?
    
    public init(accessToken: String, accessTokenExpiration: Date, refreshToken: String? = nil, refreshTokenExpiration: Date? = nil) {
        self.accessToken = accessToken
        self.accessTokenExpiration = accessTokenExpiration
        self.refreshToken = refreshToken
        self.refreshTokenExpiration = refreshTokenExpiration
    }
    
}
