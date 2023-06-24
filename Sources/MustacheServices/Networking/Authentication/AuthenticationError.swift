
import Foundation

enum AuthenticationError: Error {
    case missingToken
    case missingRefreshToken
    case unauthorized
    case accessTokenExpired
    case refreshTokenExpired
    case missingInstallationId
}
