
import Foundation
import UIKit

extension UIViewController {
    
    func dismiss(animated: Bool) async {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    continuation.resume()
                }
            }
        }
    }
}
