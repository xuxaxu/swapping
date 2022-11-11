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
    
    
    private var topLevelCategories: [Category] = [] {
        didSet {
            filteredTopLevelCategories = transformTopLevelCategoriesToNames()
        }
    }
    
    private var allCategories: Dictionary<Category,[Category]> = [:] {
        didSet {
            filteredCategories = transformAllCategoriesToNames()
        }
    }
    
    var filterStr = "" {
        didSet {
            filterCategories()
        }
    }
    
    var filteredCategories : [String : [String]] = [:]
    
    var filteredTopLevelCategories : [String] = []
    
    var product: Product?
    
    var category: Dynamic<Category>?
    
    private var dataServiceCategories : DataService<Category>
    
    private var dataService: DataService<Product>
    
    var errorMessage = Dynamic("")
    
    private var publisher: RefreshPublisher
    
    private let currentUserId: String?
    
    required init(container: IContainer, args: Product?) {
        dataService = container.resolve(args: Product.self)
        dataServiceCategories = container.resolve(args: Category.self)
        publisher = container.resolve(args: ())
        let userId = container.appState.getStateUserId()
        self.currentUserId = userId
        product = args
        bindDataService()
    }
    
    func bindDataService() {
        dataServiceCategories.arrayOfObjects.bind({ [weak self] arrayOfObjects in
                    self?.topLevelCategories = arrayOfObjects
                    self?.fillChildCategories(inCategoryArray: arrayOfObjects, parentCategoty: nil)
            })
            
            dataServiceCategories.arrayOfChildren.bind { [weak self] (category, childObjects) in
                
                    if self?.allCategories[category] == nil {
                        self?.allCategories[category] = []
                    }
                    self?.allCategories[category]?.append(contentsOf: childObjects)
                    self?.fillChildCategories(inCategoryArray: childObjects, parentCategoty: category)
            }
        
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
    }
    
    func getProductCategory() {
        if let categoryId = product?.category {
            dataServiceCategories.getElement(path: "categories/" + categoryId) { [weak self] category in
                self?.category?.value = category
            }
        }
    }
    
    func fillTopLevelCategories() {
        allCategories = [:]
        dataServiceCategories.getCategories(in: nil)
    }
    
    func fillChildCategories(inCategoryArray categories: [Category], parentCategoty: Category?) {
            for childCategory in categories {
                dataServiceCategories.getChildCategories(inCategory: childCategory, topLevelCategory: parentCategoty ?? childCategory)
            }
    }
    
    func correctCategoryName(name : String?) -> Bool {
         
        guard let name = name, name != "" else {return false}
        
        if !allCategories.values.filter({ !$0.filter({ $0.name == name }).isEmpty }).isEmpty {
            return true
        }
        
        if !topLevelCategories.filter({ $0.name == name && (allCategories[$0]?.isEmpty ?? true)}).isEmpty {
            return true
        }
        
        return false
    }
    
    func editProduct(name: String, category: String, image: UIImage?, description: String?) {
        
        //detect category id from name for saving in product
        var categoryObject: Category?
        let arrayOfCategoriesWithName = allCategories.values.filter( {!$0.filter({ $0.name == category }).isEmpty })
        if arrayOfCategoriesWithName.isEmpty {
            categoryObject = topLevelCategories.filter({ $0.name == category }).first
        } else {
            categoryObject = arrayOfCategoriesWithName.first!.filter({ $0.name == category }).first
        }
        
        if product == nil {
            let product = Product()
            product.name = name
            product.category = categoryObject?.id ?? "unknown"
            product.image = image
            product.productDescription = description
            dataService.createObject(object: product)
            product.owner = currentUserId
            self.product = product
        } else {
            product!.name = name
            product!.category = categoryObject?.id ?? "unknown"
            product!.productDescription = description
            product!.image = image
        }
        dataService.editProduct(product: product!, completion: {})
    }
    
    func subscribeForUpdateProduct(subscriber: ObjectUpdatesSubscriber) {
        publisher.subscribeforUpdates(some: subscriber)
    }
    
    func deleteProduct() {
        if let product = product {
            dataService.deleteObject(object: product) { [weak self] message in
            self?.errorMessage.value = message
            }
        }
    }
    
    private func transformTopLevelCategoriesToNames() -> [String] {
        return topLevelCategories.map({ $0.name ?? "unknown" })
    }
    
    private func transformAllCategoriesToNames() -> Dictionary<String, [String]> {
        return Dictionary(uniqueKeysWithValues: allCategories.map({ key, value in
            (key.name ?? "unknown", value.map({ $0.name ?? "unknown" }))
        }))
    }
    
    private func filterCategories() {
        if filterStr != "" {
            filteredCategories = transformAllCategoriesToNames().filter({ (key, value) in
                value.filter{$0.starts(with: filterStr)}.count > 0
            })
            for (key, value) in filteredCategories {
                filteredCategories[key] = value.filter{ $0.starts(with: filterStr) }
            }
            filteredTopLevelCategories = Array(filteredCategories.keys)
        } else {
            refreshFilteredCategories()
        }
    }
    
    func refreshFilteredCategories() {
        filteredTopLevelCategories = transformTopLevelCategoriesToNames()
        filteredCategories = transformAllCategoriesToNames()
    }
    
}
