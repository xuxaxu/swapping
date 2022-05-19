//
//  Category.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 11.05.22.
//

import Foundation
import UIKit.UIImage

class Category : DataObject {
    
    var parent : Category?
    
    convenience init(name : String, parent : Category?, image : UIImage?) {
        self.init()
        self.name = name
        self.parent = parent
        self.image = image
        self.id = name
    }
    
    override func getRef() -> String {
        if parent == nil {
            return "categories/" + (name ?? "unknown")
        } else {
            return parent!.getRef() + "/" + (name ?? "unknown")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case imgUrl = "image_url"
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.imgUrl = try container.decodeIfPresent(URL.self, forKey: .imgUrl)
        
    }
    
    class func primaryKey() -> String? {
        return "name"
    }
}
