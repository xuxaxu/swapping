import Foundation
import UIKit

final class Coordinator: IPerRequest, MainCoordinatorProtocol, AlertProtocol {
    
    internal var childCoordinators: [CoordinatorProtocol] = []
    
    internal var navigationController: UINavigationController
    
    private var container: IContainer!
    
    public var categoriesService: CategoriesService
    private var productListManager: ProductListManagement
    private var productService: ProductService
    
    required init(container: IContainer, args: ()) {
        self.container = container
        navigationController = UINavigationController()
        self.categoriesService = CategoriesServiceImp(container: container,
                                                      args: ())
        self.productListManager = ProductListManagementImp(
            container: container, categoriesService: categoriesService)
        let dataService = DataService(container: container, args: Product.self)
        self.productService = ProductServiceImp(dataService: dataService)
    }
    
    func start() -> UIViewController {
        let viewController = getStartViewController()
        navigationController.viewControllers = [viewController]
        return navigationController
    }
    
    private func getStartViewController() -> UIViewController {
        let dataService = DataService(container: container, args: UserData.self)
        let authBuilder = AuthBuilder(dataService: dataService, coordinator: self)
        return authBuilder.viewController
    }
    
    private func getVC(id: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        if let vcCoordinator = vc as? CoordinatedVC {
            vcCoordinator.coordinator = self
            return vcCoordinator
        }
        return vc
    }
    
    func showMainTabBar() {
        
        let tabBar = UITabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        
        let categoryCoordinator = CategoryListCoordinator(container: container, args: ())
        categoryCoordinator.parentCoordinator = self
        categoriesService.recieveCategories()
        
        let productCoordinator = ProductListCoordinator(container: container, args: ())
        productCoordinator.parentCoordinator = self
        
        childCoordinators = [productCoordinator, categoryCoordinator]
        
        tabBar.viewControllers = [productCoordinator.start(), categoryCoordinator.start()]
        
        presentVC(newOne: tabBar, inRootOfVC: navigationController)
    }
    
    func showStartVC(in viewController: UIViewController) {
        let startViewController = getStartViewController()
        presentVC(newOne: startViewController, inRootOfVC: viewController)
    }
    
    func showLogOut(in vc: UIViewController) {
        let dataService = DataService(container: container, args: UserData.self)
        let logOutBuilder = LogOutBuilder(dataService: dataService)
        let vcLogOut = logOutBuilder.viewController
        
        presentVC(newOne:  vcLogOut)
    }
    
}

extension CoordinatorProtocol {
    
    func presentVC(newOne: UIViewController, inRootOfVC: UIViewController? = nil) {
        newOne.modalPresentationStyle = .fullScreen
        
        if let window = inRootOfVC?.view.window {
            window.rootViewController = newOne
        } else {
            navigationController.pushViewController(newOne, animated: true)
        }
    }
    
    func dismiss(vc : UIViewController) {
        navigationController.popViewController(animated: true)
    }
    
}
