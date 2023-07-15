
import Foundation

public protocol InlineConfigurable {
}

public extension InlineConfigurable {
    func configured(_ configurator: (Self) -> Void) -> Self {
        // Run the provided configurator:
        configurator(self)

        // Return self (which is now configured):
        return self
    }
}

extension NSObject: InlineConfigurable {
}

extension JSONDecoder: InlineConfigurable {
}

extension JSONEncoder: InlineConfigurable {
}
