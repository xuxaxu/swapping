//
//  MessageTableViewCell.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 16.06.22.
//

import UIKit

class MessageTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(author: String, message: String) {
        authorLabel.text = author
        messageTextView.text = message
        var constraint = NSLayoutConstraint()
        imageWork.adjustTextView(textView: &messageTextView, heightConstraint: &constraint)
    }
    
    
}
