import Foundation
import UIKit

protocol CoordinatorProtocol: AlertProtocol {
    
    var childCoordinators: [CoordinatorProtocol] { get set }
    
    var navigationController: UINavigationController { get set }
    
    func start() -> UIViewController
    
    func presentVC(newOne: UIViewController, inRootOfVC: UIViewController?)
    
    func dismiss(vc : UIViewController)
    
}

protocol MainCoordinatorProtocol: CoordinatorProtocol {
    
    func showMainTabBar()
    
    func showStartVC(in vc: UIViewController)
    
    func showLogOut(in vc: UIViewController)
    
    var categoriesService: CategoriesService { get }
}

protocol CategoryListCoordinatorProtocol: CoordinatorProtocol {
    func showCategories(in category : Category?, presentingVC : UIViewController)
    func showEditingCategory(category : Category?, parentCategory: Category?, presentingVC: UIViewController)
}

protocol ProductListCoordinatorProtocol: CoordinatorProtocol {
    func showEditingProduct(product : Product?, presentingVC: UIViewController)
    func showProductDialogue(product: Product,
                             in vc: UIViewController)
}

protocol MayLogOut: CoordinatorProtocol {
    func showLogOut(in vc: UIViewController)
}
