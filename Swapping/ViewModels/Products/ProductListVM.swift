//
//  ProductVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 10.05.22.
//

import Foundation
import UIKit

final class ProductListVM: IPerRequest {
    
    private var dataService: DataService<Product>
    
    var products:[Product] = []
    
    var productsChanged = Dynamic(false)
    
    var productChanged = Dynamic(0)
    
    var errorMessage = Dynamic("")
    
    required init(container: IContainer, args: ()) {
        dataService = container.resolve(args: Product.self)
        bindDataService()
    }
    
    func bindDataService() {
        dataService.arrayOfObjects.bind { [weak self] data in
                self?.products = data
                self?.productsChanged.value = true
        }
        
        dataService.image.bind({ [weak self] object in
            
                if let inx = self?.products.firstIndex(of: object) {
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
        return products.count
    }
    
    func dataForIndex(inx: Int)-> Product? {
        if inx < products.count {
            return products[inx]
        } else {
            return nil
        }
    }
    
    func delete(inx: Int, complition: @escaping (String)->Void) {
        if inx < products.count {
            dataService.deleteObject(object: products[inx]) { massage in
               complition(massage)
            }
        }
    }
    
    
}
