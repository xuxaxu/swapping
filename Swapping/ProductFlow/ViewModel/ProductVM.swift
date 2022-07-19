//
//  ProductVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 26.05.22.
//

import Foundation

class ProductVM: IPerRequest {
    
    typealias Arguments = Product
    
    required init(container: IContainer, args: Product) {
        self.product = args
        
        userService = container.resolve(args: ())
        
        dataService = container.resolve(args: Category.self)
        
        authService = container.resolve(args: ())
        
        messageService = container.resolve(args: ())
        
        bind()
    }
    
    var product: Product
    
    private var userService: UserDataVM
    
    var errorMessage = Dynamic("")
    
    var ownerName = Dynamic("")
    
    var parentCategory = Dynamic("")
    
    var currentUserIsOwner = Dynamic(false)
    
    private var dataService: DataService<Category>
    
    private var authService: SwappingAuth
    
    private var messageService: MessageService
    
    var messages: [Message] = []
    
    var messagesUpdated = Dynamic(false)
    
    func bind() {
        userService.userName.bind { [weak self] name in
            self?.ownerName.value = name
        }
        
        userService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
        
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
        
    }
    
    func getNameOfOwner() {
        if let uid = product.owner {
            userService.getUserName(uid: uid)
            checkCurrentUserIsOwner()
        }
    }
    
    private func checkCurrentUserIsOwner() {
        if let uid = product.owner, let currentUid = authService.getUserUid() {
            self.currentUserIsOwner.value = (uid == currentUid)
        }
    }
    
    func getParentCategory() {
        if let category = product.category {
            parentCategory.value = ""
            dataService.getElement(path: "categories/" + category) { [weak self] firstCategory in
                self?.composePathCategory(model: self, category: firstCategory)
            }
        }
    }
    
    private func composePathCategory(model: ProductVM?, category: Category?) {
        if let existSelf = model, let existCategory = category, let name = existCategory.name {
            
            if existSelf.parentCategory.value == "" {
                existSelf.parentCategory.value = name
            } else {
                existSelf.parentCategory.value = name + "/" + existSelf.parentCategory.value
            }
            
            if let parent = existCategory.parentId, parent != "" {
                dataService.getElement(path: "categories/" + parent) { [weak self] category in
                    self?.composePathCategory(model: self, category: category)
                }
            }
        }
    }
    
    func writeToOwner(message: String) {
        if let currentUid = authService.getUserUid() {
            var message: MessageProtocol = Message(authorId: currentUid, subject: product, message: message)
            messageService.writeMessage(message: &message)
        }
    }
    
    func labelForAuthor(message: Message) -> String {
        if message.authorId == authService.getUserUid() {
            return "You"
        } else {
            return "Owner"
        }
    }
    
    func getMessages() {
        if let userId = authService.getUserUid(), let productId = product.id {
            messageService.readMessages(userId: userId, productId: productId) { [weak self] messagesFromDB in
                self?.messages = messagesFromDB
                self?.messagesUpdated.value = true
            }
        }
    }
    
}
