
import Foundation
import UIKit

public protocol FadeTransition { }

public class FadeAnimationTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        var temporaryTransitionContext: UIViewControllerContextTransitioning? = transitionContext
        let containerView = transitionContext.containerView
        
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        toViewController.view.frame = fromViewController.view.frame
        toViewController.view.alpha = 0
        containerView.addSubview(toViewController.view)
        
        UIView.animate(duration: duration,
                       delay: 0.0,
                       animationOption: .easeOutQuart,
                       animations: {
            fromViewController.view.alpha = 0
            toViewController.view.alpha = 1
        }, completion: {
            temporaryTransitionContext?.completeTransition(true)
            temporaryTransitionContext = nil
        })
        
    }
    
}
