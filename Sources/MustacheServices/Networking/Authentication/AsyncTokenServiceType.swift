
import Foundation
import MustacheFoundation
import Resolver

protocol AsyncTokenServiceType: Actor {
    
    func validToken() async throws -> AuthToken
    
    func refreshToken() async throws -> AuthToken
    
    func endpoint(refreshToken: String) -> Endpoint
    
    func token(for: Data) -> AuthToken
}

actor AsyncTokenService: AsyncTokenServiceType {
    
    @Injected
    var credentialsService: CredentialsServiceType
    
    var refreshTask: Task<AuthToken, Error>?
    
    func validToken() async throws -> AuthToken {
        
        if let handle = self.refreshTask {
            return try await handle.value
        }
        
        guard let token: AuthToken = await self.credentialsService.getCredential(type: .oauth) else {
            throw AuthenticationError.missingToken
        }
        
        if token.isValid {
            return token
        } else {
            return try await self.refreshToken()
        }
        
    }
    
    func refreshToken() async throws -> AuthToken {
        
        if let refreshTask = self.refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task { () throws -> AuthToken in
            defer { self.refreshTask = nil }
            
            guard let oldToken: AuthToken = await self.credentialsService.getCredential(type: .oauth),
                  let refreshToken = oldToken.refreshToken else {
                throw AuthenticationError.missingRefreshToken
            }
            
            let endpoint = self.endpoint(refreshToken: refreshToken)
            let request = endpoint.request()
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                await self.credentialsService.setCredential(type: .oauth, value: nil)
                throw AuthenticationError.refreshTokenExpired
            }
            
            let token = self.token(for: data)
            
            await self.credentialsService.setCredential(type: .oauth, value: token)
            return token
            
        }
        
        self.refreshTask = task
        
        return try await task.value
        
    }
    
    func endpoint(refreshToken: String) -> Endpoint {
        //        let requestObject = AuthenticationRequest(grantType: .refreshToken, refreshToken: refreshToken)
        //        let endpoint = AuthenticationEndpoint.token(requestObject)
        fatalError("Must be overriden")
    }
    
    func token(for: Data) -> AuthToken {
        //        let authResponse = try JSONDecoder().decode(AuthenticationTokenResponse.self, from: data)
        //        let token = OAuthTokenType(response: authResponse)
        fatalError("Must be overriden")
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
