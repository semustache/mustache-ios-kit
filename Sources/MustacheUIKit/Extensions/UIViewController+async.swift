
import Foundation
import UIKit

public extension UIViewController {
    
    func dismissAsync(animated: Bool) async {
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
