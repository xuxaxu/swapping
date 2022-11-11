protocol ProductViewOutput {
    func writeToOwner(message: String)
    func labelForAuthor(message: Message) -> String
    func fillInformation()
    var editable: Bool { get }
    func editBtnTap()
    func messagesCount() -> Int
    func getMessage(index: Int) -> Message
}
