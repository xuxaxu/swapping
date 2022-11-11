//
//  CatalogVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 13.05.22.
//

import Foundation
import UIKit
import Combine

class CategoryVM : IPerRequest {
    
    typealias Arguments = (Category?, Category?)
    
    private let dataService: DataService<Category>
    
    var category: Category?
    
    var parentCategory: Category?
    
    var errorMessage = Dynamic("")
    
    private var publisher: RefreshPublisher
    
    required init(container: IContainer, args: (Category?, Category?)) {
        dataService = container.resolve(args: Category.self)
        category = args.0
        parentCategory = args.1
        publisher = container.resolve(args: ())
        
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
    
    func editFinished(name: String, image: UIImage?, _ subscriber: ObjectUpdatesSubscriber? = nil) {
        if category == nil {
            createCategory(name: name, image: image)
        } else {
                category!.image = image
        }
        dataService.editCategory(category: category!) {}

        if let subscriber = subscriber {
            publisher.subscribeforUpdates(some: subscriber)
        }
    }
    
}
