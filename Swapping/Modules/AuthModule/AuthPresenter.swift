import Foundation

class AuthPresenter {
    public var output: AuthModuleOutput?
    
    public weak var view: AuthViewInput? 
    
    private let storageService: SettingsPersistance
    private let authService: AuthenticationService
    
    private var saveCredentials: Bool {
        didSet {
            if view != nil {
                view!.setSaveCredentials(saveCredentials)
            }
        }
    }
    
    init(settingsPersistanceService: SettingsPersistance, authService: AuthenticationService, output: AuthModuleOutput? = nil) {
        self.storageService = settingsPersistanceService
        self.authService = authService
        self.output = output
        saveCredentials = storageService.lastChooseForCredentials()
        tryAuthenticateWithSavesCredentials()
    }
    
    private func tryAuthenticateWithSavesCredentials() {
        do {
            try authService.logOut()
        } catch {
        }
        
        if let credentials = storageService.getCredentials() {
            signIn(login: credentials.0,
                   password: credentials.1)
        }
    }
}

extension AuthPresenter: AuthModuleInput {}

extension AuthPresenter: AuthViewOutput {
    
    func signIn(login: String, password: String) {
        authService.signIn(login: login, password: password) { [weak self] result in
            switch result {
            case .success(let (login, password)):
                if let save = self?.saveCredentials, save == true {
                    self?.storageService.saveCredentials(login: login, password: password)
                }
                self?.view?.finish()
            case .failure(let error):
                self?.view?.showAlert(error.localizedDescription)
                self?.storageService.clearLastCredentials()
            }
        }
    }
    
    func signUp(name: String, login: String, password: String) {
        authService.signUp(name: name, login: login, password: password) { [weak self] result in
            switch result {
            case .success(let (login, password)):
                if let save = self?.saveCredentials, save == true {
                    self?.storageService.saveCredentials(login: login, password: password)
                }
                self?.view?.finish()
            case .failure(let error):
                self?.view?.showAlert(error.localizedDescription)
            }
        }
    }
    
    func saveCredentialsTap() {
        saveCredentials = !saveCredentials
        storageService.saveChooseForCredentials(save: saveCredentials)
    }
    
    func loginEditingEnd(_ login: String?) {
        if let login = login, let password = storageService.getSavedPassword(login: login) {
            view?.fillPassword(password)
        }
    }
    
    func forgotPassword(login: String) {
        authService.resetPassword(login: login) { [weak self] message in
            self?.view?.showAlert(message)
        }
    }
}
