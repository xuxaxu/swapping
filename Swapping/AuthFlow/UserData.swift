//
//  userData.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 27.05.22.
//

import Foundation
import Firebase

/* some class for saving user */
class UserData : DataObject {
    
    convenience init(uid: String, name : String, image : UIImage?) {
        self.init()
        
        self.name = name
        self.image = image
        self.id = uid
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
    
    class func primaryKey() -> String? {
        return "id"
    }
    
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.id == rhs.id
    }
    
    override func getRef() -> String {
        return "usersData/" + (id ?? "unknown")
    }
    
    override func getTopRef() -> String {
        return "userData/"
    }
}

