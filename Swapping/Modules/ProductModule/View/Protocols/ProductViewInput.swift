import UIKit

protocol ProductViewInput: AnyObject {
    func showAlert(_ message: String)
    func showOwnerName(_ name: String)
    func showCategory(_ category: String)
    func showMessages(_ messages: [Message])
    func fillProductName(with name: String)
    func fillDescription(with text: String?)
    func fillImage(with image: UIImage)
    func goToEditModule(product: Product)
}
