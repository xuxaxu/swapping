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
            setFilterStr()
        }
    }
    
    private var dataServiceCategory: DataService<Category>
    
    //service for work with categories for filtering by them
    private var filterCategory: CategoryFilter
    
    //when change category filter from menu
    var choosenCategory = "" {
        didSet {
            setCategoryFilter()
        }
    }
    
    private var preFilteredProducts : [Product] = [] {
        didSet {
            setFilterStr()
        }
    }
    
    //for filter by categories
    var menuCategories: Dynamic<Dictionary<Category, [String]>> = Dynamic([:])
    
    private var filterCategoryStr: Dictionary<String, String> = [:] {
        didSet {
            setCategoryFilter()
        }
    }
    
    
    required init(container: IContainer, args: ()) {
        dataService = container.resolve(args: Product.self)
        dataServiceCategory = container.resolve(args: Category.self)
        filterCategory = container.resolve(args: ())
        
        bindDataService()
    }
    
    private func bindDataService() {
        dataService.arrayOfObjects.bind { [weak self] data in
            self?.products = data
            self?.setCategoryFilter()
        }
        
        dataService.image.bind({ [weak self] object in
            
                if let inx = self?.filteredProducts.firstIndex(of: object) {
                    self?.productChanged.value = inx
                }
        })
        
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
        
        filterCategory.menuCategories.bind { [weak self] menu in
            self?.menuCategories.value = menu
        }
        
        filterCategory.filterCategoryStr.bind({[weak self] str in
            self?.filterCategoryStr = str
        })
        
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
    
    func getCategoriesForFilter() {
        filterCategory.getAllCategories()
    }
    
    private func setCategoryFilter() {
        if choosenCategory == "" || choosenCategory == "All" {
            preFilteredProducts = products
        } else {
            preFilteredProducts = products.filter({ (filterCategoryStr[choosenCategory] == nil) ? false : filterCategoryStr[choosenCategory]!.contains($0.category ?? "imposible") })
        }
    }
    
    private func setFilterStr() {
        if filterString == "" {
            filteredProducts = preFilteredProducts
        } else {
            filteredProducts = preFilteredProducts.filter({ product in
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
