//
//  DataServiceCategory.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 15.05.22.
//

import Foundation
import UIKit.UIImage

class DataServiceCategory : DataService, IPerRequest {
    
    private var fireDataBase : FireDataBase?
    
    //for notifying about image recieving
    var image: Dynamic<Category> = Dynamic(Category())
    
    //we got from db array of objects and notify about their changes
    var arrayOfObjects: Dynamic<[Category]> = Dynamic([])
    
    required init(container: IContainer, args: ()) {
        fireDataBase = FireDataBase(container: container, args: args)
    }
    
    //for picker category
    var arrayOfChildren: Dynamic<(Category, [Category])> = Dynamic((Category(),[]))
    
    
    //MARK: recieving of array of data
    func getData(ref: String, _ withImages: Bool = true, complition: @escaping ([Category])->Void) {
    
            fireDataBase?.getData(path: ref) { [weak self, complition, withImages] dictData in
                
                var arrayOfData: [Category] = []
                
                for (key, value) in dictData {
                    if let object = try? JSONDecoder().decode(Category.self, from: value) {
                            object.id = key
                            arrayOfData.append(object)
                        
                        if withImages, let imgUrl = object.imgUrl {
                            self?.fireDataBase?.downloadImage(path: imgUrl, complition: { [object] image in
                                object.image = image
                                
                                self?.image.value = object
                            })
                        }
                    }
                }
                
                complition(arrayOfData)
            }
        }
    
    func getDataToArrayOfChildren(ref: String, object: Category) {
        getData(ref: ref, false) { [weak self] objects in
            self?.arrayOfChildren.value = (object, objects)
        }
    }
    
    func loadImage(owner: Category) {
        if let url = owner.imgUrl {
            fireDataBase?.downloadImage(path: url) { [weak self, owner] image in
                owner.image = image
                self?.image.value = owner
            }
        }
    }
    
    func uploadImage(image : UIImage, owner: Category) {
        
        fireDataBase?.uploadImage(image: image, ref: owner.id ?? (owner.name ?? "unknown")) { [owner, weak self] url in
            self?.setUrlInObject(url: url, object: owner)
        }
                    
    }
    
    func setUrlInObject(url: URL, object: Category) {
        object.imgUrl = url
        fireDataBase?.setUrlInObject(url: url, object: object)
    }
    
        
    func createObject(object : Category) {
            
        fireDataBase?.createObject(object: object)
            
            if let image = object.image {
                uploadImage(image: image, owner: object)
            }
    }
    
    //MARK: - work with Category
    //get only child categories of argument from FireDB
    func getCategories(in category: Category?, _ withImages: Bool = true) {
        
        let categoryPath = (category?.getRef() ?? "categories") + "/"
        
        getData(ref: categoryPath, withImages) { [weak self] objects in
            self?.arrayOfObjects.value = objects
            }
    }
    
    func editCategory(category: Category, newName: String) {
        let values = ["name" : newName]
        
        fireDataBase?.editObject(object: category, stringValues: values, complition: { [weak self, category] url in
            self?.setUrlInObject(url: url, object: category)
        })
    }
    
    func getChildCategories(inCategory category: Category, topLevelCategory: Category) {
        
        let categoryPath = category.getRef() + "/"
        
        getData(ref: categoryPath, false) { [weak self, topLevelCategory] objects in
            self?.arrayOfChildren.value = (topLevelCategory, objects)
        }
    }
    
}
