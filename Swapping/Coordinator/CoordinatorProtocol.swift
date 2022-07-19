//
//  CoordinatorProtocol.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 19.07.22.
//

import Foundation
import UIKit

protocol CoordinatorProtocol: AlertProtocol {
    
    var childCoordinators: [CoordinatorProtocol] { get set }
    
    var navigationController: UINavigationController { get set }
    
    func start() -> UIViewController
    
    func presentVC(newOne: UIViewController, oldOne: UIViewController, inRoot: Bool)
    
    func dismiss(vc : UIViewController)
    
    //убрать когда заменим таб бар на swiftUI
    func showMainTabBar(in vc: UIViewController)
    
    func showLogOut(in vc: UIViewController)
    
    func showStartVC(in vc: UIViewController)
}

protocol CoordinatedVC : UIViewController {
    var coordinator: CoordinatorProtocol? {get set}
}

protocol CategoryListCoordinatorProtocol: CoordinatorProtocol {
    func showCategories(in category : Category?, presentingVC : UIViewController)
    func showEditingCategory(category : Category?, parentCategory: Category?, presentingVC: UIViewController)
}

protocol ProductListCoordinatorProtocol: CoordinatorProtocol {
    func showProducts(presentingVC: UIViewController)
    func showEditingProduct(product : Product?, presentingVC: UIViewController)
    func showProductDialogue(product: Product, in vc: UIViewController)
}
