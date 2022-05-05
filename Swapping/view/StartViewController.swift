//
//  StartViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwappingAuth().signInSwap(in: self)
        
        //Coordinator.showCategories(in: nil, presentingVC: self)
        Coordinator.showProducts(presentingVC: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
