//
//  ProductChooseViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 06.05.22.
//

import UIKit

class ProductChooseViewController: UIViewController, CoordinatedVC {
    
    var coordinator: Coordinator?
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    
    
    @IBAction func editProductAction(_ sender: UIBarButtonItem) {
        coordinator?.showEditingProduct(product: model.product, presentingVC: self)
    }
    
    func fillData() {
        categoryLabelView.text = model.product.category
        productLabelView.text = model.product.name
        
        descriptionLabelView.text = model.product.productDescription
        imageWork.adjustTextView(textView: &descriptionLabelView, heightConstraint: &descriptionHeightConstraint)
        
        if let image = model.product.image {
                productImageView.image = image
                imageWork.adjustImageView(imageView: &productImageView, widthConstraint: &widthConstraint, heightConstraint: &heightConstraint)
        }
        
        model.getNameOfOwner()
        model.getParentCategory()
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
