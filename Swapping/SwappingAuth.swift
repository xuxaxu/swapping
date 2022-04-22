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

class SwappingAuth: NSObject, FUIAuthDelegate {
     
    func signInSwap(in vc : UIViewController) {
            if let authUI = FUIAuth.defaultAuthUI() {
                authUI.delegate = self
            
                authUI.providers = [FUIEmailAuth(), FUIOAuth.appleAuthProvider()]
    
                let authVC = authUI.authViewController()
                vc.present(authVC, animated: true)

            }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let _ = error {
            
        } else {
            FireDataBase.shared.currentUser = authDataResult?.user
        }
    }
    
}
