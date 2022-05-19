//
//  CatalogVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 13.05.22.
//

import Foundation
import UIKit

class CategoryVM : IPerRequest {
    
    typealias Arguments = (Category?, Category?)
    
    private let dataService: DataService<Category>
    
    var category: Category?
    
    var parentCategory: Category?
    
    var errorMessage = Dynamic("")
    
    required init(container: IContainer, args: (Category?, Category?)) {
        dataService = container.resolve(args: Category.self)
        category = args.0
        parentCategory = args.1
        
        bindDataService()
    }
    
    func bindDataService() {
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
    }
    
    func createCategory(name: String, image: UIImage?) {
        category = Category(name: name, parent: parentCategory, image: image)
        if let newCategory = category {
            dataService.createObject(object: newCategory)
        }
    }
    
    func editFinished(name: String, image: UIImage?) {
        if category == nil {
            createCategory(name: name, image: image)
        } else {
                category!.image = image
                dataService.editCategory(category: category!, newName: name)
        }
    }
    
}
