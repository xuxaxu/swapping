//
//  EditProductViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 01.05.22.
//

import UIKit

class EditProductViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, PhotoPickerDelegate, CoordinatedVC {
    
    var coordinator: Coordinator?
    
    var model: ProductEditVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        model.fillTopLevelCategories()

        if let product = model.product {
            shortTextView.text = product.name
            productImageView.image = product.image
            longTextView.text = product.productDescription
            categoryTextField.text = product.category
        }
        
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
        model.topLevelCategoryNames.bind { [weak self] topLevels in
            self?.filteredTopLevelCategories = topLevels
        }
        
        model.allCategories.bind { [weak self] dictCategories in
            self?.filteredCategories = dictCategories
        }
        
        model.errorMessage.bind { [weak self] message in
            self?.coordinator?.showAlert(message: message, in: self!)
        }
    }
    
    @IBOutlet private weak var shortTextView: UITextField!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var imgWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var featureTableView: UITableView!
    
    @IBOutlet private weak var longTextView: UITextView!
    
    //MARK: - choosing category for product, in DataService have topLevelCategories for 1 component of picker and allCategories for 2 picker component
    @IBOutlet weak var categoryTextField: UITextField!
    
    var pickerView = UIPickerView()
    
    var filteredCategories : [String : [String]] = [:]
    var filteredTopLevelCategories : [String] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
            
        case 0: return filteredTopLevelCategories.count //DataService.shared.topLevelCategories.count
            
        case 1: //if let count = DataService.shared.allCategories[DataService.shared.topLevelCategories[pickerView.selectedRow(inComponent: 0)]]?.count {
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            if  selectedRow < filteredTopLevelCategories.count,
                let count = filteredCategories[filteredTopLevelCategories[selectedRow]]?.count {
                return count
            } else {
                return 0
            }
            
        default: return 0
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return filteredTopLevelCategories[row] //DataService.shared.topLevelCategories[row]
        } else {
            //if let arrayCategories = DataService.shared.allCategories[DataService.shared.topLevelCategories[pickerView.selectedRow(inComponent: 0)]],
            if let arrayCategories = filteredCategories[filteredTopLevelCategories[pickerView.selectedRow(inComponent: 0)]],
                row < arrayCategories.count {
                    return arrayCategories[row]
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
            if row < filteredTopLevelCategories.count, filteredCategories[filteredTopLevelCategories[row]]?.count == 0 {
                categoryTextField.text = filteredTopLevelCategories[row]
            } else {
                if row < filteredTopLevelCategories.count, filteredCategories[filteredTopLevelCategories[row]]?.count == 1 {
                    categoryTextField.text = filteredCategories[filteredTopLevelCategories[row]]?[0] ?? ""
                }
            }
        } else {
            let selectedTop = pickerView.selectedRow(inComponent: 0)
              //if selectedTop < DataService.shared.topLevelCategories.count,
              // let categoryName = DataService.shared.allCategories[DataService.shared.topLevelCategories[selectedTop]]?[row] {
            if selectedTop < filteredTopLevelCategories.count,
               let filteredArray = filteredCategories[filteredTopLevelCategories[selectedTop]],
               row < filteredArray.count {
                    categoryTextField.text = filteredArray[row]
            }
        }
    }
    
    @IBAction private func categoryTextDidBegin(_ sender: UITextField) {
        filteredTopLevelCategories = model.topLevelCategoryNames.value
        filteredCategories = model.allCategories.value
    }
    
    @IBAction private func categoryTextEditingChanged(_ sender: UITextField) {
        if let text = categoryTextField.text, text != "" {
            filteredCategories = model.allCategories.value.filter({ (key, value) in
                value.filter{$0.starts(with: text)}.count > 0
            })
            for (key, value) in filteredCategories {
                filteredCategories[key] = value.filter{ $0.starts(with: text) }
            }
            filteredTopLevelCategories = Array(filteredCategories.keys)
        } else {
            filteredTopLevelCategories = model.topLevelCategoryNames.value
            filteredCategories = model.allCategories.value
        }
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
    
    //MARK: - finish editing or creating product
    @IBAction private func done(_ sender: UIButton) {
        
        //if DataService.shared.currentUser == nil {
          //  coordinator.showStartVC(in: self)
            //SwappingAuth().signInSwap(in: self)
        //}
        
        guard let name = shortTextView.text, name != "" else {
            shortTextView.backgroundColor = .systemPink
            return
        }
        
        guard model.correctCategoryName(name: categoryTextField.text) else {
            categoryTextField.backgroundColor = .systemPink
            return
        }
        
        model.editProduct(name: name, category: categoryTextField.text!, image: productImageView.image, description: longTextView.text)
        
        if let nc = navigationController {
            if nc.children.count>1, let productsVC = nc.children[nc.children.count-2] as? ProductViewController {
                productsVC.startRefreshingData()
            }
            nc.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
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
