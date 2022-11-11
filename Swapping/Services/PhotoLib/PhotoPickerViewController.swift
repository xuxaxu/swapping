//
//  PhotoPickerViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 24.04.22.
//

import UIKit
import MobileCoreServices
import PhotosUI

class PhotoPickerViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadImage()
    }
    
    var delegate : PhotoPickerDelegate?
    
    func pickupImage() {
        if let _ = delegate {
            let pickupVC = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickupVC.delegate = self
                pickupVC.sourceType = .camera
                pickupVC.mediaTypes = [kUTTypeImage as String]
                pickupVC.modalPresentationStyle = .popover
                pickupVC.allowsEditing = true
                
                self.present(pickupVC, animated: true)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
        Coordinator().dismiss(vc: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = ((info[UIImagePickerController.InfoKey.editedImage] ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage) {
            delegate?.imageGot(image: image)
        }
        picker.presentingViewController?.dismiss(animated: true)
        Coordinator().dismiss(vc: self)
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
            pickupVC.delegate = self
            pickupVC.modalPresentationStyle = .popover
            self.present(pickupVC, animated: true)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.presentingViewController?.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [delegate] itemProvider, error in
                if error == nil {
                    if let image = itemProvider as? UIImage {
                        DispatchQueue.main.async {
                            delegate?.imageGot(image: image)
                        }
                    }
                }
            }
        }
        Coordinator().dismiss(vc: self)
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

protocol PhotoPickerDelegate : UIViewController, PHPickerViewControllerDelegate {
    func imageGot(image : UIImage)
}
