
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
    
    convenience init?(systemName symbol: SFSymbol) {
        self.init(systemName: symbol.name)
    }
    
    convenience init?(symbol: SFSymbol) {
        self.init(systemName: symbol.name)
    }
}
