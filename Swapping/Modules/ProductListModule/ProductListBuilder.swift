class ProductListBuilder {
    private let presenter: ProductListPresenter
    public let viewController: ProductListViewController
    
    init(coordinator: CoordinatorProtocol, container: IContainer) {
        presenter = ProductListPresenter(container: container)
        viewController = .instantiate()
        viewController.coordinator = coordinator
        viewController.output = presenter
        presenter.view = viewController
    }
}
