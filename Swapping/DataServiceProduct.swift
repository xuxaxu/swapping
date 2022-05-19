//
//  DataServiceProduct.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 15.05.22.
//

import Foundation
import UIKit.UIImage

class DataServiceProduct : DataService, IPerRequest {
    
    //for notifying about image recieving
    var image: Dynamic<Product> = Dynamic(Product())
    
    //we got from db array of objects and notify about their changes
    var arrayOfObjects: Dynamic<[Product]> = Dynamic([])
    
    
    //MARK: recieving of array of data
    func getData(ref: String, _ withImages: Bool = true, complition: @escaping ([Product])->Void) {
    
            fireDataBase?.getData(path: ref) { [weak self, complition, withImages] dictData in
                
                var arrayOfData: [Product] = []
                
                for (key, value) in dictData {
                    if let object = try? JSONDecoder().decode(Product.self, from: value) {
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
    
    
    func loadImage(owner: Product) {
        if let url = owner.imgUrl {
            fireDataBase?.downloadImage(path: url) { [weak self, owner] image in
                owner.image = image
                self?.image.value = owner
            }
        }
    }
    
    func uploadImage(image : UIImage, owner: Product) {
        
        fireDataBase?.uploadImage(image: image, ref: owner.id ?? (owner.name ?? "unknown")) { [owner, weak self] url in
            self?.setUrlInObject(url: url, object: owner)
        }
                    
    }
    
    func setUrlInObject(url: URL, object: Product) {
        object.imgUrl = url
        fireDataBase?.setUrlInObject(url: url, object: object)
    }
    
        
    func createObject(object : Product) {
            
        fireDataBase?.createObject(object: object)
            
            if let image = object.image {
                uploadImage(image: image, owner: object)
            }
    }
    
    func getProducts() {
        
        let path = "products/"
        
        getData(ref: path, type: type) { [weak self] objects in
            self?.arrayOfObjects.value = objects
            }
    }
    
    func editProduct(product: Product) {
        let values = ["name" : product.name ?? "unknown",
                      "description" : product.productDescription ?? "",
                      "category" : product.category ?? "unknown",
                      "owner" : product.owner?.uid ?? "unknown"]
        fireDataBase?.editObject(object: product, stringValues: values, complition: { [weak self, product] url in
            self?.setUrlInObject(url: url, object: product)
        })
    }
    
}
