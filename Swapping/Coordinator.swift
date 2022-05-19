//
//  Coordinator.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import Foundation
import UIKit

final class Coordinator: IPerRequest {
    
    private var container: IContainer!
    
    required init(container: IContainer, args: ()) {
        self.container = container
        
    }
    
    func start()->UIViewController? {
        let vc = getVC(id: "startVCId")
        return vc
    }
    
    func getVC(id: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        if let vcCoordinator = vc as? CoordinatedVC {
            vcCoordinator.coordinator = self
            return vcCoordinator
        }
        return vc
    }
    
    func presentVC(newOne: UIViewController, oldOne: UIViewController) {
        newOne.modalPresentationStyle = .fullScreen
        
        if let navigationController = oldOne.navigationController {
            navigationController.pushViewController(newOne, animated: true)
        } else {
            
            if let window = oldOne.view.window {
                window.rootViewController = newOne
            } else {
                oldOne.present(newOne, animated: true)
            }
        }
    }
    
    func dismiss(vc : UIViewController) {
        if let nc = vc.navigationController {
            nc.popViewController(animated: true)
        } else {
            vc.dismiss(animated: true)
        }
    }
    
    func showAlert(message: String, in vc: UIViewController) {
            
        let alert = UIAlertController(title: message, message: "error.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
       
        vc.present(alert, animated: true)
    }
    
    func showMainTabBar(in vc: UIViewController) {
        if let tabBar = getVC(id: "tabBarMainId") as? UITabBarController {
            tabBar.modalPresentationStyle = .fullScreen
            guard let naviControllers = tabBar.viewControllers else {return}
            for nc in naviControllers {
                if let naviController = nc as? UINavigationController,
                   naviController.viewControllers.count > 0,
                   let vc = naviController.viewControllers[0] as? CoordinatedVC {
                    vc.coordinator = self
                    if let productVC = vc as? ProductViewController {
                        productVC.model = container.resolve(args: ())
                    } else {
                        if let categoryVC = vc as? CatalogVC {
                            categoryVC.model = container.resolve(args: nil)
                        }
                    }
                }
            }
            presentVC(newOne: tabBar, oldOne: vc)
        }
    }
    
    func showStartVC(in vc: UIViewController) {
        if let startVC = getVC(id: "startVCId") as? StartViewController {
            presentVC(newOne: startVC, oldOne: vc)
        }
    }
    
    func showCategories(in category : Category?, presentingVC : UIViewController) {
        
        if let categoryVC = getVC(id: "categoriesCatalogID") as? CatalogVC {
        
            categoryVC.model = container.resolve(args: category)
            
            presentVC(newOne: categoryVC, oldOne: presentingVC)
        }
    }
    
    func showEditingCategory(category : Category?, parentCategory: Category?, presentingVC: UIViewController) {
        if let categoryVC = getVC(id: "categoryViewController") as? CategoryViewController {
            categoryVC.model = container.resolve(args: (category, parentCategory))
            presentVC(newOne: categoryVC, oldOne: presentingVC)
        }
        
    }
    
    func showProducts(presentingVC: UIViewController) {
        if let vcProduct = getVC(id: "ProductCollectionId") as? ProductViewController {
            vcProduct.model = container.resolve(args: ())
            presentVC(newOne: vcProduct, oldOne: presentingVC)
        }
    }
    
    func showEditingProduct(product : Product?, presentingVC: UIViewController) {
        if let productVC = getVC(id: "EditingProductVCId") as? EditProductViewController {
            productVC.model = container.resolve(args: product)
            presentVC(newOne: productVC, oldOne: presentingVC)
        }
    }
    
    func showProductDialogue(product: Product, in vc: UIViewController) {
        
        if let productVC = getVC(id: "ProductDialogueId") as? ProductChooseViewController {
            productVC.product = product
            presentVC(newOne: productVC, oldOne: vc)
        }
    }
    
}

protocol CoordinatedVC : UIViewController {
    var coordinator: Coordinator? {get set}
}

