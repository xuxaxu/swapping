//
//  FirebaseNetwork.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 21.04.22.
//

import Foundation
import Firebase

class FireDataBase : ISingleton {
    
    required init(container: IContainer, args: ()) { }
    
    var ref : DatabaseReference = Database.database(url: "https://swappingapp-c409e-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference(forURL: "gs://swappingapp-c409e.appspot.com/")
    
    // MARK: - get Data from DB and put it into array of Any
    
    func getData(path : String, complition: @escaping (Dictionary<String, Data>, Error?)->Void) {
        
        ref.child(path).getData(completion: { [complition] error, snapshot in
            
            guard error == nil else {
              print(error!.localizedDescription)
                complition([:], error)
              return
            }
        
            //decode
            var dataRecieved: Dictionary<String, Data> = [:]
            
                    for child in snapshot.children {
                        let childSnapshot = child as! DataSnapshot
                        if let value = childSnapshot.value {
                            if let _ = value as? String {
                                //if need fields of parent element
                            } else {
                                do { let jsonData = try JSONSerialization.data(withJSONObject: value)
                                    dataRecieved[childSnapshot.key] = jsonData
                                } catch {
                                    //here fields of upper element
                                }
                            }
                        }
                    }
                 complition(dataRecieved, nil)
                    
        }
            )
    }
    
    func getPieceOfData(path: String,
                        complition: @escaping (Data?, Error?)->Void) {
        
        ref.child(path).getData(completion: { [complition] error, snapshot in
            
            guard error == nil else {
              print(error!.localizedDescription)
                complition(nil, error)
              return
            }
        
            //decode
            if snapshot.exists(), let value = snapshot.value {
                 do { let jsonData = try JSONSerialization.data(withJSONObject: value)
                        complition(jsonData, nil)
                        return
                    } catch {
                        
                    }
            }
            complition(nil, nil)
        }
            )
    }
    
    //MARK: - upload/download media
    
    func uploadImage(image : UIImage, ref: String, complition: @escaping (URL)->Void) {
        
        let fullRef = "systemImages/" + ref + ".jpeg"
        
        let refUpload = storageRef.child(fullRef)
        
        DispatchQueue.global(qos: .userInitiated).async { [complition, weak self] in
            if let weakSelf = self, let jpegData = image.jpegData(compressionQuality: weakSelf.compressInt(image: image)) {
            
                let _ = refUpload.putData(jpegData, metadata: nil) { [complition] (metadata, error) in
                    guard let _ = metadata else {
                        //error of uploading
                        return
                    }
                    refUpload.downloadURL { [complition] url, error in
                        guard let url = url else {
                            //error of getting url of image
                            return
                        }
                        complition(url)
                    }
                }
            }
        }
    }
    
    private func compressInt(image : UIImage) -> CGFloat {
        
        let size = image.size.width * image.size.height
        if size > 1024 * 1024 {
            return 1024 * 1024 / size
        } else {
            return 1
        }
    }
    
    func setUrlInObject(url: URL, object: DataObject) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
                let firePath = object.getRef()
                let strUrl = url.absoluteString
                self?.ref.child(firePath + "/image_url").setValue(strUrl)
        
        }
    }
    
    func downloadImage(path: URL, complition: @escaping (UIImage)->Void ) {
     
        DispatchQueue.global(qos: .userInitiated).async { [weak self, path, complition] in
            
            let urlString = path.absoluteString
            if let imageRef = self?.storage.reference(forURL: urlString) {
                    imageRef.getData(maxSize: 1 * 1024 * 1024) { [complition] (data, error) in
                        if let _ = error {
                            //can't dowmload image
                        } else {
                            if let image = UIImage(data: data!) {
                                complition(image)
                            }
                        }
                    }
            }
        }
    }
    
    //MARK: - editing data
    func createObject(object : DataObject)->String {
        
        let objectPath = object.getRef()
        
        guard let newId = ref.child(objectPath).childByAutoId().key else { return ""}
        
        ref.child(objectPath + "/" + newId + "/name").setValue(object.name)
        
        return newId
        
    }
    
    func editObject(object : DataObject, stringValues: Dictionary<String, String>, complition: @escaping (URL)->Void) {
        
        let path = object.getRef()+"/"
        
        //ref.child(path + "name").setValue(object.name)
        
        var updates : [AnyHashable : Any] = [:]
        for (key, value) in stringValues {
            updates[ path + key] = value
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [ref, updates] in
            ref.updateChildValues(updates)
        }
        
        if let image = object.image {
            uploadImage(image: image, ref: object.id ?? "unknown" + ".jpeg", complition: complition)
        }
    }
    
    func deleteObject(object : DataObject, complition: @escaping (String)->Void) {
        //let delete only if there are not childs
        
        let path = object.getRef()
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self, complition] in
            
            self?.ref.child(path).getData { [weak self] error, snapshot in
                guard error == nil else {
                    complition("not ability to read object")
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
                    self?.ref.child(path).removeValue()
                    complition("deletion succeeded")
                } else {
                    complition("Forbidden delete category with child categories")
                }
            }
        }
    }
    
    //MARK: - query to db
    func findPathOfElement(path: String,
                           key: String,
                           value: String,
                           complition: @escaping (String?)->Void) {
        
        let query = ref.child(path).queryEqual(toValue: value, childKey: key)
        query.getData { [complition] error, snapshot in
            if error != nil {
                complition(nil)
                return
            }
            
            if snapshot.exists() {
                
            }
        }
        
    }
    
}
    

