import Foundation

final class LogOutPresenter {
    private let authService: AuthenticationService
    public weak var view: LogOutViewInput?
    
    init(authService: AuthenticationService) {
        self.authService = authService
    }
}

extension LogOutPresenter: LogOutViewOutput {
    func logOut() {
        do {
            try authService.logOut()
            view?.finish()
        } catch {
            view?.showAlert(error.localizedDescription)
        }
    }
}
