
import Foundation
import UIKit

extension UIViewController {
    
    func configureKeyboardHandling() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWillHide(notification: notification)
        }
    }
    
    func tearDownKeyboardHandling() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: Notification) {
        guard
            let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration: Double = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else { return }
        
        guard
            let scrollView = self.view.subViews(type: UIScrollView.self).first,
            let containerView = scrollView.subviews.first
        else { return }
        
        var difference: CGFloat = .leastNonzeroMagnitude
        let containerViewMaxY = containerView.frame.maxY
        let keyboardHeight = keyboardSize.height
        let remainderHeight = self.view.bounds.height - keyboardHeight
        if remainderHeight > containerViewMaxY {
            difference = containerViewMaxY - remainderHeight
        }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [],
                       animations: { scrollView.contentOffset = CGPoint(x: 0, y: difference) })
    }
    
    func keyboardWillHide(notification: Notification) {
        
        guard let duration: Double = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        
        guard let scrollView = self.view.subViews(type: UIScrollView.self).first
        else { return }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [],
                       animations: { scrollView.contentOffset = .zero })
    }
    
}
