
import Foundation
import Resolver

@available(iOS 13.0.0, *)
protocol AsyncNetworkServiceType {
    
    func send<T: Decodable>(endpoint: Endpoint) async throws -> T
    
    func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder) async throws -> T
    
    func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder, retries: Int) async throws -> T
    
}

extension AsyncNetworkServiceType {
    
    func send<T: Decodable>(endpoint: Endpoint) async throws -> T {
        return try await self.send(endpoint: endpoint, using: JSONDecoder(), retries: 3)
    }
    
    func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder) async throws -> T {
        return try await self.send(endpoint: endpoint, using: decoder, retries: 3)
    }
    
}

@available(iOS 13.0.0, *)
actor AsyncNetworkService: AsyncNetworkServiceType {
    
    @LazyInjected
    var tokenService: AsyncTokenServiceType
    
    @LazyInjected
    var credentialsService: CredentialsServiceType
    
    func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder, retries: Int) async throws -> T {
        
        if let demoData = endpoint.demoData as? T { return demoData }
        
        var request = endpoint.request()
        
        do {
            
            if endpoint.authentication == .oauth {
                
                do {
                    let token = try await self.tokenService.validToken()
                    request.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
                } catch let error {
                    let userInfo = [String.errorKey: error]
                    DispatchQueue.main.async { NotificationCenter.default.post(name: .logOut, object: nil, userInfo: userInfo) }
                    throw error
                }
                
            } else if endpoint.authentication == .bearer {
                
                do {
                    let token = try await self.tokenService.validToken()
                    request.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
                } catch let error {
                    let userInfo = [String.errorKey: error]
                    DispatchQueue.main.async { NotificationCenter.default.post(name: .logOut, object: nil, userInfo: userInfo) }
                    throw error
                }
                
                guard let token = self.credentialsService.bearer else { throw AuthenticationError.missingToken}
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
            } else if endpoint.authentication == .basic {
                
                guard let username = self.credentialsService.username, let password = self.credentialsService.password else { throw AuthenticationError.missingToken}
                let raw = String(format: "%@:%@", username, password)
                let data = raw.data(using: .utf8)!
                let encoded = data.base64EncodedString()
                request.addValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
                
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let urlResponse = response as? HTTPURLResponse else {
                throw NetworkServiceTypeError.invalidResponseType(response, data)
            }
            
            guard urlResponse.statusCode != 204 else {
                guard let reply = EmptyReply() as? T else {
                    throw NetworkServiceTypeError.invalidResponseType(response, data)
                }
                return reply
            }
            
            guard urlResponse.statusCode < 400 else {
                
                if urlResponse.statusCode == 401 {
                    if retries >= 1 {
                        self.credentialsService.invalidate(type: .oauth)
                        return try await self.send(endpoint: endpoint, using: decoder, retries: retries - 1)
                    } else {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .logOut, object: nil)
                        }
                        throw NetworkServiceTypeError.unauthorized(data: data)
                    }
                } else {
                    throw NetworkServiceTypeError.unSuccessful(urlResponse, data, urlResponse.statusCode, nil)
                }
            }
            
            do {
                let model: T = try decoder.decode(T.self, from: data)
                return model
            } catch let error {
                throw NetworkServiceTypeError.decodingError(urlResponse, data, error)
            }
        } catch let error as NetworkServiceTypeError {
            switch error {
                case .decodingError(_, let data, _), .invalidResponseType(_, let data), .unSuccessful(_, let data, _, _), .unauthorized(let data):
                    guard let data = data else { throw error }
                    guard let response = try? decoder.decode(ErrorResponse.self, from: data) else { throw error }
                    throw response
            }
        } catch {
            throw error
        }
        
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension NSNotification.Name {
    
    public static let logOut = NSNotification.Name("logOut")
    
}

extension String {
    
    public static let errorKey = NSNotification.Name("errorKey")
    
}
