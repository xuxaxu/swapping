import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImageLabelView: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    func confugure(text : String, image : UIImage?) {
        if let image = image {
            productImageView.image = image
            heightConstraint.constant = 100
            widthConstraint.constant = 100
            imageWork.adjustImageView(imageView: &productImageView, widthConstraint: &widthConstraint, heightConstraint: &heightConstraint)
        }
        productImageLabelView.text = text
    }
    
    override func prepareForReuse() {
        productImageView.image = nil
    }
    
}
