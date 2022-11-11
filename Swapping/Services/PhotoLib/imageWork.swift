//
//  imageWork.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 04.05.22.
//

import Foundation
import UIKit

final class imageWork {
    
    private static func imageWidthHeight(imageSize : CGSize, imgWidthConstraint: CGFloat, imgHeightConstraint: CGFloat) -> (CGFloat, CGFloat) {
        var imgWidth = imgWidthConstraint
        var imgHeight = imgHeightConstraint
        if imageSize.width > 0, imageSize.height > 0 {
            if imageSize.width > imageSize.height {
                imgHeight = imgWidthConstraint * (imageSize.height / imageSize.width)
            } else {
                imgWidth = imgHeightConstraint * (imageSize.width / imageSize.height)
            }
        }
        
        return (imgWidth, imgHeight)
    }
    
    static func adjustImageView(imageView: inout UIImageView, widthConstraint: inout NSLayoutConstraint, heightConstraint: inout NSLayoutConstraint) {
        if let img = imageView.image {
           let imgSize = imageWidthHeight(imageSize: img.size, imgWidthConstraint: widthConstraint.constant, imgHeightConstraint: heightConstraint.constant)
            
            heightConstraint.constant = imgSize.1
            widthConstraint.constant = imgSize.0
        }
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 13
        imageView.setNeedsLayout()
    }
    
    static func adjustTextView(textView: inout UITextView, heightConstraint: inout NSLayoutConstraint) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        heightConstraint.constant = textView.frame.height
        
        textView.setNeedsLayout()
    }
}
