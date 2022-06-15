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
    var parentId : String?
    
    convenience init(name : String, parent : Category?, image : UIImage?) {
        self.init()
        self.name = name
        self.parent = parent
        self.image = image
        self.parentId = parent?.id
    }
    
    override func getRef() -> String {        
            return "categories/" + (id ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case imgUrl = "image_url"
        case id
        case parentId = "parent_id"
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.imgUrl = try container.decodeIfPresent(URL.self, forKey: .imgUrl)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
    }
    
    class func primaryKey() -> String? {
        return "id"
    }
}
extension Category: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
