import Foundation

public protocol CoordinatorDelegate: CoordinatorType {
    
    var childCoordinators: [CoordinatorType] { get set }
    
    func completed(child: CoordinatorType?)
}

public extension CoordinatorDelegate {
    func completed(child: CoordinatorType?) {
        self.childCoordinators.removeAll(where: { $0 === child })
    }
}
