
import UIKit

public extension SFSymbol {
    
    var name: String {
        return self.rawValue
    }
    
    var image: UIImage? {
        return UIImage(systemName: self.rawValue)
    }
}

public extension UIImage {
    
    convenience init?(systemName symbol: SFSymbol, config: UIImage.SymbolConfiguration? = nil) {
        self.init(systemName: symbol.name, withConfiguration: config)
    }
    
    convenience init?(symbol: SFSymbol, config: UIImage.SymbolConfiguration? = nil) {
        self.init(systemName: symbol.name, withConfiguration: config)
    }
}
