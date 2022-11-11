import Foundation

class ProductPresenter {
    public weak var view: ProductViewInput?
    
    private var product: Product
    private let container: IContainer
    private let categoryService: CategoriesService
    
    internal let editable: Bool
    
    init(container: IContainer,
         product: Product,
         categoryService: CategoriesService,
         checkUserService: CheckUserService) {
        self.product = product
        self.container = container
        self.categoryService = categoryService
        let isProductEditable = checkUserService.isItCurrentUser(
            id: product.owner ?? "unknown")
        self.editable = isProductEditable
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(messagesChanged(_:)),
            name: .MessagesChanged,
            object: nil)
    }
    
    @objc private func messagesChanged(_ notification: Notification) {
        guard let (productId, messages) = notification.object as? (String, [Message]),
            productId == product.id else {
            return
        }
        view?.showMessages(messages)
    }
}

extension ProductPresenter: ProductViewOutput {
    func messagesCount() -> Int {
        guard let id = product.id else {
            return 0
        }
        return container.appState.messagesCount(for: id)
    }
    
    func getMessage(index: Int) -> Message {
        guard let id = product.id else {
            return Message()
        }
        return container.appState.message(for: id, at: index)
    }
    
    func editBtnTap() {
        view?.goToEditModule(product: product)
    }
    
    func writeToOwner(message: String) {
        NotificationCenter.default.post(name: .AskForMessageToProductOwner,
                                        object: (product, message))
    }
    
    func labelForAuthor(message: Message) -> String {
        if message.authorId != product.owner {
            return "You"
        } else {
            return "Owner"
        }
    }
    
    private func getMessages() {
        if let productId = product.id {
            NotificationCenter.default.post(name: .RequestForAllProductMessages,
                                            object: productId)
        }
    }
    
    private func getParentCategory() {
        guard let category = product.category else {
            return
        }
        categoryService.getPathToCategory(name: category) { [weak self] categoryPath in
            self?.view?.showCategory(categoryPath)
        }
    }
    
    private func getOwnerName() {
        guard let ownerId = product.owner else {
            return
        }
        let userService = UserDataVM(container: container, args: ())
        userService.getUserName(for: ownerId) { [weak self] owner in
            self?.view?.showOwnerName(owner)
        }
    }
    func fillInformation() {
        view?.fillProductName(with: product.name ?? GlobalConstants.plugString)
        view?.fillDescription(with: product.productDescription)
        if let image = product.image {
            view?.fillImage(with: image)
        }
        getParentCategory()
        getOwnerName()
        getMessages()
    }
}
