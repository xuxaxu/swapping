//
//  ProductVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 26.05.22.
//

import Foundation

class ProductVM {
    
    typealias Arguments = Product
    
    required init(container: IContainer, args: Product, messageService: MessageServiceProtocol) {
        self.product = args
        
        userService = container.resolve(args: ())
        
        dataService = container.resolve(args: Category.self)
        
        self.messageService = messageService
        
        bind()
    }
    
    var product: Product
    
    private var userService: UserDataVM
    
    var errorMessage = Dynamic("")
    
    var ownerName = Dynamic("")
    
    var parentCategory = Dynamic("")
    
    var currentUserIsOwner = Dynamic(false)
    
    private var dataService: DataService<Category>
    
    private var messageService: MessageServiceProtocol
    
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
        messageService.writeMessage(message: message, product: product)
    }
    
    func labelForAuthor(message: Message) -> String {
        if message.authorId != product.owner {
            return "You"
        } else {
            return "Owner"
        }
    }
    
    func getMessages() {
        if let productId = product.id {
            messageService.readMessages(productId: productId) { [weak self] messagesFromDB in
                self?.messages = messagesFromDB
                self?.messagesUpdated.value = true
            }
        }
    }
    
}
