//
//  MessageService.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 15.06.22.
//

import Foundation

class MessageService: MessageServiceProtocol, ISingleton {
    
    var fireDataBase: FireDataBase
    
    var errorMessage = Dynamic("")
    
    required init(container: IContainer, args: ()) {
        fireDataBase = container.resolve(args: ())
    }
    
    func writeMessage(message: inout MessageProtocol) {
        
        message.id = fireDataBase.createObject(object: message)
        
        let values: [String : Any] = ["author_id" : message.authorId ?? "unknown",
                      "reciever_id" : message.recieverId ?? "unknown",
                      "subject_id" : message.subjectId ?? "unknown",
                      "type_of_subject": message.typeOfSubject?.rawValue ?? "unknown",
                      "year": message.year ?? 0,
                      "month": message.month ?? 0,
                      "day": message.day ?? 0,
                      "hour": message.hour ?? 0,
                      "minute": message.minute ?? 0,
                      "second": message.second ?? 0,
                      "text" : message.text ?? "unknown"]
        
        fireDataBase.editObjectWithId(object: message, stringValues: values)
        
    }
    
    func readMessages(userId: String, productId: String, complition: @escaping ([Message]) -> Void) {
        fireDataBase.recieveData(path: "messages/", key: "subject_id", value: productId) { [weak self, userId, complition] dict, error in
            guard error == nil else { self?.errorMessage.value = error!.localizedDescription; return }
            
            var arrayOfMessages: [Message] = []
            for (_, value) in dict {
                if let object = try? JSONDecoder().decode(Message.self, from: value) {
                    if object.authorId == userId || object.recieverId == userId {
                        object.setDateComponents()
                        arrayOfMessages.append(object)
                    }
                }
            }
            complition( arrayOfMessages.sorted { lhs, rhs in
                lhs.date ?? Date() < rhs.date ?? Date ()
            } )
        }
    }
    
}

protocol MessageServiceProtocol {
    
    var fireDataBase: FireDataBase { get set }
    
    func writeMessage(message: inout MessageProtocol)
    
}
