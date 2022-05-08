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
     
    func signInSwap(in vc : UIViewController & FUIAuthDelegate) {
            if let authUI = FUIAuth.defaultAuthUI() {
                authUI.delegate = vc
            
                authUI.providers = [FUIEmailAuth(), FUIOAuth.appleAuthProvider()]
    
                let authVC = authUI.authViewController()
                authVC.modalPresentationStyle = .fullScreen
                
                //if let nc = vc.navigationController {
                 //   nc.pushViewController(authVC, animated: true)
                //} else {
                    vc.present(authVC, animated: true)
                //}
            }
    }
    
}
