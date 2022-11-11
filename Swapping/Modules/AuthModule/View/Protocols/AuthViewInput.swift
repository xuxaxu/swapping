protocol AuthViewInput: AnyObject {
    func fillPassword(_ password: String)
    func showAlert(_ message: String)
    func setSaveCredentials(_ value: Bool)
    func finish() 
}
