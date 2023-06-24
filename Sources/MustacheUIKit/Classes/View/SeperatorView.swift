
import Foundation
import UIKit

class SeperatorView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        let lineHeight = 1.0 / UIScreen.main.scale
        intrinsicContentSize.height = lineHeight
        return intrinsicContentSize
    }
    
    func configure() {
        self.backgroundColor = UIColor.separator
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }
    
}
