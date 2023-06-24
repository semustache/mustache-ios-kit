
import Foundation
import UIKit

protocol ModalPushPopTransion { }

class ModalPushPopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var animated: Bool
    var isPresenting: Bool
    
    init(animated: Bool, isPresenting: Bool) {
        self.animated = animated
        self.isPresenting = isPresenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animated ? 0.5 : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        var temporaryTransitionContext: UIViewControllerContextTransitioning? = transitionContext
        let containerView = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else { transitionContext.completeTransition(true); return }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        if self.isPresenting {
            
            toViewController.view.frame = CGRect(origin: CGPoint(x: 0, y: fromViewController.view.frame.height), size: fromViewController.view.frame.size)
            containerView.addSubview(toViewController.view)
            
            UIView.animate(duration: duration,
                           delay: 0.0,
                           animationOption: .easeOutQuart,
                           animations: {
                toViewController.view.frame = fromViewController.view.frame
            }, completion: {
                temporaryTransitionContext?.completeTransition(true)
                temporaryTransitionContext = nil
            })
            
        } else {
            
            containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
            
            UIView.animate(duration: duration,
                           delay: 0.0,
                           animationOption: .easeOutQuart,
                           animations: {
                fromViewController.view.frame = CGRect(origin: CGPoint(x: 0, y: fromViewController.view.frame.height), size: fromViewController.view.frame.size)
            }, completion: {
                temporaryTransitionContext?.completeTransition(true)
                temporaryTransitionContext = nil
            })
            
            
            
        }
    }
    
}
