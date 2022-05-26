//
//  StartViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import UIKit
import FirebaseAuthUI

class StartViewController: UIViewController, FUIAuthDelegate, CoordinatedVC {
    
    var authStarted = false
    
    var coordinator : Coordinator?
    
    var model : SwappingAuth!
    
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var saveCredential = true
    
    @IBOutlet weak var saveCredentialsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindModel()
        
        setSavingCredentials(model.lastChooseForCredentials())
    }
    
    private func bindModel() {
        model.authenticated.bind { [weak self] authenticated in
            if let strongSelf = self, strongSelf.authStarted {
                if authenticated {
                    strongSelf.done()
                } //else {
                    //strongSelf.model.signInSwap(in: strongSelf)
                    //strongSelf.setSavingCredentials(strongSelf.model.lastChooseForCredentials())
                //}
            }
        }
        
        model.errorMessage.bind { [weak self] message in
            if let strongSelf = self {
                strongSelf.coordinator?.showAlert(message: message, in: strongSelf)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !authStarted {
            authStarted = true
            model.checkSavedCredentials()
        }
    }
    
    func setSavingCredentials(_ save: Bool) {
        self.saveCredential = save
        
        if save {
            saveCredentialsBtn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        } else {
            saveCredentialsBtn.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
        saveCredentialsBtn.setNeedsLayout()
    }
    
    @IBAction func loginEditDidEnd(_ sender: UITextField) {
    }
    
    @IBAction func passwordEditDidEnd(_ sender: UITextField) {
    }
    
    @IBAction func saveCredentialTap(_ sender: UIButton) {
        setSavingCredentials(!saveCredential)
    }
    
    @IBAction func forgotPasswordAction(_ sender: UIButton) {
        if let login = loginTextField.text, login != "" {
        model.forgotPassword(login: login)
        } else {
            coordinator?.showAlert(message: "full your email", in: self)
        }
    }
    
    
    @IBAction func signInAction(_ sender: UIButton) {
        if let login = loginTextField.text, let password = passwordTextField.text {
            model.authenticate(login: login, password: password, save: saveCredential)
        } else {
            coordinator?.showAlert(message: "email and password can't be empty", in: self)
        }
    }
    
    func done() {
        model.saveChooseForCredentials(save: saveCredential)
        coordinator?.showMainTabBar(in: self)
    
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        model.signUp(login: loginTextField.text ?? "", password: passwordTextField.text ?? "", save: saveCredential)
    }
    
}
