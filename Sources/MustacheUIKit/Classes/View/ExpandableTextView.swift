import UIKit

open class ExpandableTextView: View {

    fileprivate static var nonExpandedMaxLines = 4

    @IBOutlet open var contentView: UIView!
    @IBOutlet open weak var descriptionLabel: UILabel!
    @IBOutlet open weak var expandButton: Button!
    @IBOutlet open weak var expandButtonHeightConstraint: NSLayoutConstraint!

    fileprivate var canExpand: Bool = false {
        didSet { self.expandButtonHeightConstraint.constant = self.canExpand ? 19 : 0 }
    }

    fileprivate var isExpanded: Bool { return self.descriptionLabel.numberOfLines == 0 }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureView()
    }

    open func set(description: String) {
        self.descriptionLabel.text = description
        let lines = self.descriptionLabel.maxLines
        self.canExpand = (lines > 4)
    }

    fileprivate func toggle(expand: Bool) {
        self.descriptionLabel.numberOfLines = expand ? 0 : ExpandableTextView.nonExpandedMaxLines
        self.expandButton.rotate(degrees: expand ? 180 : 0)
        self.expandButton.imageEdgeInsets = UIEdgeInsets(top: expand ? 10 : 0, left: 0, bottom: expand ? 0 : 10, right: 0)
        self.setNeedsLayout()
    }

    fileprivate func configureView() {
        self.contentView = self.configureNibView()
        self.descriptionLabel.numberOfLines = ExpandableTextView.nonExpandedMaxLines
        self.expandButton.didTouchUpInside = { [unowned self] _ in self.toggle(expand: !self.isExpanded) }
    }

}
