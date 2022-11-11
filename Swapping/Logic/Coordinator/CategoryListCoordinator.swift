//
//  CategoryListCoordinator.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 19.07.22.
//

import Foundation
import UIKit

class CategoryListCoordinator: CoordinatorProtocol, CategoryListCoordinatorProtocol, IPerRequest, AlertProtocol {
    
    internal var container: IContainer!
    
    required init(container: IContainer, args: ()) {
        self.container = container
        navigationController = UINavigationController()
    }
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    weak var parentCoordinator: Coordinator?
    
    var navigationController: UINavigationController
    
    func start() -> UIViewController {
        let categoryVC = CatalogVC.instantiate()
        categoryVC.coordinator = self
        
        categoryVC.model = container.resolve(args: nil)
            
        presentVC(newOne: categoryVC)
        
        let tabBarItem = UITabBarItem(title: "categories", image: UIImage(systemName: "tray.full"), tag: 1)
        tabBarItem.badgeColor = .orange
        navigationController.tabBarItem = tabBarItem
        
        return navigationController
    }
    
    
    func showCategories(in category : Category?, presentingVC : UIViewController) {
        
        let categoryVC = CatalogVC.instantiate()
        categoryVC.coordinator = self
        
        categoryVC.model = container.resolve(args: category)
            
        presentVC(newOne: categoryVC)
    }
    
    func showEditingCategory(category : Category?, parentCategory: Category?, presentingVC: UIViewController) {
        let categoryVC = CategoryViewController.instantiate()
        categoryVC.coordinator = self
        categoryVC.model = container.resolve(args: (category, parentCategory))
        presentVC(newOne: categoryVC)
        
    }
    
}
