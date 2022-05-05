//
//  FirebaseNetwork.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 21.04.22.
//

import Foundation
import Firebase

class FireDataBase {
    
    static var shared = FireDataBase()
    
    var ref : DatabaseReference = Database.database(url: "https://swappingapp-c409e-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference(forURL: "gs://swappingapp-c409e.appspot.com/")
    
    weak var delegate : FireDataBaseDelegate? //data service
    weak var alertDelegate : FireDataBaseAlertDelegate?
    
    var kindOfData : kindData? //what data we work with (category, feacher, product or users)
    
    
    // MARK: - get Data from DB and put it into array of Any
    
    func getData(path : String, _ hierarhicaly: Bool = false) {
        
        ref.child(path).getData(completion: { [weak self, hierarhicaly] error, snapshot in
            
            guard error == nil else {
              print(error!.localizedDescription)
              return
            }
              
            if hierarhicaly {
                
                self?.getDataHierarhicaly(snapshot: snapshot)
                
            } else {
            
                if self?.kindOfData == .product {
                    //decode product
                    for child in snapshot.children {
                        let childSnapshot = child as! DataSnapshot
                        if let data = try? JSONSerialization.data(withJSONObject: childSnapshot.value) {
                            DataService.shared.jsonGotten(data: data, id: childSnapshot.key)
                        }
                    }
                    
                } else {
                
                    var arrayData : [Dictionary<String, Any>] = []
                
                    for child in snapshot.children {
                        let childSnapshot = child as! DataSnapshot
                        if let element = childSnapshot.value as? Dictionary<String, Any> {
                            arrayData.append(element)
                          }
                      }
                    if let kindOfData = self?.kindOfData {
                        self?.delegate?.DataGotten(kind: kindOfData, data: arrayData)
                    }
                }
            }
        }
            )
    }
    
    func getDataHierarhicaly(snapshot: DataSnapshot, _ topLevel : String = "") {
        for child in snapshot.children {
            let childSnapshot = child as! DataSnapshot
            if let fields = childSnapshot.value as? Dictionary<String, Any> {
                if let name = fields["name"] as? String {
                    var currentTopLevel = topLevel
                    
                    if self.kindOfData == .topLevelCategory {
                        if topLevel == "" {
                            DataService.shared.topLevelCategories.append(name)
                            currentTopLevel = name
                        } else {
                            if DataService.shared.allCategories[currentTopLevel] != nil {
                                DataService.shared.allCategories[currentTopLevel]!.append(name)
                            } else {
                                DataService.shared.allCategories[currentTopLevel] = [name]
                            }
                        }
                    }
                    getDataHierarhicaly(snapshot: childSnapshot, currentTopLevel)
                }
            }
        }
    }
    
    //MARK: - upload/download media
    
    func uploadImage(image : UIImage, ref: String, owner: ObjectWithImage) {
        
        let refUpload = storageRef.child(ref)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let jpegData = image.jpegData(compressionQuality: DataService.shared.compressInt(image: image)) {
            
                let _ = refUpload.putData(jpegData, metadata: nil) { [owner, weak self] (metadata, error) in
                    guard let _ = metadata else {
                        //error of uploading
                        return
                    }
                    refUpload.downloadURL { url, error in
                        guard let url = url else {
                            //error of getting url of image
                            return
                        }
                        self?.setUrlInObject(url: url, object: owner)
                    }
                }
            }
        }
    }
    
    func setUrlInObject(url: URL, object: ObjectWithImage) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
                object.imgUrl = url
                let firePath = object.getRef()
                let strUrl = url.absoluteString
                self?.ref.child(firePath + "/image_url").setValue(strUrl)
            
        }
    }
    
    func downloadImage(url: URL, owner: ObjectWithImage) {
     
        let urlString = url.absoluteString
        let imageRef = storage.reference(forURL: urlString)
                imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if let _ = error {
                        //can't dowmload image
                    } else {
                        owner.image = UIImage(data: data!)
                        DataService.shared.mediaGotten(owner: owner)
                    }
                }
    }
    
    //MARK: - upload/download categories
    
    func getCategories(in category : Category?) {
        
        let categoryPath = (category?.getRef() ?? "categories") + "/"
        
        self.kindOfData = .category
        
        getData(path: categoryPath)
                
    }
    
    func getCategoriesForPicker() {
        
        DataService.shared.topLevelCategories = []
        DataService.shared.allCategories = [:]
        
        self.kindOfData = .topLevelCategory
        
        getData(path: "categories/", true)

    }
    
    func createCategory(category : Category) {
        
        let categoryPath = category.getRef()
        
        ref.child(categoryPath + "/name").setValue(category.name)
        
        if let image = category.image {
            uploadImage(image: image, ref: "systemImages/" + (category.name ?? "unknown") + ".jpeg", owner: category)
        }
    }
    
    func editCategory(category : Category, newName : String, newImage : UIImage?) {
        
        let categoryPath = category.getRef()
        
        ref.child(categoryPath + "/name").setValue(newName)
        category.name = newName
        
        if let image = newImage {
            uploadImage(image: image, ref: "systemImages/" + (category.name ?? "unknown") + ".jpeg", owner: category)
        }
    }
    
    func deleteCategory(category : Category, vcForAlert : UIViewController) {
        //let delete only if there are not child categories
        
        let categoryPath = category.getRef()
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            
            self?.ref.child(categoryPath).getData { [weak self] error, snapshot in
                guard error == nil else {
                    DataService.shared.getCategories(in: category.parent)
                    return
                }
                var noChild = true
                for child in snapshot.children {
                    if let _ = (child as! DataSnapshot).value as? NSDictionary {
                        noChild = false
                        break
                    }
                }
                if noChild {
                    self?.ref.child(categoryPath).removeValue()
                } else {
                    DataService.shared.getCategories(in: category.parent)
                    
                    self?.alertDelegate?.showAlert(message: "Forbidden delete category with child categories")
                }
            }
        }
    }
    
    //MARK: - upload/download Products
    
    func getProducts() {
        
        let productPath = "products/"
        
        self.kindOfData = .product
        
        getData(path: productPath)
                
    }
    
    func editProduct(product : Product) {
        
        if DataService.shared.currentUser == nil {
            //need authenticate
            return
        }
        
        if product.id == nil {
            guard let id = ref.child("products/").childByAutoId().key  else {return}
            product.id = id
        }
        let productRef = "products/\(product.id!)/"
        
        let updates : [AnyHashable : Any] = [productRef + "name" : (product.name ?? "unknown"),
                                             productRef + "description" : product.productDescription ?? "",
                       productRef + "category" : (product.category ?? "unknown"),
                       productRef + "owner" : DataService.shared.currentUser!.uid]
        ref.updateChildValues(updates)
        
        if let image = product.image {
            uploadImage(image: image, ref: "productImages/" + product.id! + ".jpeg", owner: product)
        }
    }
    
    func deleteProduct(product : Product, vcForAlert : UIViewController) {
        
        //let delete only if there are not chats with product
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            
            var noChat = true
                
            if noChat, let productId = product.id {
                    self?.ref.child("products").child(productId).removeValue()
                } else {
                    self?.alertDelegate?.showAlert(message: "Forbidden delete product which has been used in chats")
                }
            }
    }
    
}

protocol FireDataBaseDelegate : AnyObject {
    func DataGotten(kind : kindData, data: [Dictionary<String, Any>]) 
}

protocol FireDataBaseAlertDelegate : UIViewController {
    func showAlert(message : String)
}
