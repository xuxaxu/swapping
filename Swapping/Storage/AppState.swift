import Foundation

class AppState {
    
    init() {
        bindAuthService()
        bindCategoriesService()
    }
    
    var stateUser = StateUser()
    var stateProduct = StateProduct()
    var stateCategories = StateCategories(main: [])
    var stateMessages = StateMessage()
    
    private func bindAuthService() {
        // userId change from AuthenticationService
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userIdChanged(_:)),
            name: .AuthenticationSucceed,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authenticationFailed(_:)),
            name: .AuthenticationFailed,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(productsChanged(_:)),
            name: .ArrayOfObjectsChanged,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoryForFilterProductListChanged(_:)),
            name: .CategoryNameForFilterProductListChangedByUser,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(filterStringForProductListChanged(_:)),
            name: .FilterStringForProductListChanged,
            object: nil)
    }
    
    @objc private func filterStringForProductListChanged(_ notification: Notification) {
        guard let filterString = notification.object as? String else {
            return
        }
        stateProduct.setFilterStr(filterString)
    }
    
    @objc private func categoryForFilterProductListChanged(_ notification: Notification) {
        guard let nameOfCategory = notification.object as? String else {
            return
        }
        stateProduct.setFilterCategoryName(nameOfCategory)
    }
    
    @objc private func userIdChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let newId = userInfo[GlobalConstants.userIdUserInfo] as? String else {
            return }
        setStateUserId(newId)
    }
    
    @objc private func authenticationFailed(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let authenticated = userInfo[GlobalConstants.authenticatedUserInfo] as? Bool else {
            return }
        if !authenticated {
            setStateUserId(nil)
        }
    }
    
    @objc private func productsChanged(_ notification: Notification) {
        guard let dataService = notification.object as? DataService<Product> else {
            return
        }
        
        stateProduct.setProducts(dataService.arrayOfObjects.value)
        
        NotificationCenter.default.post(name: .ProductsChanged,
                                        object: self)
    }
    
    private func bindCategoriesService() {
        // tree of categories changes in CategoriesService
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(treeChanges(_:)),
            name: .CategoryTreeUpdated,
            object: nil
        )
    }
    
    @objc private func treeChanges(_ notification: Notification) {
        guard let categoriesService = notification.object as? CategoriesService else {
            return
        }
        stateCategories.main = categoriesService.allCategories
        stateCategories.categoriesNames = categoriesService.namesDict
        NotificationCenter.default.post(name: .SomeChangesInCategories,
                                        object: self)
    }
    
    func getStateProducts() -> [Product] {
        let state = stateProduct
        let products = state.products
        return products
    }
    func setStateProductFilteredProducts(_ products: [Product]) {
        stateProduct.setFilteredProducts(products)
        NotificationCenter.default.post(name: .FilteredProductsChanged,
                                        object: self)
    }
    func getStateProductFilteresProducts() -> [Product] {
        let products = stateProduct.filteredProducts
        return products
    }
    func setStateProductFilterCategoriesNames(_ names: [String]) {
        stateProduct.setFilterCategoriesNames(names)
    }
    func getStateProductFilterCategoriesNames() -> [String]? {
        let names = stateProduct.filterCategoryWithChildrenNames
        return names
    }
    func getStateProductFilterStr() -> String? {
        let str = stateProduct.filterStr
        return str
    }
    func setImageToProduct(_ product: Product) {
        stateProduct.setImage(product)
        NotificationCenter.default.post(name: .ProductChanged,
                                        object: product)
    }
    func setStateSelectedProduct(_ product: Product) {
        stateProduct.setProduct(product)
    }
    func setStateUserId(_ id: String?) {
        stateUser.setUserId(id)
    }
    func getStateUserId() -> String? {
        let id = stateUser.userID
        return id
    }
    func setStateCategoriesRoot(_ root: [CategoryTree]) {
        stateCategories.main = root
    }
    func getStateCategoriesRoot() -> [CategoryTree] {
        let root = stateCategories.main
        return root
    }
    func setStateCategoriesNamesDict(_ names: [String: String]) {
        stateCategories.categoriesNames = names
    }
    func getStateCategoriesNamesDict() -> [String: String] {
        let names = stateCategories.categoriesNames
        return names
    }
    func setStateCategoriesParent(_ node: CategoryTree) {
        stateCategories.currentParent = node
        NotificationCenter.default.post(name: .ParentCategoryChanged,
                                        object: node)
    }
    func getMessages(for productId: String) -> [Message] {
        stateMessages.getMessages(for: productId)
    }
    func setMessages(_ messages: [Message], for productId: String) {
        stateMessages.setMessages(messages, for: productId)
        NotificationCenter.default.post(name: .MessagesChanged,
                                        object: (productId, messages))
    }
    func messagesCount(for productId: String) -> Int {
        guard let messages = stateMessages.messages[productId] else {
            return 0
        }
        return messages.count
    }
    func message(for productId: String, at index: Int) -> Message {
        guard let messages = stateMessages.messages[productId] else {
            return Message()
        }
        return messages[index]
    }
}

extension Notification.Name {
   static let CategoryNameForFilterProductListChangedByUser = Notification.Name(
        rawValue: "com.Swapping.ProductList.UserChooseCategoryForFilterProductList")
    static let FilterStringForProductListChanged = Notification.Name(
        rawValue: "com.Swapping.ProductList.UserEnterFilterString")
    static let ProductChanged = Notification.Name(
        rawValue: "com.Swapping.AppState.ProductState.ProductHasChangedInListsInStateProducts")
    static let MessagesChanged = Notification.Name(
        rawValue: "com.Swapping.StateMessage.MessagesChanged")
}
