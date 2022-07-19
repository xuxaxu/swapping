//
//  LogoutVC.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 20.05.22.
//

import UIKit

class LogoutVC: UIViewController, CoordinatedVC {
    
    var coordinator: CoordinatorProtocol?

    var model: SwappingAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindViewModel()
    }
    
    private func bindViewModel() {
        model.errorMessage.bind { [weak self] message in
            self?.coordinator?.showAlert(message: message, in: self!)
        }
        
        model.authenticated.bind { [weak self] authenticated in
            if !authenticated {
                self?.coordinator?.showStartVC(in: self!)
            }
        }
    }
    
    @IBAction private func logOutAction(_ sender: UIButton) {
        model.logout()
    }
    
    
    @IBAction private func cancelAction(_ sender: UIButton) {
        coordinator?.dismiss(vc: self)
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
