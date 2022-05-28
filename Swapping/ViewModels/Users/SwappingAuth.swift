//
//  SwappingAuth.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 18.04.22.
//

import Foundation

import Firebase
import FirebaseAuth
import FirebaseAuthUI
import FirebaseOAuthUI
import FirebaseEmailAuthUI
import KeychainAccess

class SwappingAuth: NSObject, FUIAuthDelegate, ISingleton {
    
    required init(container: IContainer, args: ()) {
        
        dataService = container.resolve(args: UserData.self)

        super.init()
        
        let _ = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.authStateDidChanged(auth: auth, user: user)
        }
    }
    
    var authenticated = Dynamic(false)
    
    var errorMessage = Dynamic("")
    
    private var dataService: DataService<UserData>
    
    func checkSavedCredentials() {
        do {
            try Auth.auth().signOut() //firebase save succeed authentication automaticaly
        } catch {}
        
        if let credentials = getLastEntryCredentials() {
            authenticate(login: credentials.login,
                         password: credentials.password,
                         save: false,
                         provider: credentials.provider)
        }
    }
    
    private func saveCredentials(login: String, password: String, provider: Providers = .mail) {
        
        let keychain = Keychain(service: "Swapping")
        keychain[login] = password
        
        UserDefaults.standard.set(login, forKey: "last authorized login")
    }
    
    private func getLastEntryCredentials()-> (login: String, password: String, provider: Providers)? {
        
        if lastChooseForCredentials(), let login = UserDefaults.standard.string(forKey: "last authorized login") {
            let keychain = Keychain(service: "Swapping")
            if let password = keychain[login] {
                return (login, password, .mail)
            }
        }
        return nil
    }
    
    func saveChooseForCredentials(save: Bool) {
        UserDefaults.standard.set(save, forKey: "save credential choose")
        UserDefaults.standard.set(true, forKey: "setting for credentials set")
    }
    
    func lastChooseForCredentials()->Bool {
        if UserDefaults.standard.bool(forKey: "setting for credentials set") {
            return UserDefaults.standard.bool(forKey: "save credential choose")
        } else {
            return true
        }
    }
    
    func authenticate(login: String, password: String, save: Bool, provider: Providers = .mail) {
        
        Auth.auth().signIn(withEmail: login, password: password) { [weak self, password, login, save] authResult, error in
          guard let strongSelf = self, error == nil  else {
              UserDefaults.standard.set(nil, forKey: "last authorized login")
              self?.errorMessage.value = error?.localizedDescription ?? "error signing in"
              return
          }
            if save {
                strongSelf.saveCredentials(login: login, password: password)
            }
        }
        
    }
    
    private func authStateDidChanged(auth: Auth, user: User?) {
        if let _ = user {
            authenticated.value = true
        } else {
            authenticated.value = false
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            errorMessage.value = "error with logging out"
        }
    }
    
    func signUp(login: String, password: String, name: String, save: Bool) {
        Auth.auth().createUser(withEmail: login, password: password) { [weak self, login, password] authResult, error in
            if error != nil {
                self?.errorMessage.value = error!.localizedDescription
            }
            if authResult != nil {
                
                let changeRequest = authResult!.user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { [weak self] error in
                    if error != nil {
                        self?.errorMessage.value = error!.localizedDescription
                    }
                }
                
                let newUser = UserData(uid: authResult!.user.uid,
                                       name: name,
                                       image: nil)
                self?.dataService.editObject(object: newUser, newName: name)
                
                if save {
                    self?.saveCredentials(login: login, password: password)
                }
            }
            
        }
    }
    
    func forgotPassword(login: String) {
        Auth.auth().sendPasswordReset(withEmail: login) { [weak self] error in
            if error == nil {
                self?.errorMessage.value = "letter send"
            } else {
                self?.errorMessage.value = error!.localizedDescription
            }
        }
    }
    
    //if use firebase authUI
    func signInSwap(in vc : UIViewController & FUIAuthDelegate) {
            if let authUI = FUIAuth.defaultAuthUI() {
                authUI.delegate = self
            
                authUI.providers = [FUIEmailAuth(), FUIOAuth.appleAuthProvider()]
    
                let authVC = authUI.authViewController()
                authVC.modalPresentationStyle = .fullScreen
                
                vc.present(authVC, animated: true)
            }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            self.errorMessage.value = error.localizedDescription
        } else {
            if let _ = authDataResult {
               //   can't save user password if use authUI
                self.authenticated.value = true
            } else {
                self.authenticated.value = false
            }
        }
    }
    
    func getUserUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    enum Providers {
        case mail
        case appleId
        case phone
        case login
    }
    
}
