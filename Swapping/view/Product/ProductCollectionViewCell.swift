//
//  ProductCollectionViewCell.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 01.05.22.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImageLabelView: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    func confugure(text : String, image : UIImage?) {
        if let image = image {
            productImageView.image = image
            imageWork.adjustImageView(imageView: &productImageView, widthConstraint: &widthConstraint, heightConstraint: &heightConstraint)
        }
        productImageLabelView.text = text
    }
}
