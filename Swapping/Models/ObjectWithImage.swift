//
//  ObjectWithImage.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 11.05.22.
//

import Foundation
import UIKit.UIImage

//any kind who have image
protocol ObjectWithImage : AnyObject, Decodable, Equatable {
    var image : UIImage? {get set}
    var imgUrl: URL? {get set}
    var name: String? {get set}
    var id: String? {get set}
    
    func getRef() -> String
    
}

class DataObject: ObjectWithImage {
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
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.imgUrl = try container.decodeIfPresent(URL.self, forKey: .imgUrl)
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

//which kind of data we'll be work with
enum kindData {
    case category
    case topLevelCategory
    case product
    case feature
    case appUser
}
