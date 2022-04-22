//
//  FirebaseNetwork.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 21.04.22.
//

import Foundation
import Firebase
import Metal

class FireDataBase {
    
    static var shared = FireDataBase()
    
    var ref : DatabaseReference = Database.database(url: "https://swappingapp-c409e-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    
    var currentUser : User?
    
    var delegateCategories : FireDataBaseDelegate?
    
    var categories : [Category] = []
    
    var parentCategory : Category?
    
    func getCategories(in category : Category?) {
        
        parentCategory = category
        let categoryPath = (category?.getRef() ?? "categories") + "/"
        
        categories = []
        ref.child(categoryPath).getData(completion:  { [weak self] error, snapshot in
              guard error == nil else {
                print(error!.localizedDescription)
                return;
              }
                
                for child in snapshot.children {
                    let childSnapshot = child as! DataSnapshot
                    if let element = childSnapshot.value as? Dictionary<String, Any> {
                        if let name = element["name"] as? String {
                            self?.categories.append(Category(name: name, parent: self?.parentCategory))
                        }
                    }
                }
                
                    self?.delegateCategories?.refreshData()
            
            })
    }
    
    func createCategory(category : Category) {
        
        let categoryPath = category.getRef()
        
        ref.child(categoryPath + "/name").setValue(category.name)
        
    }
}

protocol FireDataBaseDelegate {
    func refreshData() 
}
