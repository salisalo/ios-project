//
//  RegisterViewController.swift
//  TvShows
//
//  Created by Salo Antidze on 3/23/21.
//

import UIKit
import Firebase
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.layer.cornerRadius = 10
        firstNameTextField.clipsToBounds = true
        lastNameTextField.layer.cornerRadius = 10
        lastNameTextField.clipsToBounds = true
        emailTextField.layer.cornerRadius = 10
        emailTextField.clipsToBounds = true
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.clipsToBounds = true
        repeatPasswordTextField.layer.cornerRadius = 10
        repeatPasswordTextField.clipsToBounds = true
        registerButton.layer.cornerRadius = 10
        registerButton.clipsToBounds = true
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.layer.frame.size.width / 2
        profilePictureImageView.clipsToBounds = true
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profilePictureImageViewClicked))
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(gesture)
        
    }
    
    
    @objc private func profilePictureImageViewClicked() {
        presentPhotoActionSheet()
    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let repeatPassword = repeatPasswordTextField.text,
              !email.isEmpty,
              !password.isEmpty,
              !repeatPassword.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty
              else {
            showErrorAlert(message: "Please fill all fields")
            return
        }
        
        guard password == repeatPassword else {
            showErrorAlert(message: "Passwords don't match")
            return
        }
        
        guard password.count >= 6 else {
            showErrorAlert(message: "Password must be at least 6 symbols")
            return
        }
        
        spinner.show(in: view)
        
        DbManager.shared.userExists(with: email) { [weak self] userExists in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            guard !userExists else {
                self.showErrorAlert(message: "User with this email already exists")
                return
            }
            
            Firebase.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                guard result != nil, error == nil
                else {
                    self.showErrorAlert(message: "There was a problem creating new account")
                    return
                }
                
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                let user = User(firstName: firstName,
                                lastName: lastName,
                                email: email)
                DbManager.shared.insertUser(with: user, completion: { isSuccessful in
                    print("\(isSuccessful)")
                    if isSuccessful {
                        
                        // upload image
                        guard let image = self.profilePictureImageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        let filename = user.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename) {
                            (url, error ) in
                            if let url = url {
                                UserDefaults.standard.set(url, forKey: "profile_picture_url")
                                
                                guard let vc = self.storyboard?.instantiateViewController(identifier: "ProfileNavigationViewController")
                                else { return }
                                
                                guard let rootViewController = self.navigationController?.viewControllers.first
                                else { return }
                                
                                guard let firstTabVc = rootViewController.tabBarController?.viewControllers?[0]
                                else { return }
                                
                                self.tabBarController?.setViewControllers([firstTabVc, vc], animated: false)
                                vc.tabBarItem.image = UIImage(systemName: "person.circle")
                                vc.tabBarItem.title = "Profile"
                            }
                        }
//                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
//                            switch result {
//                            case .success(let downloadUrl):
//                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
//                                print(downloadUrl)
//                            case .failure(let error):
//                                print("Storage manager error: \(error)")
//                            }
//                        })
                    }
                })
                
                //                        if let vc = self.storyboard?.instantiateViewController(identifier: "WelcomeViewController") {
                //                            vc.modalPresentationStyle = .fullScreen
                //                            self.present(vc, animated: true, completion: nil)
                //                        }
               
                
            }
            
        }
        
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension RegisterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take a Picture",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentCamera()
                                                
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Choose a Picture",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentPhotoPicker()
                                                
                                            }))
        
        present(actionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.profilePictureImageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
