
import Foundation
import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UITableView {

    /// Bindable sink for `reload` property.
    public var reloadData: Binder<Void> {
        return Binder(self.base) { tableView, _ in
            tableView.reloadData()
        }
    }
}
