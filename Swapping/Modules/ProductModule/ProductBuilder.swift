class ProductBuilder {
    private let presenter: ProductPresenter
    public let viewController: ProductViewController
    
    init(coordinator: CoordinatorProtocol,
         container: IContainer,
         categoryService: CategoriesService,
         checkUserService: CheckUserService) {
        guard let product = container.appState.stateProduct.product else {
            fatalError()
        }
        self.presenter = ProductPresenter(container: container,
                                          product: product,
                                          categoryService: categoryService,
                                          checkUserService: checkUserService)
        self.viewController = .instantiate()
        viewController.output = presenter
        viewController.coordinator = coordinator
        presenter.view = viewController
    }
}
