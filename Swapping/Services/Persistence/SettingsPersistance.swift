import Foundation
import KeychainAccess

protocol SettingsPersistance {
    func getCredentials() -> (String, String)?
    func saveCredentials(login: String, password: String)
    func clearLastCredentials()
    func saveChooseForCredentials(save: Bool)
    func lastChooseForCredentials() -> Bool
    func getSavedPassword(login: String) -> String?
}

final class UserDefaultsPersistance: SettingsPersistance {
    
    func saveCredentials(login: String, password: String) {
        
        let keychain = Keychain(service: "Swapping")
        keychain[login] = password
        
        UserDefaults.standard.set(login, forKey: "last authorized login")
    }
    
    func clearLastCredentials() {
        UserDefaults.standard.set(nil, forKey: "last authorized login")
    }
    
    func getCredentials() -> (String, String)? {
        
        if lastChooseForCredentials(), let login = UserDefaults.standard.string(forKey: "last authorized login") {
            let keychain = Keychain(service: "Swapping")
            if let password = keychain[login] {
                return (login, password)
            }
        }
        return nil
    }
    
    func saveChooseForCredentials(save: Bool) {
        UserDefaults.standard.set(save, forKey: "save credential choose")
        UserDefaults.standard.set(true, forKey: "setting for credentials set")
    }
    
    func lastChooseForCredentials() -> Bool {
        if UserDefaults.standard.bool(forKey: "setting for credentials set") {
            return UserDefaults.standard.bool(forKey: "save credential choose")
        } else {
            return true
        }
    }
    
    func getSavedPassword(login: String) -> String? {
        let keychain = Keychain(service: "Swapping")
        if let password = keychain[login] {
            return password
        }
        return nil
    }
}
