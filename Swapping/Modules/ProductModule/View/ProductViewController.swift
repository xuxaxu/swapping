import UIKit

class ProductViewController: UIViewController,
                             CoordinatedVC,
                             UITableViewDelegate,
                             UITableViewDataSource,
                             Storyboarded {
    
    var coordinator: CoordinatorProtocol?
    
    var output: ProductViewOutput!
    
    @IBOutlet weak var categoryLabelView: UILabel!
    
    @IBOutlet weak var productLabelView: UILabel!
    
    @IBOutlet weak var descriptionLabelView: UITextView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var owner: UILabel!

    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var sendMessageBtn: UIButton!
    
    @IBOutlet weak var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.dataSource = self
        messageTableView.delegate = self
        messageTableView.register(
            UINib(nibName: GlobalConstants.nibNameForMessageCell,
                  bundle: .main),
            forCellReuseIdentifier: Constants.reusableMessageCell)
        messageTableView.estimatedRowHeight = DesignSizes.messageRowHeight
        
        setupEditBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        output.fillInformation()
    }
    
    private func setupEditBtn() {
        if !output.editable {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    @IBAction func editProductAction(_ sender: UIBarButtonItem) {
        output.editBtnTap()
    }
    
    //MARK: message exchange
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        if let message = messageTextField.text {
            output.writeToOwner(message: message)
            messageTextField.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.messagesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.reusableMessageCell,
            for: indexPath) as? MessageTableViewCell,
            output.messagesCount() > indexPath.row {
            let message = output.getMessage(index: indexPath.row)
            cell.configure(author: output.labelForAuthor(message: message), message: message.text ?? "", date: message.date)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let fixedWidth = tableView.frame.width - 10
        let textView = UITextView()
        if let text = output.getMessage(index: indexPath.row).text {
            textView.text = text
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            return newSize.height + 30
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ProductViewController {
    struct Constants {
        static let reusableMessageCell = "messageTableViewCell"
    }
}

extension ProductViewController: ProductViewInput {
    func fillProductName(with name: String) {
        productLabelView.text = name
    }
    
    func fillDescription(with text: String?) {
        descriptionLabelView.text = text
        imageWork.adjustTextView(textView: &descriptionLabelView,
                                 heightConstraint: &descriptionHeightConstraint)
    }
    
    func fillImage(with image: UIImage) {
        productImageView.image = image
        imageWork.adjustImageView(imageView: &productImageView, widthConstraint: &widthConstraint, heightConstraint: &heightConstraint)
    }
    
    func goToEditModule(product: Product) {
        if let coordinator = coordinator as? ProductListCoordinatorProtocol {
            coordinator.showEditingProduct(product: product,
                                           presentingVC: self)
        }
    }
    
    func showOwnerName(_ name: String) {
        owner.text = name
    }
    
    func showCategory(_ category: String) {
        categoryLabelView.text = category
    }
    
    func showMessages(_ messages: [Message]) {
        messageTableView.reloadData()
    }
    
    func showAlert(_ message: String) {
        coordinator?.showAlert(message: message, in: self)
    }
}
