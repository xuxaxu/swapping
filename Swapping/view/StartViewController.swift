//
//  StartViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import UIKit
import FirebaseAuthUI

class StartViewController: UIViewController, FUIAuthDelegate {

    private var authStarted = false
    
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
            DataService.shared.currentUser = authDataResult?.user
        }
        Coordinator.showMainTabBar(in: self)
        //Coordinator.dismiss(vc: self)
    }

}
