//
//  StartViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import UIKit
import FirebaseAuthUI

class StartViewController: UIViewController, FUIAuthDelegate, CoordinatedVC {
    
    private var authStarted = false
    
    var coordinator : Coordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !authStarted {
            authStarted = true
            SwappingAuth().signInSwap(in: self)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let _ = error {
            
        } else {
            //DataService.shared.currentUser = authDataResult?.user
        }
        coordinator?.showMainTabBar(in: self)
        coordinator?.dismiss(vc: self)
    }

}
