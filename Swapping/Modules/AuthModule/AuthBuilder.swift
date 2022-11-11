import Foundation

final class AuthBuilder {
    private let presenter: AuthPresenter
    public let viewController: AuthViewController
    public var output: AuthModuleOutput? {
        presenter.output
    }

    public var input: AuthModuleInput {
        presenter
    }

    // MARK: - Init

    init(dataService: DataService<UserData>, coordinator: MainCoordinatorProtocol, output: AuthModuleOutput? = nil) {
        let settingStorageService = UserDefaultsPersistance()
        let authService = AuthenticationImp(dataService: dataService)
        presenter = AuthPresenter(settingsPersistanceService: settingStorageService,
                                  authService: authService,
                                  output: output)
        viewController = .instantiate()
        viewController.coordinator = coordinator
        viewController.output = presenter
        presenter.view = viewController
    }
}
