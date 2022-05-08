//
//  ProductChooseViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 06.05.22.
//

import UIKit

class ProductChooseViewController: UIViewController {
    
    @IBOutlet weak var categoryLabelView: UILabel!
    
    @IBOutlet weak var productLabelView: UILabel!
    
    @IBOutlet weak var descriptionLabelView: UITextView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var owner: UILabel!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if product != nil {
            categoryLabelView.text = product!.category
            productLabelView.text = product!.name
            descriptionLabelView.text = product!.productDescription
            if let image = product!.image {
                productImageView.image = image
                imageWork.adjustImageView(imageView: &productImageView, widthConstraint: &widthConstraint, heightConstraint: &heightConstraint)
            }
            //owner.text = product!.owner
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
