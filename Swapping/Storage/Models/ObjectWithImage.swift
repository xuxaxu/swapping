import Foundation
import UIKit.UIImage

//any kind who have image
protocol ObjectWithImage : Decodable, Equatable, ObjectWithId {
    var image : UIImage? {get set}
    var imgUrl: URL? {get set}
    var name: String? {get set}
    
}

class DataObject: ObjectWithImage {
    
    func getTopRef() -> String {
        return "objects/"
    }
    
    static func == (lhs: DataObject, rhs: DataObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    var image: UIImage?
    
    var imgUrl: URL?
    
    var name: String?
    
    var id: String?
    
    func getRef() -> String {
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case imgUrl = "image_url"
        case id
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.imgUrl = try container.decodeIfPresent(URL.self, forKey: .imgUrl)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
    }
    
    required init() {
        
    }
    
}

enum Feature {
    case color
    case size
    case volume
    case weight
    case material
}
