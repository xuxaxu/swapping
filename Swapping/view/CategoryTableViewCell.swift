//
//  CategoryTableViewCell.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 21.04.22.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var nameCategoryLabel: UILabel!
    
    @IBOutlet weak var imgCategory: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name : String, img : UIImage?) {
        self.nameCategoryLabel.text = name
        self.imgCategory.image = img
    }
    
}
