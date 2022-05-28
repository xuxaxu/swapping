//
//  DataService.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import Foundation
import FirebaseAuth

class DataService<T: DataObject> : NSObject, IPerRequest {
    
    var fireDataBase : FireDataBase
    
    //for notifying about image recieving
    var image: Dynamic<T>
    
    //we got from db array of objects and notify about their changes
    var arrayOfObjects: Dynamic<[T]>
    
    typealias Arguments = T.Type
    
    //for picker category
    var arrayOfChildren: Dynamic<(Category, [Category])> = Dynamic((Category(),[]))
    
    var errorMessage = Dynamic("")
    
    
    required init(container: IContainer, args: T.Type) {
        fireDataBase = FireDataBase(container: container, args: ())
        image = Dynamic(T.init())
        arrayOfObjects = Dynamic([T.init()])
    }
    
    //MARK: recieving of array of data
    func getData(ref: String, _ withImages: Bool = true, complition: @escaping ([T])->Void) {
    
            fireDataBase.getData(path: ref) { [weak self, complition, withImages] dictData, error in
                
                guard error == nil else {
                    self?.errorMessage.value = error!.localizedDescription
                    return
                }
                
                var arrayOfData: [T] = []
                
                for (key, value) in dictData {
                    if let object = try? JSONDecoder().decode(T.self, from: value) {
                            object.id = key
                            arrayOfData.append(object)
                        
                        if withImages, let imgUrl = object.imgUrl {
                            self?.fireDataBase.downloadImage(path: imgUrl, complition: { [object] image in
                                object.image = image
                                
                                self?.image.value = object
                            })
                        }
                    }
                }
                
                complition(arrayOfData)
            }
        }
    
    func getDataToArrayOfObjects(ref: String, _ withImages: Bool = true) {
        getData(ref: ref, withImages) { [weak self] objects in
            
            self?.arrayOfObjects.value = objects
            
        }
    }
    
    func loadImage(owner: T) {
        if let url = owner.imgUrl {
            fireDataBase.downloadImage(path: url) { [weak self, owner] image in
                owner.image = image
                self?.image.value = owner
            }
        }
    }
    
    func uploadImage(image : UIImage, owner: T) {
        
        fireDataBase.uploadImage(image: image, ref: owner.id ?? (owner.name ?? "unknown")) { [owner, weak self] url in
            self?.setUrlInObject(url: url, object: owner)
        }
                    
    }
    
    func setUrlInObject(url: URL, object: T) {
        object.imgUrl = url
        fireDataBase.setUrlInObject(url: url, object: object)
    }
    
        
    func createObject(object : T) {
            
        let newId = fireDataBase.createObject(object: object)
        
        if newId != "" {
            
            object.id = newId
            
            if let image = object.image {
                uploadImage(image: image, owner: object)
            }
            
        } else {
            
            errorMessage.value = "can't create object"
            
        }
    }
    
    func deleteObject(object: T, complition: @escaping (String)-> Void) {
        fireDataBase.deleteObject(object: object, complition: complition)
    }
    
    func getElement(path: String, withImage : Bool = false, complition: @escaping (T)->Void) {
        
        fireDataBase.getPieceOfData(path: path) { [weak self, complition, withImage] data, error in
            
            guard error == nil else {
                self?.errorMessage.value = error!.localizedDescription
                return
            }
            
            if let jsonData = data,
                let object = try? JSONDecoder().decode(T.self, from: jsonData) {
                
                if withImage, let imgUrl = object.imgUrl {
                    self?.fireDataBase.downloadImage(path: imgUrl, complition: { [object] image in
                        object.image = image
                        
                        self?.image.value = object
                    })
                }
                complition(object)
            }
        }
            
    }
    
    func editObject(object: T, newName: String) {
        let values = ["name" : newName]
        
        fireDataBase.editObject(object: object, stringValues: values, complition: { [weak self, object] url in
                self?.setUrlInObject(url: url, object: object)
        })
    }
    
    //MARK: - work with Category
    //get only child categories of argument from FireDB
    func getCategories(in category: Category?, _ withImages: Bool = true) {
        
        let categoryPath = (category?.getRef() ?? "categories") + "/"
        
        getDataToArrayOfObjects(ref: categoryPath, withImages)
    }
    
    func getDataToArrayOfChildren(ref: String, object: Category) {
        getData(ref: ref, false) { [weak self] objects in
            var categories = objects as? [Category]
            if categories == nil {
                categories = []
            }
        
            self?.arrayOfChildren.value = (object, categories!)
        }
    }
    
    func getChildCategories(inCategory category: Category, topLevelCategory: Category) {
        
        let categoryPath = category.getRef() + "/"
        
        getDataToArrayOfChildren(ref: categoryPath, object: topLevelCategory)
    }
    
    func getParentsOfCategory(name: String) {
        fireDataBase.findPathOfElement(path: "categories/", key: "name", value: name) { parents in
            if let strParents = parents {
                
            }
        }
    }
    
    //MARK: work with products
    func getProducts() {
        
        let path = "products/"
        
        getDataToArrayOfObjects(ref: path)
    }
    
    func editProduct(product: Product) {
        let values = ["name" : product.name ?? "unknown",
                      "description" : product.productDescription ?? "",
                      "category" : product.category ?? "unknown",
                      "owner" : product.owner ?? "unknown"]
        fireDataBase.editObject(object: product, stringValues: values, complition: { [weak self, product] url in
            if let productFromGeneric = product as? T {
                self?.setUrlInObject(url: url, object: productFromGeneric)
            }
        })
    }
    
}
