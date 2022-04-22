//
//  ModelData.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 19.04.22.
//

import Foundation
import Firebase

class Category : NSObject {
    var name : String
    var parent : Category?
    var img : UIImage?
    
    init(name : String, parent : Category?) {
        self.name = name
        self.parent = parent
    }
    
    func getRef() -> String {
        if parent == nil {
            return "categories/" + name
        } else {
            return parent!.getRef() + name
        }
    }
}

class FireCategory : NSObject {
    var name : AnyObject!
    var img : AnyObject!
}

class Product : NSObject {
    
}
