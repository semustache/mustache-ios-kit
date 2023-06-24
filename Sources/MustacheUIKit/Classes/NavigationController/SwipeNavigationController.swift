
import Foundation
import UIKit

final class SwipeNavigationController: UINavigationController {

    // MARK: - Lifecycle

    var _preferredInterfaceOrientationForPresentation: UIInterfaceOrientation = .portrait
    var _supportedInterfaceOrientations: UIInterfaceOrientationMask = [.portrait]
    weak var forwardingDelegate: UINavigationControllerDelegate? = nil

    override var delegate: UINavigationControllerDelegate? {
        set {
            self.forwardingDelegate = newValue
        } get {
            return self.forwardingDelegate
        }
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        super.delegate = self
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        super.delegate = self
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        super.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // This needs to be in here, not in init
        self.interactivePopGestureRecognizer?.delegate = self
    }

    deinit {
        self.delegate = nil
        self.interactivePopGestureRecognizer?.delegate = nil
    }

    // MARK: - Overrides

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - Private Properties

    fileprivate var duringPushAnimation = false

}

// MARK: - UINavigationControllerDelegate

extension SwipeNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.forwardingDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let swipeNavigationController = navigationController as? SwipeNavigationController else { return }
        swipeNavigationController.duringPushAnimation = false
        self.forwardingDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.forwardingDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? self._supportedInterfaceOrientations
    }

    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return self.forwardingDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? self._preferredInterfaceOrientationForPresentation
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.forwardingDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.forwardingDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }

}

// MARK: - UIGestureRecognizerDelegate

extension SwipeNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.interactivePopGestureRecognizer else { return true } // default value

        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed
        return self.viewControllers.count > 1 && self.duringPushAnimation == false
    }
}
