//
//  CategoryFilter.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 09.06.22.
//

import Foundation
import UIKit

class CategoryFilter: ISingleton {
    
    
    private var dataService: DataService<Category>
    
    //for searching : key = category.id, value = string with names of child categories + category.name
    var filteredStr: Dictionary<String, String> = [:]
    
    private var categories: [Category] = []
    
    //for filter by categories
    var menuCategories: Dynamic<Dictionary<Category, [String]>> = Dynamic([:])
    
    var filterCategoryStr: Dynamic<Dictionary<String, String>> = Dynamic([:])
    
    required init(container: IContainer, args: ()) {
        dataService = container.resolve(args: Category.self)
        
        bindDataServise()
    }
    
    private func bindDataServise() {
        dataService.arrayOfObjects.bind { [weak self] categories in
            if !categories.isEmpty {
            
                    for category in categories {
                            self?.addToFilterCategory(category: category)
                            
                            self?.dataService.getCategories(in: category)
                    }
            }
        }
    }
    
    //searching
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
    
    //filter by categories
    func getAllCategories() {
        dataService.getCategories(in: nil)
    }
    
    private func addToFilterCategory(category: Category) {
        if let name = category.name, let id = category.id {
            if let parent_id = category.parentId, parent_id != "" {
                
                //all added in str where parent is
                let filteredFilterCategories = filterCategoryStr.value.filter({ $0.value.contains(parent_id)})
                for key in filteredFilterCategories.keys {
                    filterCategoryStr.value[key] = filterCategoryStr.value[key]! + " " + id
                }
                
                //is it second level
                let filteredTopLevel = menuCategories.value.keys.filter({ $0.id == parent_id})
                for key in filteredTopLevel {
                    menuCategories.value[key]?.append(name)
                }
                
            } else {
                //top level
                menuCategories.value[category] = []
                filterCategoryStr.value[name] = id
            }
        }
    }
    
}
