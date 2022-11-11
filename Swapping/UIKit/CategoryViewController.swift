//
//  CategoryViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 21.04.22.
//

import UIKit
import PhotosUI

class CategoryViewController: UIViewController, PhotoPickerDelegate, UITextFieldDelegate, CoordinatedVC, Storyboarded {
    
    var coordinator: CoordinatorProtocol?
    
    var model: CategoryVM!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let model = model, let editedCategory = model.category {
            nameTextField.text = editedCategory.name
            imageView.image = editedCategory.image
        }
        adjustImageView()
        
        //set action for making photo
        let clickGesture = UITapGestureRecognizer(target: self, action: #selector(self.takePhoto(gesture: )))
        clickGesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(clickGesture)
        
        nameTextField.delegate = self
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        model?.errorMessage.bind({ [weak self] message in
            self?.coordinator?.showAlert(message: message, in: self!)
        })
    }
    
    @IBAction private func done(_ sender: UIButton) {
        if let name = nameTextField.text, name > ""  {
            if let model = model {
                
                var previousVC: ObjectUpdatesSubscriber? = nil
                if let nc = navigationController?.children,
                    nc.count>1,
                    let catalogVC = nc[nc.count-2] as? CatalogVC,
                   let subscriber = catalogVC.model {
                    previousVC = subscriber
                }
                
                model.editFinished(name: name, image: imageView.image, previousVC)
            }
        }
        
        if let coordinator = coordinator {
            coordinator.dismiss(vc: self)
        }
    }
    
    //MARK: - text fiels
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - photo for category
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imgWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    
    
    @objc private func takePhoto(gesture : UITapGestureRecognizer) {
        let pickerImage = PhotoPicker.shared
        pickerImage.photoPickerDelegate = self
        pickerImage.loadImage()
    }
    
    func imageGot(image: UIImage) {
        imageView.image = image
        adjustImageView()
    }
    
    private func adjustImageView() {
        imageWork.adjustImageView(imageView: &imageView, widthConstraint: &imgWidthConstraint, heightConstraint: &imgHeightConstraint)
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
