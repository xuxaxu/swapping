//
//  ProductVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 10.05.22.
//

import Foundation
import UIKit
import CoreMedia

final class ProductListVM: IPerRequest, ObjectUpdatesSubscriber {
    
    private var dataService: DataService<Product>
    
    var products:[Product] = []
    
    var productsChanged = Dynamic(false)
    
    var productChanged = Dynamic(0)
    
    var errorMessage = Dynamic("")
    
    var id: RefreshPublisher.updatedUrl? {
        didSet {
            for product in products {
                if product.id == id?.id {
                    product.imgUrl = id!.url
                    dataService.loadImage(owner: product)
                }
            }
        }
    }
    
    var filteredProducts: [Product] = [] {
        didSet {
            self.productsChanged.value = true
        }
    }
    
    var filterString: String = "" {
        didSet {
            if filterString == "" {
                filteredProducts = products
            } else {
                filteredProducts = products.filter({ product in
                    var suitable = false
                    if let name = product.name {
                        suitable = name.contains(filterString)
                    }
                    if let category = product.category {
                        if let str = filterCategory.filteredStr[category] {
                            suitable = suitable || str.contains(filterString)
                        } else {
                            filterCategory.getCategory(id: category)
                        }
                    }
                    return suitable
                })
            }
        }
    }
    
    private var dataServiceCategory: DataService<Category>
    
    private var filterCategory: CategoryFilter
    
    required init(container: IContainer, args: ()) {
        dataService = container.resolve(args: Product.self)
        dataServiceCategory = container.resolve(args: Category.self)
        filterCategory = container.resolve(args: ())
        
        bindDataService()
    }
    
    func bindDataService() {
        dataService.arrayOfObjects.bind { [weak self] data in
                self?.products = data
                self?.filterString = self!.filterString
        }
        
        dataService.image.bind({ [weak self] object in
            
                if let inx = self?.filteredProducts.firstIndex(of: object) {
                    self?.productChanged.value = inx
                }
        })
        
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
    }
    
    func loadData() {
        dataService.getProducts()
    }
    
    func dataCount()->Int {
        return filteredProducts.count
    }
    
    func dataForIndex(inx: Int)-> Product? {
        if inx < filteredProducts.count {
            return filteredProducts[inx]
        } else {
            return nil
        }
    }
    
    func delete(inx: Int, complition: @escaping (String)->Void) {
        if inx < filteredProducts.count {
            dataService.deleteObject(object: filteredProducts[inx]) { massage in
               complition(massage)
            }
        }
    }
    
    
}
