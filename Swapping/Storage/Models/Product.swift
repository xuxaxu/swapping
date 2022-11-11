import Foundation

class Product : DataObject {
    
    var category : String?
    var features : Dictionary<Feature, Any>?
    var owner : String?
    var productDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case productDescription = "description"
        case imgUrl = "image_url"
        case category
        case owner
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.productDescription = try container.decodeIfPresent(String.self, forKey: .productDescription)
        self.imgUrl = try container.decodeIfPresent(URL.self, forKey: .imgUrl)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.owner = try container.decodeIfPresent(String.self, forKey: .owner)
    }
    
    class func primaryKey() -> String? {
        return "id"
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    override func getRef() -> String {
        if let identifier = id {
            return "products/" + identifier
        } else {
            return "products"
        }
    }
    
    override func getTopRef() -> String {
        return "products/"
    }
}

