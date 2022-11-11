import Foundation

final class LogOutBuilder {
    private let presenter: LogOutPresenter
    public let viewController: LogoutVC

    // MARK: - Init

    init(dataService: DataService<UserData>) {
        let settingStorageService = UserDefaultsPersistance()
        let authService = AuthenticationImp(dataService: dataService)
        presenter = LogOutPresenter(authService: authService)
        viewController = .instantiate()
        viewController.output = presenter
        presenter.view = viewController
    }
}
