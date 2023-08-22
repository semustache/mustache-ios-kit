
import Foundation
import UIKit

extension UIControl {
    
    func add(event: UIControl.Event, action: @escaping (()->())) {
        let identifier = UIAction.Identifier("UIControl.Event.\(event)")
        
        self.removeAction(identifiedBy: identifier, for: event)
        
        let action = UIAction(identifier: identifier, handler: { _ in action() })
        
        self.addAction(action, for: event)
        
    }
    
}
