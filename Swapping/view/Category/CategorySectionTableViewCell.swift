//
//  CategorySectionTableViewCell.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 29.04.22.
//

import UIKit

class CategorySectionTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var sectionLabelView: UILabel!
    @IBOutlet weak var sectionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(text: String, image: UIImage?) {
        sectionLabelView.text = text
        sectionImageView.image = image
        
        sectionImageView.layer.cornerRadius = 13
        sectionImageView.clipsToBounds = true
    }
    
}
