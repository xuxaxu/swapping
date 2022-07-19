//
//  ObjectWithId.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 19.07.22.
//

import Foundation

protocol ObjectWithId {
    
    var id: String? { get set }
    
    func getRef() -> String
    
    func getTopRef() -> String
}

enum TypesOfSubjects: String, Codable {
    case product
    case user
    case category
}
