//
//  Subject.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 15.06.22.
//

import Foundation

protocol ObjectWithId: AnyObject {
    
    var id: String? { get set }
    
    func getRef() -> String
    
    func getTopRef() -> String
}

protocol MessageProtocol: ObjectWithId {
    var authorId: String? { get set }
    var recieverId: String? { get set }
    var date: Date? { get set }
    var subjectId: String? { get set }
    var typeOfSubject: TypesOfSubjects? { get set }
    var text: String? { get set }
    var id: String? { get set }
    var year: Int? { get set }
    var month: Int? { get set }
    var day: Int? { get set }
    var hour: Int? { get set }
    var minute: Int? { get set }
    var second: Int? { get set }
}

enum TypesOfSubjects: String, Codable {
    case product
    case user
    case category
}

class Message : MessageProtocol, Decodable {
    
    var id: String?
    
    var authorId: String?
    
    var recieverId: String?
    
    var date: Date?
    
    var subjectId: String?
    
    var typeOfSubject: TypesOfSubjects?
    
    var files: [URL]?
    
    var text: String?
    
    var year: Int?
    var month: Int?
    var day: Int?
    var hour: Int?
    var minute: Int?
    var second: Int?
    
    convenience init(authorId: String, subject: Product, message: String) {
        self.init()
        
        self.subjectId = subject.id
        self.recieverId = subject.owner
        self.authorId = authorId
        self.typeOfSubject = .product
        let currentDate = Date()
        self.date = currentDate
        setDateComponents()
        self.text = message
    }
    
    enum CodingKeys: String, CodingKey {
        case subjectId = "subject_id"
        case authorId = "author_id"
        case recieverId = "reciever_id"
        case year
        case month
        case day
        case minute
        case hour
        case second
        case typeOfSubject = "type_of_subject"
        case files
        case text
        case id
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.authorId = try container.decodeIfPresent(String.self, forKey: .authorId)
        self.recieverId = try container.decodeIfPresent(String.self, forKey: .recieverId)
        self.subjectId = try container.decodeIfPresent(String.self, forKey: .subjectId)
        self.typeOfSubject = try container.decodeIfPresent(TypesOfSubjects.self, forKey: .typeOfSubject)
        self.files = try container.decodeIfPresent([URL].self, forKey: .files)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.year = try container.decodeIfPresent(Int.self, forKey: .year)
        self.month = try container.decodeIfPresent(Int.self, forKey: .month)
        self.day = try container.decodeIfPresent(Int.self, forKey: .day)
        self.hour = try container.decodeIfPresent(Int.self, forKey: .hour)
        self.minute = try container.decodeIfPresent(Int.self, forKey: .minute)
        self.second = try container.decodeIfPresent(Int.self, forKey: .second)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        self.date = Calendar.current.date(from: dateComponents)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
    }
    
    func setDateComponents() {
        if let curDate = date {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: curDate)
            year = components.year
            month = components.month
            day = components.day
            hour = components.hour
            minute = components.minute
            second = components.second
        }
    }
    
}

extension MessageProtocol {
    
    func getRef() -> String {
        return "messages/" + (id ?? "")
    }
    
    func getTopRef() -> String {
        return "messages"
    }
    
}
