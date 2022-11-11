import UIKit
import FirebaseAuthUI

class AuthViewController: UIViewController, FUIAuthDelegate, CoordinatedVC, UITextFieldDelegate, Storyboarded {
    
    public var output: AuthViewOutput!

    
    var coordinator : CoordinatorProtocol?
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var saveCredentialsBtn: UIButton!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        loginTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameTextField.becomeFirstResponder()
        
    }
    
    func setSaveCredentials(_ value: Bool) {
        if value {
            saveCredentialsBtn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        } else {
            saveCredentialsBtn.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
        saveCredentialsBtn.setNeedsLayout()
    }
    
    @IBAction func loginEditDidEnd(_ sender: UITextField) {
        output.loginEditingEnd(sender.text)
    }
    
    @IBAction func passwordEditDidEnd(_ sender: UITextField) {
    }
    
    @IBAction func saveCredentialTap(_ sender: UIButton) {
        output.saveCredentialsTap()
    }
    
    @IBAction func forgotPasswordAction(_ sender: UIButton) {
        if let login = loginTextField.text, login != "" {
            output.forgotPassword(login: login)
        } else {
            coordinator?.showAlert(message: "full your email", in: self)
        }
    }
    
    
    @IBAction func signInAction(_ sender: UIButton) {
        if let login = loginTextField.text, let password = passwordTextField.text {
            output.signIn(login: login, password: password)
        } else {
            coordinator?.showAlert(message: "email and password can't be empty", in: self)
        }
    }
    
    func finish() {
        
        guard let coordinator = coordinator as? MainCoordinatorProtocol else {
            return
        }
        coordinator.showMainTabBar()
    
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        if let name = nameTextField.text,
            let email = loginTextField.text,
           let password = passwordTextField.text {
            output.signUp(name: name, login: email, password: password)
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

extension AuthViewController: AuthViewInput {
    func fillPassword(_ password: String) {
        passwordTextField.text = password
    }
    
    func showAlert(_ message: String) {
        coordinator?.showAlert(message: message, in: self)
    }
}
