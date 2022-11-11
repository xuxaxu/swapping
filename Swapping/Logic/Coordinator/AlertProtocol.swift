import Foundation
import UIKit

protocol AlertProtocol {
    
    func showAlert(message: String, in vc: UIViewController)
    
}

extension AlertProtocol {
    
    func showAlert(message: String, in vc: UIViewController) {
            
        let alert = UIAlertController(title: message, message: "error.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
       
        vc.present(alert, animated: true)
    }
}
