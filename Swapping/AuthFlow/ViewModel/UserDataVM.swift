//
//  UserDataVM.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 27.05.22.
//

import Foundation

class UserDataVM : IPerRequest {
    
    typealias Arguments = ()
    
    required init(container: IContainer, args: ()) {
        dataService =  container.resolve(args: UserData.self)
        bindDataService()
    }
    
    var dataService: DataService<UserData>
    
    var userName = Dynamic("")
    
    var errorMessage = Dynamic("")
    
    func bindDataService() {
        dataService.errorMessage.bind { [weak self] message in
            self?.errorMessage.value = message
        }
    }
    
    func getUserName(uid: String) {
        dataService.getElement(path: "usersData/" + uid + "/") { [weak self] userData in
            if let name = userData.name {
                self?.userName.value = name
            }
        }
    }
    
}
