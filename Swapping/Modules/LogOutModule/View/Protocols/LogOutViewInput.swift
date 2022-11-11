protocol LogOutViewInput: AnyObject {
    func finish()
    func showAlert(_ message: String)
    func dismiss()
}
