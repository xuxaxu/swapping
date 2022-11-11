import Foundation
import FirebaseAuth

protocol AuthenticationService {
    func signIn(login: String, password: String, completion: @escaping (Result<(String, String),Error>) -> Void )
    func signUp(name: String, login: String, password: String, completion: @escaping (Result<(String, String), Error>) -> Void)
    func logOut() throws
    func resetPassword(login: String, completion: @escaping (String) -> Void)
    func getUserUid() -> String? 
}

final class AuthenticationImp: AuthenticationService {
    
    private let dataService: DataService<UserData>
    
    init(dataService: DataService<UserData>) {
        self.dataService = dataService
        let _ = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.authStateDidChanged(auth: auth, user: user)
        }
    }
    
    private func authStateDidChanged(auth: Auth, user: User?) {
        if let user = user {
            NotificationCenter.default.post(name: .AuthenticationSucceed, object: self, userInfo: [GlobalConstants.userIdUserInfo: user.uid])
        } else {
            NotificationCenter.default.post(name: .AuthenticationFailed, object: self, userInfo: [GlobalConstants.authenticatedUserInfo: false])
        }
    }
    
    func signIn(login: String, password: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        Auth.auth().signIn(withEmail: login, password: password) { [login, password, completion] authResult, error in
            guard let error = error else {
                completion(.success((login, password)))
                return
            }
            completion(.failure(error))
        }
    }
    
    func signUp(name: String, login: String, password: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        Auth.auth().createUser(withEmail: login, password: password) { [weak self] authResult, error in
            if error != nil {
                completion(.failure(error!))
            }
            if authResult != nil {
                
                let changeRequest = authResult!.user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    if error != nil {
                        completion(.failure(error!))
                    }
                }
                
                let newUser = UserData(uid: authResult!.user.uid,
                                       name: name,
                                       image: nil)
                self?.dataService.editObject(object: newUser, newName: name, completion: {})
                
                completion(.success((login, password)))
            }
            
        }
    }
    
    func logOut() throws {
        try Auth.auth().signOut()
    }
    
    func resetPassword(login: String, completion: @escaping (String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: login) { [completion] error in
            if error == nil {
                completion("letter send")
            } else {
                completion(error!.localizedDescription)
            }
        }
    }
    
    func getUserUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
}

enum Providers {
    case mail
    case appleId
    case phone
    case login
}

extension Notification.Name {
    static let AuthenticationSucceed = Notification.Name(rawValue: "com.Swapping.authenticationSucceed")
    static let AuthenticationFailed = Notification.Name(rawValue: "com.Swapping.authenticationFailed")
}


