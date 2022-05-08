//
//  Coordinator.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import Foundation
import UIKit

final class Coordinator {
    
    static func getVC(id: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id)
    }
    
    static func presentVC(newOne: UIViewController, oldOne: UIViewController) {
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
    
    static func dismiss(vc : UIViewController) {
        if let nc = vc.navigationController {
            nc.popViewController(animated: true)
        } else {
            vc.dismiss(animated: true)
        }
    }
    
    static func showAlert(message: String, in vc: UIViewController) {
            
        let alert = UIAlertController(title: message, message: "error.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
       
        vc.present(alert, animated: true)
    }
    
    static func showMainTabBar(in vc: UIViewController) {
        if let tabBar = getVC(id: "tabBarMainId") as? UITabBarController {
            tabBar.modalPresentationStyle = .fullScreen
            presentVC(newOne: tabBar, oldOne: vc)
        }
    }
    
    static func showStartVC(in vc: UIViewController) {
        if let startVC = getVC(id: "startVCId") as? StartViewController {
            presentVC(newOne: startVC, oldOne: vc)
        }
    }
    
    static func showCategories(in category : Category?, presentingVC : UIViewController) {
        
        if let categoryVC = getVC(id: "categoriesCatalogID") as? CatalogVC {
        
            categoryVC.parentCategory = category
            
            presentVC(newOne: categoryVC, oldOne: presentingVC)
        }
    }
    
    static func showEditingCategory(category : Category?, presentingVC: UIViewController) {
        if let categoryVC = getVC(id: "categoryViewController") as? CategoryViewController {
            categoryVC.category = category
            presentVC(newOne: categoryVC, oldOne: presentingVC)
        }
        
    }
    
    static func showProducts(presentingVC: UIViewController) {
        if let vcProduct = getVC(id: "ProductCollectionId") {
            presentVC(newOne: vcProduct, oldOne: presentingVC)
        }
    }
    
    static func showEditingProduct(product : Product?, presentingVC: UIViewController) {
        if let productVC = getVC(id: "EditingProductVCId") as? EditProductViewController {
            productVC.product = product
            presentVC(newOne: productVC, oldOne: presentingVC)
        }
    }
    
    static func showProductDialogue(product: Product, in vc: UIViewController) {
        
        if let productVC = getVC(id: "ProductDialogueId") as? ProductChooseViewController {
            productVC.product = product
            presentVC(newOne: productVC, oldOne: vc)
        }
    }
    
}
