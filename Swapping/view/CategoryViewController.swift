//
//  CategoryViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 21.04.22.
//

import UIKit
import PhotosUI

class CategoryViewController: UIViewController, PhotoPickerDelegate, UITextFieldDelegate {
    
    var category : Category?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set action for making photo
        let clickGesture = UITapGestureRecognizer(target: self, action: #selector(self.takePhoto(gesture: )))
        clickGesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(clickGesture)
        
        nameTextField.delegate = self
    }
    
    @IBAction func done(_ sender: UIButton) {
        if let name = nameTextField.text, name > ""  {
            if let editedCategory = category {
                
            } else {
                category = Category(name: name, parent: DataService.shared.parentCategory, image: imageView.image)
                FireDataBase.shared.createCategory(category: category!)
                DataService.shared.getCategories(in: DataService.shared.parentCategory)
            }
        }
        
        Coordinator.dismiss(vc: self)
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
    
    
    @objc func takePhoto(gesture : UITapGestureRecognizer) {
        let pickerImage = PhotoPicker.shared
        pickerImage.photoPickerDelegate = self
        pickerImage.loadImage()
    }
    
    func imageGot(image: UIImage) {
        imageView.image = image
        adjustImageView()
    }
    
    func adjustImageView() {
        if let img = imageView.image, img.size.width > 0, img.size.height > 0 {
            if img.size.width > img.size.height {
                //imageView.frame.size.height = imageView.frame.width * (img.size.height / img.size.width)
                imgHeightConstraint.constant = imgWidthConstraint.constant * (img.size.height / img.size.width)
            } else {
                //imageView.frame.size.width = imageView.frame.height * (img.size.width / img.size.height)
                imgWidthConstraint.constant = imgHeightConstraint.constant * (img.size.width / img.size.height)
            }
        }
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 0.3
        imageView.setNeedsLayout()
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
