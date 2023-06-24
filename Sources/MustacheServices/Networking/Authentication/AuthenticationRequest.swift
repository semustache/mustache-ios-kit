import MustacheFoundation

struct AuthenticationRequest: Codable {
    
    var clientId: String?
    var clientSecret: String?
    var grantType: GrantType
    var username: String?
    var password: String?
    var refreshToken: String?
    
    internal init(clientId: String? = Environment.clientId,
                  clientSecret: String? = Environment.clientSecret,
                  grantType: GrantType = .password,
                  username: String,
                  password: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.grantType = grantType
        self.username = username
        self.password = password
    }
    
    internal init(clientId: String? = Environment.clientId,
                  clientSecret: String? = Environment.clientSecret,
                  grantType: GrantType = .refreshToken,
                  refreshToken: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.grantType = grantType
        self.refreshToken = refreshToken
    }
    
}

extension AuthenticationRequest {
    
    enum GrantType: String, Codable {
        case password
        case refreshToken = "refresh_token"
    }
}
