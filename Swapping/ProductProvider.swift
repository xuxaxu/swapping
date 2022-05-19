//
//  ProductProvider.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 10.05.22.
//

import Foundation

class ProductProvider: ISingleton, FireDataBaseDelegate {
    
    private var fireDataBase: FireDataBase
    
    required init(container: IContainer, args: ()) {
        fireDataBase = container.resolve(args: args)
    }
    
    var products: [Product] = []
    
    func loadProducts() {
        fireDataBase.getProducts()
    }
    
    func jsonGotten(data: Data, id: String, kind: kindData) {
        <#code#>
    }
}
