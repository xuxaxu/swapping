import UIKit

class LogoutVC: UIViewController, CoordinatedVC, Storyboarded {
    
    var coordinator: CoordinatorProtocol?

    var output: LogOutViewOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func logOutAction(_ sender: UIButton) {
        output.logOut()
    }
    
    
    @IBAction private func cancelAction(_ sender: UIButton) {
        dismiss()
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

extension LogoutVC: LogOutViewInput {
    func dismiss() {
        coordinator?.dismiss(vc: self)
    }
    
    func showAlert(_ message: String) {
        coordinator?.showAlert(message: message, in: self)
    }
        
    func finish() {
        guard let coordinator = coordinator as? MainCoordinatorProtocol else {
            return
        }
        coordinator.showStartVC(in: self)
    }
}
