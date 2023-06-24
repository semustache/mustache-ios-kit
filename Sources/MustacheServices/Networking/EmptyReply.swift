
import Foundation

public struct EmptyReply: Decodable {

    public init() {}

}

public struct StringReply: Decodable {

    var string: String

    public init(string: String) {
        self.string = string
    }

}
