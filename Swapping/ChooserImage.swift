//
//  ChooserImage.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 23.04.22.
//

import Foundation
import UIKit
import MobileCoreServices
import PhotosUI

class ChooserImage : NSObject, UIImagePickerControllerDelegate & UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    var delegate : ChooserImageDelegate?
    
    func pickupImage() {
        if let vc = delegate {
            let pickupVC = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickupVC.delegate = self
                pickupVC.sourceType = .camera
                pickupVC.mediaTypes = [kUTTypeImage as String]
                pickupVC.modalPresentationStyle = .popover
                pickupVC.allowsEditing = true
                
                if let nc = vc.navigationController {
                    nc.present(pickupVC, animated: true)
                } else {
                    vc.present(pickupVC, animated: true)
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = ((info[UIImagePickerController.InfoKey.editedImage] ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage) {
            delegate?.imageGot(image: image)
        } else {
            picker.presentingViewController?.dismiss(animated: true)
        }
    }
    
    func checkPermission() {
        /*
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            present(imagePicker, animated: true, completion: nil)
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    self.present(self.imagePicker, animated: true, completion: nil)
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
         */
    }
    
    //MARK: - choose image from photo library
    
    func loadImage() {
        if let vc = delegate {
            var configPhLib = PHPickerConfiguration()
            configPhLib.selectionLimit = 1
            configPhLib.filter = .images
            let pickupVC = PHPickerViewController(configuration: configPhLib)
            pickupVC.delegate = vc
            pickupVC.modalPresentationStyle = .popover
            vc.present(pickupVC, animated: true)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.presentingViewController?.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] itemProvider, error in
                if error == nil {
                    if let image = itemProvider as? UIImage {
                        DispatchQueue.main.async {
                            self?.delegate?.imageGot(image: image)
                        }
                    }
                }
            }
        }
    }
    
}

protocol PhotoPickerDelegate : UIViewController, PHPickerViewControllerDelegate {
    func imageGot(image : UIImage)
}

