//
//  CategoryVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 10.05.22.
//

import Foundation
import CoreMedia

final class CategoryListVM : IPerRequest, ObjectUpdatesSubscriber {
    
    
    typealias Arguments = Category?
    
    
    private var dataService: DataService<Category>
    
    var parentCategory: Category?
    
    var categories: [Category] = []
    
    var allDataChanged = Dynamic(false)
    
    var rowChanged = Dynamic(0)
    
    var errorMessage = Dynamic("")
    
    var id: RefreshPublisher.updatedUrl? {
        didSet {
            for category in categories {
                if category.id == id?.id {
                    category.imgUrl = id!.url
                    dataService.loadImage(owner: category)
                    return
                }
            }
        }
    }
    
    required init(container: IContainer, args: Category?) {
        dataService = container.resolve(args: Category.self)
        parentCategory = args
        bind()
    }
    
    func bind() {
        dataService.arrayOfObjects.bind({ [weak self] arrayOfObjects in
            if let existSelf = self {
                existSelf.categories = arrayOfObjects
                existSelf.allDataChanged.value = true
            }
        })
        
        dataService.image.bind({[weak self] object in
                if let inx = self?.categories.firstIndex(of: object) {
                    self?.rowChanged.value = inx
                }
        })
        
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
        
    }
    
    func getCategories() {
        dataService.getCategories(in: parentCategory)
    }
    
    func categorySelected(inx: Int) {
        
    }
    
    func deleteCategory(inx: Int, complition: @escaping (String)->Void) {
        if inx < categories.count {
            dataService.deleteObject(object: categories[inx], complition: complition)
            
            categories.remove(at: inx)
            allDataChanged.value = true
        }
    }
    
}
