protocol AuthViewOutput {
    func signIn(login: String, password: String)
    func signUp(name: String, login: String, password: String)
    func saveCredentialsTap()
    func loginEditingEnd(_ login: String?)
    func forgotPassword(login: String)
}
