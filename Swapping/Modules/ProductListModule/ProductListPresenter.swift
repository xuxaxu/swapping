import Foundation

class ProductListPresenter {
    public weak var view: ProductListViewInput?
    private var container: IContainer
    
    init(container: IContainer) {
        self.container = container
        subscribe()
        requestProducts()
    }
    
    private func requestProducts() {
        NotificationCenter.default.post(name: .RequestForRecievingProducts,
                                        object: nil)
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imageLoadedForObject(_:)),
            name: .ProductChanged,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData(_:)),
            name: .FilteredProductsChanged,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoriesUpdared(_:)),
            name: .CategoryTreeUpdated,
            object: nil)
    }
    
    @objc private func categoriesUpdared(_ notification: Notification) {
        let menu = getMenuItems()
        view?.fillFilterMenu(menu)
    }
    
    private func getMenuItems() -> [String] {
        var menu = [Constants.menuAllCategories]
        let currentCategoriesState = container.appState.getStateCategoriesRoot()
        for node in currentCategoriesState {
            if let name = node.category.name {
                menu.append(name)
            }
        }
        return menu
    }
    
    @objc private func reloadData(_ notification: Notification) {
        view?.refreshData()
    }
    
    @objc private func imageLoadedForObject(_ notification: Notification) {
        guard let object = notification.object as? Product else {
            return
        }
        let filteredProducts = container.appState.getStateProductFilteresProducts()
        guard let index = filteredProducts.firstIndex(of: object) else {
            return
        }
        view?.refreshPieceOfData(inx: index)
    }
}

extension ProductListPresenter: ProductListViewOutput {
    var menuBtnTitle: String {
        Constants.menuAllCategories
    }
    
    var menuTitle: String {
        Constants.menuTitle
    }
    
    func categoryMenuSelected(_ menuTitle: String) {
        var filterCategoryName = ""
        if menuTitle != Constants.menuAllCategories {
            filterCategoryName = menuTitle
        }
        filterCategoryChanged(filterCategoryName)
    }
    
    func askForRefreshingList() {
        requestProducts()
    }
    
    func productsCount() -> Int {
        let filteredProducts = container.appState.getStateProductFilteresProducts()
        return filteredProducts.count
    }
    
    func productForIndex(_ index: Int) -> Product? {
        let filteredProducts = container.appState.getStateProductFilteresProducts()
        guard index < filteredProducts.count else {
            return nil
        }
        let product = filteredProducts[index]
        return product
    }
    
    func itemSelected(_ index: Int) {
        let filteredProducts = container.appState.getStateProductFilteresProducts()
        if index < filteredProducts.count {
            let product = filteredProducts[index]
            view?.openProductDialog(product)
        }
    }
    
    func filterStringChanged(_ filter: String) {
        NotificationCenter.default.post(name: .FilterStringForProductListChanged,
                                        object: filter)
    }
    private func filterCategoryChanged(_ categoryName: String) {
        NotificationCenter.default.post(
            name: .CategoryNameForFilterProductListChangedByUser,
            object: categoryName)
    }
}

extension Notification.Name {
    static let RequestForRecievingProducts = Notification.Name(
        rawValue: "com.Swapping.ProductListPresenter.RequestForRecievingProducts")
}

extension ProductListPresenter {
    struct Constants {
        static let menuTitle = "categories"
        static let menuAllCategories = "All"
    }
}
