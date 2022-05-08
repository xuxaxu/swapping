//
//  ModelData.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 19.04.22.
//

import Foundation
import Firebase

class Category : ObjectWithImage, Equatable, Decodable {
    
    var name : String?
    var parent : Category?
    var image : UIImage?
    var imgUrl : URL?
    
    convenience init(name : String, parent : Category?, image : UIImage?) {
        self.init()
        self.name = name
        self.parent = parent
        self.image = image
    }
    
    func getRef() -> String {
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

class Product : ObjectWithImage, Decodable, Equatable {
    
    var name : String?
    var category : String?
    var image : UIImage?
    var imgUrl: URL?
    var features : Dictionary<Feature, Any>?
    var owner : User?
    var productDescription: String?
    var id : String?
    
    convenience init(name : String, category : String, image : UIImage?, features : Dictionary<Feature, Any>?, description : String?) {
        self.init()
        if let owner = DataService.shared.currentUser {
            self.owner = owner
        }
            self.name = name
            self.category = category
            self.image = image
            self.features = features
            self.productDescription = description
        
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case productDescription = "description"
        case imgUrl = "image_url"
        case category
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.productDescription = try container.decodeIfPresent(String.self, forKey: .productDescription)
        self.imgUrl = try container.decodeIfPresent(URL.self, forKey: .imgUrl)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
    }
    
    class func primaryKey() -> String? {
        return "id"
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getRef() -> String {
        return "products/" + (id ?? "unknown")
    }
}

enum Feature {
    case color
    case size
    case volume
    case weight
    case material
}

//which kind of data we'll be work with
enum kindData {
    case category
    case topLevelCategory
    case product
    case feature
    case appUser
}

//any kind who have image
protocol ObjectWithImage : AnyObject {
    var image : UIImage? {get set}
    var imgUrl: URL? {get set}
    var name: String? {get set}
    func getRef() -> String
}
