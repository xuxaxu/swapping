import Foundation

protocol CheckUserService {
    func isItCurrentUser(id: String) -> Bool
}

class CheckUserFromStateService: CheckUserService {
    
    private let container: IContainer
    
    init(container: IContainer) {
        self.container = container
    }
    
    func isItCurrentUser(id: String) -> Bool {
        let currentUserId = container.appState.getStateUserId()
        return currentUserId == id
    }
}
