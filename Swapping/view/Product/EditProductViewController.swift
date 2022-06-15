//
//  EditProductViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 01.05.22.
//

import UIKit

class EditProductViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, PhotoPickerDelegate, CoordinatedVC, UITextViewDelegate {
    
    var coordinator: Coordinator?
    
    var model: ProductEditVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        model.fillTopLevelCategories()

        if let product = model.product {
            shortTextView.text = product.name
            productImageView.image = product.image
            descriptionTextView.text = product.productDescription
            categoryTextField.text = product.category
        }
        
        if descriptionTextView.text == nil || descriptionTextView.text == "write something about product here" {
                descriptionTextView.text = "write something about product here"
                descriptionTextView.textColor = .lightGray
        } else {
            descriptionTextView.textColor = .label
        }
        descriptionTextView.delegate = self
        
        pickerView.dataSource = self
        pickerView.delegate = self
        categoryTextField.inputView = pickerView
        
        adjustImage()
        
        //set action for choosing image
        let clickGesture = UITapGestureRecognizer(target: self, action: #selector(self.takePhoto(gesture: )))
        clickGesture.numberOfTapsRequired = 1
        productImageView.addGestureRecognizer(clickGesture)
        
    }
    
    func bindViewModel() {
        
        model.errorMessage.bind { [weak self] message in
            self?.coordinator?.showAlert(message: message, in: self!)
        }
        
        model.category?.bind({ [weak self] category in
            self?.categoryTextField.text = category.name
        })
    }
    
    @IBOutlet private weak var shortTextView: UITextField!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var imgWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK: - choosing category for product, in DataService have topLevelCategories for 1 component of picker and allCategories for 2 picker component
    @IBOutlet weak var categoryTextField: UITextField!
    
    var pickerView = UIPickerView()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
            
        case 0: return model.filteredTopLevelCategories.count
            
        case 1: 
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            if  selectedRow < model.filteredTopLevelCategories.count,
                let count = model.filteredCategories[model.filteredTopLevelCategories[selectedRow]]?.count {
                return count
            } else {
                return 0
            }
            
        default: return 0
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return model.filteredTopLevelCategories[row]
        } else {
            
            if let arrayCategories = model.filteredCategories[model.filteredTopLevelCategories[pickerView.selectedRow(inComponent: 0)]],
                row < arrayCategories.count {
                    return arrayCategories[row]
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
            if row < model.filteredTopLevelCategories.count, model.filteredCategories[model.filteredTopLevelCategories[row]]?.count == 0 {
                categoryTextField.text = model.filteredTopLevelCategories[row]
            } else {
                if row < model.filteredTopLevelCategories.count, model.filteredCategories[model.filteredTopLevelCategories[row]]?.count == 1 {
                    categoryTextField.text = model.filteredCategories[model.filteredTopLevelCategories[row]]?[0] ?? ""
                }
            }
        } else {
            let selectedTop = pickerView.selectedRow(inComponent: 0)
              
            if selectedTop < model.filteredTopLevelCategories.count,
               let filteredArray = model.filteredCategories[model.filteredTopLevelCategories[selectedTop]],
               row < filteredArray.count {
                    categoryTextField.text = filteredArray[row]
                categoryTextField.endEditing(true)
            }
        }
    }
    
    @IBAction private func categoryTextDidBegin(_ sender: UITextField) {
        model.refreshFilteredCategories()
    }
    
    @IBAction private func categoryTextEditingChanged(_ sender: UITextField) {
        model.filterStr = categoryTextField.text ?? ""
        pickerView.reloadComponent(0)
        pickerView.reloadComponent(1)
    }
    
    @IBAction private func categoryTextDidEnd(_ sender: UITextField) {
        if !model.correctCategoryName(name: categoryTextField.text) {
                categoryTextField.text = ""
            if let coordinator = coordinator {
                coordinator.showAlert(message: "Choose from sugested values please", in: self)
            }
        } else {
            categoryTextField.backgroundColor = .clear
        }
    }
    
    //MARK: - image editing
    private func adjustImage() {
        imageWork.adjustImageView(imageView: &productImageView, widthConstraint: &imgWidthConstraint, heightConstraint: &imgHeightConstraint)
    }
    
    @objc private func takePhoto(gesture : UITapGestureRecognizer) {
        let pickerImage = PhotoPicker.shared
        pickerImage.photoPickerDelegate = self
        pickerImage.loadImage()
    }
    
    func imageGot(image: UIImage) {
        productImageView.image = image
        adjustImage()
    }
    
    //MARK: - name editing
    @IBAction private func shortTextEditEnd(_ sender: UITextField) {
        if let text = shortTextView.text, text != "" {
            shortTextView.backgroundColor = .clear
        }
    }
    
    //MARK: - description editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "write something about product here" {
            textView.text = ""
            textView.textColor = .label
        } else {
            if textView.text == "" {
                textView.text = "write something about product here"
                textView.textColor = .lightGray
            }
        }
    }
    
    //MARK: - finish editing or creating product
    @IBAction private func done(_ sender: UIButton) {
        
        guard let name = shortTextView.text, name != "" else {
            shortTextView.backgroundColor = .systemPink
            return
        }
        
        guard model.correctCategoryName(name: categoryTextField.text) else {
            categoryTextField.backgroundColor = .systemPink
            return
        }
        
        model.editProduct(name: name, category: categoryTextField.text!, image: productImageView.image, description: descriptionTextView.text)
        
        if let nc = navigationController {
            if nc.children.count>1, let productsVC = nc.children[nc.children.count-2] as? ProductViewController {
                productsVC.startRefreshingData()
                
                model.subscribeForUpdateProduct(subscriber: productsVC.model)
            }
            nc.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        //ask one more time
        let alert = UIAlertController(title: "warning", message: "Are you sure to delete this product?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: deleteProduct(_:)))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
       
        self.present(alert, animated: true)

    }
    
    @objc func deleteProduct(_ alert : UIAlertAction) {
        model.deleteProduct()
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
