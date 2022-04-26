//
//  PhotoChooser.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 25.04.22.
//

import Foundation
import PhotosUI
import MobileCoreServices

class PhotoPicker : (UIImagePickerController & UINavigationControllerDelegate), PHPickerViewControllerDelegate {
    
    static var shared = PhotoPicker()
    
    var photoPickerDelegate : PhotoPickerDelegate?
    
    func pickupImage() {
        if let vc = photoPickerDelegate {
            let pickupVC = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                //pickupVC.delegate = self
                pickupVC.sourceType = .camera
                pickupVC.mediaTypes = [kUTTypeImage as String]
                pickupVC.modalPresentationStyle = .popover
                pickupVC.allowsEditing = true
                
                vc.present(pickupVC, animated: true)
            }
        }
    }

    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.presentingViewController?.dismiss(animated: true)
        if let image = ((info[UIImagePickerController.InfoKey.editedImage] ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage) {
            photoPickerDelegate?.imageGot(image: image)
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
        if let vc = photoPickerDelegate {
            
            var configPhLib = PHPickerConfiguration()
            configPhLib.selectionLimit = 1
            configPhLib.filter = .images
            let pickupVC = PHPickerViewController(configuration: configPhLib)
            pickupVC.delegate = self
            pickupVC.modalPresentationStyle = .popover
            vc.present(pickupVC, animated: true)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.presentingViewController?.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [photoPickerDelegate] itemProvider, error in
                if error == nil {
                    if let image = itemProvider as? UIImage {
                        DispatchQueue.main.async {
                            photoPickerDelegate?.imageGot(image: image)
                        }
                    }
                }
            }
        }
    }

}

protocol PhotoPickerDelegate : UIViewController {
    func imageGot(image : UIImage)
}

