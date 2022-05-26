//
//  ProductEditVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 11.05.22.
//

import Foundation
import UIKit

class ProductEditVM : IPerRequest {
    
    typealias Arguments = Product?
    
    var topLevelCategories: [Category] = []
    
    var topLevelCategoryNames: Dynamic<[String]> = Dynamic([])
    
    var allCategories: Dynamic<Dictionary<String,[String]>> = Dynamic([:])
    
    var product: Product?
    
    private var dataServiceCategories : DataService<Category>
    
    private var dataService: DataService<Product>
    
    var errorMessage = Dynamic("")
    
    required init(container: IContainer, args: Product?) {
        dataService = container.resolve(args: Product.self)
        dataServiceCategories = container.resolve(args: Category.self)
        product = args
        bindDataService()
    }
    
    func bindDataService() {
        dataServiceCategories.arrayOfObjects.bind({ [weak self] arrayOfObjects in
                    self?.topLevelCategories = arrayOfObjects
                    self?.topLevelCategoryNames.value = arrayOfObjects.map{ $0.name ?? "" }
                    self?.fillChildCategories(inCategoryArray: arrayOfObjects, parentCategoty: nil)
            })
            
            dataServiceCategories.arrayOfChildren.bind { [weak self] (category, childObjects) in
                if let name = category.name {
                    if self?.allCategories.value[name] == nil {
                        self?.allCategories.value[name] = []
                    }
                    self?.allCategories.value[name]?.append(contentsOf: childObjects.map{ $0.name ?? "" })
                    self?.fillChildCategories(inCategoryArray: childObjects, parentCategoty: category)
                }
            }
        
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
    }
    
    func fillTopLevelCategories() {
        allCategories.value = [:]
        dataServiceCategories.getCategories(in: nil)
    }
    
    func fillChildCategories(inCategoryArray categories: [Category], parentCategoty: Category?) {
            for childCategory in categories {
                dataServiceCategories.getChildCategories(inCategory: childCategory, topLevelCategory: parentCategoty ?? childCategory)
            }
    }
    
    func correctCategoryName(name : String?) -> Bool {
         
        guard let name = name, name != "" else {return false}
        
        for (key, value) in allCategories.value {
                if value.contains(name) || (value.count == 0 && key == name) {
                    return true
                }
            }
        return false
    }
    
    func editProduct(name: String, category: String, image: UIImage?, description: String?) {
        if product == nil {
            product = Product(name: name, category: category, image: image, features: nil, description: description)
            if product != nil {
                dataService.createObject(object: product!)
            }
        } else {
            product!.name = name
            product!.category = category
            product!.productDescription = description
            product!.image = image
        }
        dataService.editProduct(product: product!)
    }
    
}
