//
//  DataService.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import Foundation
import FirebaseAuth
import FirebaseAuthUI

class DataService : NSObject, FireDataBaseDelegate, FUIAuthDelegate {
    
    static var shared = DataService()
    
    //MARK: - vc for refreshing data
    
    weak var delegate : DataServiceDelegate?
    
    //MARK: - Data for using
    
    var categories : [Category] = []
    
    var parentCategory : Category?
    
    var topLevelCategories : [String] = []
    
    var allCategories : Dictionary<String, [String]> = [:]
    
    var products : [Product] = []
    
    //MARK: - authenication
    var currentUser : User?
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let _ = error {
            
        } else {
            currentUser = authDataResult?.user
        }
    }
    
    //MARK: - events for updating data
    
    func DataGotten(kind: kindData, data: [Dictionary<String, Any>]) {
        switch kind {
        case .category:
            for dict in data {
                if let name = dict["name"] as? String {
                    
                    let category = Category(name: name, parent: self.parentCategory, image: nil)
                    categories.append(category)
                    
                    if let imageUrl = dict["image_url"] as? String {
                        if let url = URL(string: imageUrl) {
                            category.imgUrl = url
                            FireDataBase.shared.downloadImage(url: url, owner: category)
                        }
                    }
                }
            }
            delegate?.refreshData()
        case .topLevelCategory:
            
            delegate?.refreshData()
            
        case .product:
            
            delegate?.refreshData()
            
        case .feature:
            delegate?.refreshData()
            
        case .appUser:
            delegate?.refreshData()
            
        }
    }
    
    func jsonGotten(data: Data, id: String) {
        if let product = try? JSONDecoder().decode(Product.self, from: data) {
            product.id = id
            products.append(product)
            
            if let imageUrl = product.imgUrl {
                FireDataBase.shared.downloadImage(url: imageUrl, owner: product)
            }
        }
        
        delegate?.refreshData()
    }
    
    func mediaGotten(owner: ObjectWithImage) {
        if let category = owner as? Category {
            if let index = categories.firstIndex(of: category) {
                delegate?.refreshRow(indexPath: IndexPath(row: index, section: 0))
            }
        } else {
            if let product = owner as? Product {
                if let index = products.firstIndex(of: product) {
                    delegate?.refreshRow(indexPath: IndexPath(item: index, section: 0))
                }
            }
        }
    }
    
    func compressInt(image : UIImage) -> CGFloat {
        
        let size = image.size.width * image.size.height
        if size > 1024 * 1024 {
            return 1024 * 1024 / size
        } else {
            return 1
        }
    }
    
    //MARK: - work with Category
    //get only child categories of argument from FireDB
    func getCategories(in category: Category?) {
        
        parentCategory = category
        
        categories = []
        
        FireDataBase.shared.delegate = self
        FireDataBase.shared.getCategories(in: category)
    }
    
    //create new category in FireDB
    func createCategory(category: Category) {
        FireDataBase.shared.createCategory(category: category)
        
        if let inx = categories.firstIndex(of: category) {
            delegate?.refreshRow(indexPath: IndexPath(row: inx, section: 1))
        }
    }
    
    func correctCategoryName(name : String?) -> Bool {
         
        guard let name = name, name != "" else {return false}
        
            for (key, value) in allCategories {
                if value.contains(name) || (value.count == 0 && key == name) {
                    return true
                }
            }        
        return false
    }
    
    //MARK: - work with products
    func getProducts() {
        products = []
        FireDataBase.shared.getProducts()
    }
    
}

//vc for refreshing data
protocol DataServiceDelegate : UIViewController {
    func refreshData()
    
    func refreshRow(indexPath: IndexPath)
}
