//
//  DataService.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import Foundation
import FirebaseAuth

class DataService : NSObject, FireDataBaseDelegate {
    
    static var shared = DataService()
    
    var currentUser : User?
    
    //MARK: - vc for refreshing data
    
    weak var delegateCategories : DataServiceDelegate?
    
    //MARK: - Data for using
    
    var categories : [Category] = []
    
    var parentCategory : Category?
    
    //MARK: - events for updating data
    
    func DataGotten(kind: kindData, data: [Dictionary<String, Any>]) {
        switch kind {
        case .category:
            for dict in data {
                if let name = dict["name"] as? String {
                    
                    let category = Category(name: name, parent: self.parentCategory, image: nil)
                    categories.append(category)
                    
                    if let imageUrl = dict["imageUrl"] as? String {
                        if let url = URL(string: imageUrl) {
                            category.imgUrl = url
                            FireDataBase.shared.downloadImage(url: url, owner: category)
                        }
                    }
                }
            }
            delegateCategories?.refreshData()
            
        case .product:
            delegateCategories?.refreshData()
            
        case .feacher:
            delegateCategories?.refreshData()
            
        case .appUser:
            delegateCategories?.refreshData()
            
        }
    }
    
    func mediaGotten(owner: ObjectWithImage) {
        if let category = owner as? Category {
            if let index = categories.firstIndex(of: category) {
                delegateCategories?.refreshRow(indexPath: IndexPath(row: index, section: 0))
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
    
    func getCategories(in category: Category?) {
        
        parentCategory = category
        
        categories = []
        
        FireDataBase.shared.delegate = self
        FireDataBase.shared.getCategories(in: category)
    }
    
    func createCategory(category: Category) {
        FireDataBase.shared.createCategory(category: category)
        
        if let inx = categories.firstIndex(of: category) {
            delegateCategories?.refreshRow(indexPath: IndexPath(row: inx, section: 0))
        }
    }
    
}

//vc for refreshing data
protocol DataServiceDelegate : UIViewController {
    func refreshData()
    
    func refreshRow(indexPath: IndexPath)
}

//which kind of data we'll be work with
enum kindData {
    case category
    case product
    case feacher
    case appUser
}

//any kind who have image
protocol ObjectWithImage : AnyObject {
    var image : UIImage? {get set}
}
