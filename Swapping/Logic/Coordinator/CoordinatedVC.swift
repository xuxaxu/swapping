import UIKit

protocol CoordinatedVC : UIViewController {
    var coordinator: CoordinatorProtocol? {get set}
}

protocol ProductCoordinatedVC: UIViewController {
    var coordinator: ProductListCoordinatorProtocol? { get set }
}

protocol CategoryCoordinatedVC: UIViewController {
    var coordinator: CategoryListCoordinatorProtocol? { get set }
}
