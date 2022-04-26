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
    
    var kindOfData : kindData? //what data we work with (category, feacher, product or users)
    
    
    // MARK: - get Data from DB and put it into array of Any
    
    func getData(path : String) {
        ref.child(path).getData(completion: { [weak self] error, snapshot in
            guard error == nil else {
              print(error!.localizedDescription)
              return
            }
              
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
            })
    }
    
    //MARK: - upload/download media
    
    func uploadImage(image : UIImage, ref: String, owner: Any) {
        
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
    
    func setUrlInObject(url: URL, object: Any) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let category = object as? Category {
                category.imgUrl = url
                let categoryPath = category.getRef()
                let strUrl = url.absoluteString
                self?.ref.child(categoryPath + "/imageUrl").setValue(strUrl)
            }
        }
    }
    
    func downloadImage(url: URL, owner: ObjectWithImage) {
     //   DispatchQueue.global(qos: .background).async { [weak self] in
        let urlString = url.absoluteString
        let imageRef = storage.reference(forURL: urlString) //{
                imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if let _ = error {
                        //can't dowmload image
                    } else {
                        owner.image = UIImage(data: data!)
                        DataService.shared.mediaGotten(owner: owner)
                    }
                }
        //}
    }
    
    //MARK: - upload/download categories
    
    func getCategories(in category : Category?) {
        
        let categoryPath = (category?.getRef() ?? "categories") + "/"
        
        self.kindOfData = .category
        
        getData(path: categoryPath)
                
    }
    
    func createCategory(category : Category) {
        
        let categoryPath = category.getRef()
        
        ref.child(categoryPath + "/name").setValue(category.name)
        
        if let image = category.image {
            uploadImage(image: image, ref: "systemImages/" + category.name + ".jpeg", owner: category)
        }
    }
    
}

protocol FireDataBaseDelegate : AnyObject {
    func DataGotten(kind : kindData, data: [Dictionary<String, Any>]) 
}
