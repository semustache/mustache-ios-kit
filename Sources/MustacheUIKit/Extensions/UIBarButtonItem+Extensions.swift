import UIKit

/// Typealias for UIBarButtonItem closure.
public typealias UIBarButtonItemTargetClosure = () -> Void

class UIBarButtonItemClosureWrapper: NSObject {
    let closure: UIBarButtonItemTargetClosure

    init(_ closure: @escaping UIBarButtonItemTargetClosure) {
        self.closure = closure
    }
}

extension UIBarButtonItem {

    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }

    private var targetClosure: UIBarButtonItemTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIBarButtonItemClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIBarButtonItemClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
    Init closure based UIBarButtonItem

    - returns:
    UIBarButtonItem

    - parameters:
        - title: String
        - style: UIBarButtonItem.Style
        - closure: UIBarButtonItemTargetClosure?

    */
    public convenience init(title: String?, style: UIBarButtonItem.Style, closure: UIBarButtonItemTargetClosure?) {
        self.init(title: title, style: style, target: nil, action: nil)
        self.targetClosure = closure
        self.action = #selector(UIBarButtonItem.closureAction)
    }

    /**
    Init closure based UIBarButtonItem

    - returns:
    UIBarButtonItem

    - parameters:
        - image: UIImage?
        - style: UIBarButtonItem.Style
        - closure: UIBarButtonItemTargetClosure?

    */
    public convenience init(image: UIImage?, style: UIBarButtonItem.Style, closure: UIBarButtonItemTargetClosure?) {
        self.init(image: image, style: style, target: nil, action: nil)
        self.targetClosure = closure
        self.action = #selector(UIBarButtonItem.closureAction)
    }

    @objc func closureAction() {
        guard let targetClosure = self.targetClosure else { return }
        targetClosure()
    }
}
