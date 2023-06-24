import Foundation

protocol CoordinatorDelegate: CoordinatorType {
    
    var childCoordinators: [CoordinatorType] { get set }
    
    func completed(child: CoordinatorType?)
}

extension CoordinatorDelegate {
    func completed(child: CoordinatorType?) {
        self.childCoordinators.removeAll(where: { $0 === child })
    }
}
