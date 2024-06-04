//
//  ProfileEditView.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 22/12/2018.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit
import ImagePicker
import ImageLoader
class ProfileEditView: UIViewController, ImagePickerDelegate, UITextFieldDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if (images.count>0){
            profilePicture.image=images[0]
            profilePicture.contentMode = .scaleAspectFill
            profilePicture.clipsToBounds = true
        }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if (images.count>0){
            profilePicture.image=images[0]
            profilePicture.contentMode = .scaleAspectFill
            profilePicture.clipsToBounds = true
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    

    let session = UserDefaults.standard
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func initialize() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.fullName.delegate = self
        fullName.text=session.string(forKey: "fullName")
        profilePicture.load.request(with: session.string(forKey: "profilePicture") ?? "")
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.clipsToBounds = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func browseImage(_ sender: Any) {
        let configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.recordLocation = false
        let imagePickerController = ImagePickerController(configuration: configuration)
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
