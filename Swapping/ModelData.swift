//
//  ModelData.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 19.04.22.
//

import Foundation
import Firebase

class Category : NSObject, ObjectWithImage {
    var name : String
    var parent : Category?
    var image : UIImage?
    var imgUrl : URL?
    
    init(name : String, parent : Category?, image : UIImage?) {
        self.name = name
        self.parent = parent
        self.image = image
    }
    
    func getRef() -> String {
        if parent == nil {
            return "categories/" + name
        } else {
            return parent!.getRef() + "/" + name
        }
    }
}

class Product : NSObject {
    
}
