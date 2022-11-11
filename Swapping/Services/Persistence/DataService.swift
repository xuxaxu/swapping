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
    
    var objectWithImage: T? {
        didSet {
            DispatchQueue.main.async { [objectWithImage] in
                NotificationCenter.default.post(name: .ImageLoadedForObject,
                                                object: objectWithImage)
            }
        }
    }
    
    //we got from db array of objects and notify about their changes
    var arrayOfObjects: Dynamic<[T]> {
        didSet {
            DispatchQueue.main.async { [weak self] in
                NotificationCenter.default.post(name: .ArrayOfObjectsChanged,
                                                object: self)
            }
        }
    }
    
    typealias Arguments = T.Type
    
    //for picker category
    var arrayOfChildren: Dynamic<(Category, [Category])> = Dynamic((Category(),[]))
    
    var errorMessage = Dynamic("")
    
    var publisher: RefreshPublisher
    
    
    required init(container: IContainer, args: T.Type) {
        fireDataBase = container.resolve(args: ()) //FireDataBase(container: container, args: ())
        image = Dynamic(T.init())
        arrayOfObjects = Dynamic([T.init()])
        publisher = container.resolve(args: ())
    }
    
    //MARK: recieving of array of data
    
    func recieveData(ref: String, key: String?, value: String?, _ withImages: Bool = true, complition: @escaping ([T])->Void) {
    
        DispatchQueue.global(qos: .userInteractive).async {
            [weak self, ref, key, value, complition] in
            
            self?.fireDataBase.recieveData(path: ref, key: key, value: value) {
                [weak self, complition, withImages] dictData, error in
                    
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
                                    self?.objectWithImage = object
                                })
                            }
                        }
                    }
                
                complition(arrayOfData)
            }
        }
    }
    
    func getDataToArrayOfObjects(ref: String,
                                 key: String? = nil,
                                 value: String? = nil,
                                 _ withImages: Bool = true) {
        recieveData(ref: ref, key: key, value: value, withImages) { [weak self] objects in
           
            self?.arrayOfObjects.value = objects
            NotificationCenter.default.post(name: .ArrayOfObjectsChanged, object: self)
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
        
        if let id = object.id {
            publisher.postUpdates(id: RefreshPublisher.updatedUrl(id: id, url: url))
        }
    }
    
        
    func createObject(object : T) {
            
        let newId = fireDataBase.createObject(object: object)
        
        if newId != "" {
            
            object.id = newId
            
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
    
    func editObject(object: T, newName: String, completion: @escaping () -> Void) {
        let values = ["name" : newName]
        
        fireDataBase.editObject(object: object, stringValues: values, editObjectCompletion: completion, complition: { [weak self, object] url in
                self?.setUrlInObject(url: url, object: object)
        })
    }
    
    //MARK: - work with Category
    //get only child categories of argument from FireDB
    func getCategories(in category: Category?, _ withImages: Bool = true) {
        
        let categoryPath = "categories/"
        
        getDataToArrayOfObjects(ref: categoryPath,
                                key: "parent_id",
                                value: category?.id ?? "",
                                withImages)
    }
    
    //get categories without hierarhy
    func getAllCategories(withImages: Bool = true) {
        
        let categoryPath = "categories/"
        
        getDataToArrayOfObjects(ref: categoryPath,
                                key: nil,
                                value: "",
                                withImages)
    }
    
    func getDataToArrayOfChildren(parent: String, object: Category) {
        
        recieveData(ref: "categories", key: "parent_id", value: parent) {
            [weak self] objects in
            var categories = objects as? [Category]
            if categories == nil {
                categories = []
            }
        
            self?.arrayOfChildren.value = (object, categories!)
        }
    }
    
    func getChildCategories(inCategory category: Category, topLevelCategory: Category) {
        
        getDataToArrayOfChildren(parent: category.id ?? "", object: topLevelCategory)
    }
    
    func editCategory(category: Category, completion: @escaping () -> Void) {
        let values = ["name" : category.name ?? "unknown", "parent_id" : category.parentId ?? ""]
        
        fireDataBase.editObject(object: category, stringValues: values, editObjectCompletion: completion, complition: { [weak self, category] url in
            if let categoryToType = category as? T {
                self?.setUrlInObject(url: url, object: categoryToType)
                if let id = categoryToType.id, let url = categoryToType.imgUrl {
                    self?.publisher.postUpdates(id: RefreshPublisher.updatedUrl(id: id, url: url))
                }
            }
        })
    }
    
    
    //MARK: work with products
    func getProducts() {
        
        let path = "products/"
        
        getDataToArrayOfObjects(ref: path)
    }
    
    func editProduct(product: Product, completion: @escaping () -> Void) {
        let values = ["name" : product.name ?? "unknown",
                      "description" : product.productDescription ?? "",
                      "category" : product.category ?? "unknown",
                      "owner" : product.owner ?? "unknown"]
        fireDataBase.editObject(object: product,
                                stringValues: values,
                                editObjectCompletion: completion,
                                complition: { [weak self, product] url in
            if let productFromGeneric = product as? T {
                self?.setUrlInObject(url: url, object: productFromGeneric)
            }
        })
    }
    
}

extension Notification.Name {
    static let ArrayOfObjectsChanged = Notification.Name(
        rawValue: "com.Swapping.DataService.ArrayOfDataChanged")
    static let ImageLoadedForObject = Notification.Name(
        rawValue: "com.Swapping.DataService.ImageLoaded")
}
