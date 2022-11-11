import Foundation
import UIKit

class ProductListCoordinator: ProductListCoordinatorProtocol,
                              IPerRequest,
                              AlertProtocol {
    
    internal var container: IContainer!
    
    required init(container: IContainer, args: ()) {
        self.container = container
        navigationController = UINavigationController()
    }
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    weak var parentCoordinator: Coordinator?
    
    var navigationController: UINavigationController
    
    private var messageService: MessageServiceProtocol?
    
    func start() -> UIViewController {
        let viewController = getProductListViewController()
        presentVC(newOne: viewController)
        let tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        tabBarItem.badgeColor = .orange
        navigationController.tabBarItem = tabBarItem
        return navigationController
    }
    
    typealias Arguments = ()
    
    private func getProductListViewController() -> UIViewController {
        let builder = ProductListBuilder(coordinator: self,
                                         container: container)
        let viewController = builder.viewController
        return viewController
    }
    
    func showEditingProduct(product : Product?, presentingVC: UIViewController) {
        let productVC = EditProductViewController.instantiate()
        productVC.coordinator = self
            productVC.model = container.resolve(args: product)
            presentVC(newOne: productVC)
    }
    
    func showProductDialogue(product: Product,
                             in vc: UIViewController) {
        
        container.appState.setStateSelectedProduct(product)
        guard let userId = container.appState.getStateUserId() else {
            self.showAlert(message: "no id of authorized user in AppState", in: vc)
            return
        }
        var categoriesService: CategoriesService
        if let parentCategoriesService = parentCoordinator?.categoriesService {
            categoriesService = parentCategoriesService
        } else {
            categoriesService = CategoriesServiceImp(container: container, args: ())
        }
        if messageService == nil {
            messageService = MessageService(userId: userId, container: container)
        }
        let checkUserService = CheckUserFromStateService(container: container)
        let productBuilder = ProductBuilder(coordinator: self,
                                            container: container,
                                            categoryService: categoriesService,
                                            checkUserService: checkUserService)
        let productViewController = productBuilder.viewController
        presentVC(newOne: productViewController)
    }
}
