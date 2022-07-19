//
//  ProductChooseViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 06.05.22.
//

import UIKit

class ProductChooseViewController: UIViewController, CoordinatedVC, UITableViewDelegate, UITableViewDataSource {
    
    var coordinator: CoordinatorProtocol?
    
    var model: ProductVM!
    
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
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: .main), forCellReuseIdentifier: "messageTableViewCell")
        messageTableView.estimatedRowHeight = 100
        
        bindViewModel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillData()
    }
    
    private func bindViewModel() {
        
        model.errorMessage.bind { [weak self] message in
            self?.coordinator?.showAlert(message: message, in: self!)
        }
        
        model.ownerName.bind { [weak self] name in
            self?.owner.text = name
        }
        
        model.parentCategory.bind { [weak self] parent in
            self?.categoryLabelView.text = parent
        }
        
        model.currentUserIsOwner.bind { [weak self] isOwner in
            if !isOwner {
                self?.navigationItem.setRightBarButton(nil, animated: true)
            }
        }
        
        model.messagesUpdated.bind { [weak self] updated in
            if updated {
                self?.messageTableView.reloadData()
            }
        }
    }
    
    
    
    @IBAction func editProductAction(_ sender: UIBarButtonItem) {
        if let coordinator = coordinator as? ProductListCoordinatorProtocol {
            coordinator.showEditingProduct(product: model.product, presentingVC: self)
        }
    }
    
    func fillData() {
        
        productLabelView.text = model.product.name
        
        descriptionLabelView.text = model.product.productDescription
        imageWork.adjustTextView(textView: &descriptionLabelView, heightConstraint: &descriptionHeightConstraint)
        
        if let image = model.product.image {
                productImageView.image = image
                imageWork.adjustImageView(imageView: &productImageView, widthConstraint: &widthConstraint, heightConstraint: &heightConstraint)
        }
        
        model.getNameOfOwner()
        model.getParentCategory()
        model.getMessages()
    }
    
    //MARK: message exchange
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        if let message = messageTextField.text {
            model.writeToOwner(message: message)
            messageTextField.text = ""
            model.getMessages()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableViewCell", for: indexPath) as? MessageTableViewCell,
           model.messages.count > indexPath.row {
            let message = model.messages[indexPath.row]
            cell.configure(author: model.labelForAuthor(message: message), message: message.text ?? "", date: message.date)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let fixedWidth = tableView.frame.width - 10
        let textView = UITextView()
        if let text = model.messages[indexPath.row].text {
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
