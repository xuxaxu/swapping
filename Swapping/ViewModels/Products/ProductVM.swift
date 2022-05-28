//
//  ProductVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 26.05.22.
//

import Foundation

class ProductVM: IPerRequest {
    
    typealias Arguments = Product
    
    required init(container: IContainer, args: Product) {
        self.product = args
        
        userService = container.resolve(args: ())
        
        dataService = container.resolve(args: Category.self)
        
        bind()
    }
    
    var product: Product
    
    var userService: UserDataVM
    
    var errorMessage = Dynamic("")
    
    var ownerName = Dynamic("")
    
    var parentCategory = Dynamic("")
    
    var dataService: DataService<Category>
    
    func bind() {
        userService.userName.bind { [weak self] name in
            self?.ownerName.value = name
        }
        
        userService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
        
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
    }
    
    func getNameOfOwner() {
        if let uid = product.owner {
            userService.getUserName(uid: uid)
        }
    }
    
    func getParentCategory() {
        if let category = product.category {
            dataService.getParentsOfCategory(name: category)
        }
    }
}
