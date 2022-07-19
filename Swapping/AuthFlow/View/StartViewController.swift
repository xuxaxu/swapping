//
//  StartViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 22.04.22.
//

import UIKit
import FirebaseAuthUI

class StartViewController: UIViewController, FUIAuthDelegate, CoordinatedVC, UITextFieldDelegate, Storyboarded {
    
    var authStarted = false
    
    var coordinator : CoordinatorProtocol?
    
    var model : SwappingAuth!
    
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    private var saveCredential = true
    
    @IBOutlet weak var saveCredentialsBtn: UIButton!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        loginTextField.delegate = self
        passwordTextField.delegate = self

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
        
        nameTextField.becomeFirstResponder()
        
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
        
        if let login = sender.text, let password = model.getSavedPassword(login: login) {
            passwordTextField.text = password
        }
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
        if let name = nameTextField.text,
            let email = loginTextField.text,
           let password = passwordTextField.text {
        model.signUp(login: email, password: password, name: name, save: saveCredential)
        } else {
            coordinator?.showAlert(message: "fullfill all fields", in: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) {
            
            if let btn = nextField as? UIButton {
                btn.isSelected = true
                textField.resignFirstResponder()
                btn.sendActions(for: .touchUpInside)
            }
            
            nextField.becomeFirstResponder()
        } else {
            signInBtn.becomeFirstResponder()
        }
        return false
    }
    
}
