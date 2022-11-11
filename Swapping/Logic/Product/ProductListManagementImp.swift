import Foundation

class ProductListManagementImp: ProductListManagement {
    private let categoriesService: CategoriesService
    private let container: IContainer
    
    init(container: IContainer,
         categoriesService: CategoriesService) {
        self.container = container
        self.categoriesService = categoriesService
        subscribe()
    }
    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoryFilterChanged(_:)),
            name: .CategoryNameForFilterProductListChangedByUser,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(filterStringChanged(_:)),
            name: .FilterStringForProductListChanged,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(productsChanged(_:)),
            name: .ProductsChanged,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imageLoadedForObject(_:)),
            name: .ImageLoadedForObject,
            object: nil)
    }
    
    @objc private func imageLoadedForObject(_ notification: Notification) {
        guard let productWithImage = notification.object as? Product else {
            return
        }
        container.appState.setImageToProduct(productWithImage)
    }
    
    @objc private func productsChanged(_ notification: Notification) {
        resetFilteredProducts()
    }
    
    private func resetFilteredProducts() {
        filterForCategory()
        let filterStr = container.appState.getStateProductFilterStr()
        guard let filterStr = filterStr,
        filterStr != "" else {
            return
        }
        filterForStr(filterStr)
    }
    
    @objc private func categoryFilterChanged(_ notification: Notification) {
        guard let categoryName = notification.object as? String else {
            return
        }
        guard categoryName != "" else {
            clearCategoryFilter()
            return
        }
        guard let categoryId = categoriesService.getCategoryId(
            name: categoryName) else {
            clearCategoryFilter()
            return
        }
        let categories = categoriesService.getAllCategoriesNamesInBranch(
            parentId: categoryId)
        
        container.appState.setStateProductFilterCategoriesNames(categories)
        filterForCategory()
    }
                                                                        
    private func filterForCategory() {
        let products = container.appState.getStateProducts()
        guard let filterCategoryNames = container.appState.getStateProductFilterCategoriesNames() else {
            container.appState.setStateProductFilteredProducts(products)
            return
        }
        let filteredProducts = products.filter{
            filterCategoryNames.contains( $0.category ?? "unknown") }
        container.appState.setStateProductFilteredProducts(filteredProducts)
    }
    
    private func clearCategoryFilter() {
        let state = container.appState
        state.setStateProductFilterCategoriesNames([])
        let products = state.getStateProducts()
        state.setStateProductFilteredProducts(products)
    }
    
    @objc private func filterStringChanged(_ notification: Notification) {
        guard let filterStr = notification.object as? String else {
            return
        }
        filterForStr(filterStr)
    }
    private func filterForStr(_ filterStr: String) {
        let state = container.appState
        let filterCategoriesNames = state.getStateProductFilterCategoriesNames()
        let allCategoriesNames = state.getStateCategoriesNamesDict()
        let categoriesNames = filterCategoriesNames ?? Array(allCategoriesNames.keys)
        let categoriesFiltered = categoriesNames.filter{ $0.contains(filterStr) }
        var filteredProducts = state.getStateProductFilteresProducts()
        filteredProducts = filteredProducts.filter({ product in
            return product.name?.contains(filterStr) ?? false || categoriesFiltered.contains(product.category ?? "unknown")
        })
        state.setStateProductFilteredProducts(filteredProducts)
    }
}
