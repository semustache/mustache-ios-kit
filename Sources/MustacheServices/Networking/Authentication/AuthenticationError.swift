
import Foundation

enum AuthenticationError: Error {
    case missingUsername
    case missingPassword
    case missingBearer
    case missingToken
    case missingRefreshToken
    case unauthorized
    case accessTokenExpired
    case refreshTokenExpired
    case missingInstallationId
}
