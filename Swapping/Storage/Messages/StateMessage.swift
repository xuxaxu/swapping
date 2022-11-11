struct StateMessage {
    var messages: [String: [Message]] = [:]
    
    mutating func setMessages(_ messages: [Message], for productId: String) {
        self.messages[productId] = messages
    }
    func getMessages(for productId: String) -> [Message] {
        guard let productMessages = messages[productId] else {
            return []
        }
        return productMessages
    }
    mutating func addMessage(_ message: Message, for productId: String) {
        if messages[productId] == nil {
            messages[productId] = []
        }
        messages[productId]!.append(message)
    }
}
