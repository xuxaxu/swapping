//
//  CategoryViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 21.04.22.
//

import UIKit

class CategoryViewController: UIViewController {
    
    var category : Category?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func done(_ sender: UIButton) {
        if let name = nameTextField.text, name > ""  {
            if let editedCategory = category {
                
            } else {
                category = Category(name: name, parent: FireDataBase.shared.parentCategory)
                FireDataBase.shared.createCategory(category: category!)
                FireDataBase.shared.getCategories(in: FireDataBase.shared.parentCategory)
            }
        }
        dismiss(animated: true)
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
