//
//  CategoryFilter.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 09.06.22.
//

import Foundation

class CategoryFilter: ISingleton {
    
    
    var dataService: DataService<Category>
    
    var filteredStr: Dictionary<String, String> = [:]
    
    private var categories: [Category] = []
    
    required init(container: IContainer, args: ()) {
        dataService = container.resolve(args: Category.self)
    }
    
    func getCategory(id: String) {
        dataService.getElement(path: "categories/" + id, withImage: false) { [weak self, id] category in
            
            category.id = id
            
            if category.parentId == nil || category.parentId == "" {
                if let id = category.id {
                    
                    self?.categoriesRemove(category: category)
                    
                    self?.filteredStr[id] = category.name
                    self?.allParentsAdded(parent_id: id)
                }
            } else {
                self?.categoriesAppend(category: category)
                
                if let _ = self?.filteredStr[category.parentId!] {
                    self?.allParentsAdded(parent_id: category.parentId!)
                } else {
                    self?.getCategory(id: category.parentId!)
                }
            }
        }
    }
    
    private func allParentsAdded(parent_id: String) {
        var selectedCategories = categories.filter{ $0.parentId == parent_id }
        
        while !selectedCategories.isEmpty {
            
            let category = selectedCategories[selectedCategories.count-1]
            
                if let id = category.id, filteredStr[id] == nil, let name = category.name {
                    filteredStr[id] = name + " " + (filteredStr[parent_id] ?? "")
                }
            if let indexCategory = categories.firstIndex(of: category) {
                categories.remove(at: indexCategory)
            }
            
            selectedCategories = categories.filter{ $0.parentId == parent_id }
        }
    }
    
    private func categoriesContains(category: Category) -> Bool {
        if let id = category.id {
            return !categories.filter{ $0.id == id }.isEmpty
        } else {
            return false
        }
    }
    
    private func categoriesAppend(category: Category) {
        if !categoriesContains(category: category) {
            categories.append(category)
        }
    }
    
    private func categoriesRemove(category: Category) {
        if let id = category.id {
            let filteredCategories = categories.filter{ $0.id == id }
            
                for equalCategory in filteredCategories {
                    if let index = categories.firstIndex(of: equalCategory) {
                        categories.remove(at: index)
                    }
                }
        }
    }
}
