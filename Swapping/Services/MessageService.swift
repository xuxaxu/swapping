import Foundation

class MessageService: MessageServiceProtocol {
    
    private var fireDataBase: FireDataBase
    private var container: IContainer
    
    private var currentUserId: String
    
    var errorMessage = Dynamic("")
    
    init(userId: String, container: IContainer) {
        self.currentUserId = userId
        self.container = container
        fireDataBase = FireDataBase(container: container, args:())
        subscribe()
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gotRequestForMessageToProductOwner(_:)),
            name: .AskForMessageToProductOwner,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gotRequestForReadingAllProductMessages(_:)),
            name: .RequestForAllProductMessages,
            object: nil)
    }
    
    @objc private func gotRequestForReadingAllProductMessages(
        _ notification: Notification) {
            guard let productId = notification.object as? String else {
                return
            }
            readMessages(productId: productId) { [weak self] messages in
                self?.container.appState.setMessages(messages, for: productId)
            }
    }
    
    @objc private func gotRequestForMessageToProductOwner(
        _ notification: Notification) {
            guard let (product, message) = notification.object as? (Product, String) else {
                return
            }
            writeMessage(message: message, product: product)
    }
    
    func writeMessage(message: String, product: Product) {
        let message = Message(authorId: currentUserId,
                              subject: product,
                              message: message)
        
        writeMessage(message: message)
    }
    
    private func writeMessage(message: MessageProtocol) {
        var messageForSending = message
        messageForSending.id = fireDataBase.createObject(object: message)
        
        let subjectId = messageForSending.subjectId ?? GlobalConstants.plugString
        
        let values: [String : Any] = ["author_id" : messageForSending.authorId ?? "unknown",
                      "reciever_id" : messageForSending.recieverId ?? "unknown",
                      "subject_id" : subjectId,
                      "type_of_subject": messageForSending.typeOfSubject?.rawValue ?? "unknown",
                      "year": messageForSending.year ?? 0,
                      "month": messageForSending.month ?? 0,
                      "day": messageForSending.day ?? 0,
                      "hour": messageForSending.hour ?? 0,
                      "minute": messageForSending.minute ?? 0,
                      "second": messageForSending.second ?? 0,
                      "text" : messageForSending.text ?? "unknown"]
        
        fireDataBase.editObjectWithId(object: messageForSending, stringValues: values) { [weak self] in
            self?.readMessages(productId: subjectId) { [weak self] messages in
                self?.container.appState.setMessages(messages, for: subjectId)
            }
        }
    }
    
    func readMessages(productId: String, completion: @escaping ([Message]) -> Void) {
        fireDataBase.recieveData(path: "messages/", key: "subject_id", value: productId) { [weak self, completion] dict, error in
            guard error == nil else { self?.errorMessage.value = error!.localizedDescription; return }
            guard let strongSelf = self else { return }
            var arrayOfMessages: [Message] = []
            for (_, value) in dict {
                if let object = try? JSONDecoder().decode(Message.self, from: value) {
                    if object.authorId == strongSelf.currentUserId || object.recieverId == strongSelf.currentUserId {
                        object.setDateComponents()
                        arrayOfMessages.append(object)
                    }
                }
            }
            completion( arrayOfMessages.sorted { lhs, rhs in
                lhs.date ?? Date() > rhs.date ?? Date ()
            } )
        }
    }
    
}

protocol MessageServiceProtocol {
    
    func writeMessage(message: String, product: Product)
    func readMessages(productId: String, completion: @escaping ([Message]) -> Void)
}

extension Notification.Name {
    static let AskForMessageToProductOwner = Notification.Name(
        rawValue: "com.Swapping.MessageService.RequesForMessageToProductOwner")
    static let RequestForAllProductMessages = Notification.Name(
        rawValue: "com.Swapping.MessagesService.RequestForReadindAllMessagesConnectedWithProduct")
}
