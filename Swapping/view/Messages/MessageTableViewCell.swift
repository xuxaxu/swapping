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
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(author: String, message: String, date: Date?) {
        authorLabel.text = author
        
        messageTextView.text = message
        if author == "You" {
            messageTextView.backgroundColor = .tertiaryLabel
        } else {
            messageTextView.backgroundColor = .white
        }
        var constraint = NSLayoutConstraint()
        imageWork.adjustTextView(textView: &messageTextView, heightConstraint: &constraint)
        
        if let messageDate = date {
            dateLabel.text = DateFormatter.localizedString(from: messageDate, dateStyle: .medium, timeStyle: .medium)
        }
    }
    
    
}
