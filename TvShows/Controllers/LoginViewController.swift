//
//  LoginViewController.swift
//  TvShows
//
//  Created by Salo Antidze on 3/23/21.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var loginView: UIView!
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        emailTextField.layer.cornerRadius = 10
        emailTextField.clipsToBounds = true
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.clipsToBounds = true
        logInButton.layer.cornerRadius = 10
        logInButton.clipsToBounds = true
        registerButton.layer.cornerRadius = 10
        registerButton.clipsToBounds = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        loginView.isUserInteractionEnabled = true
        loginView.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
//    @objc func keyboardWillShow(notification: NSNotification) {
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
//              return
//           }
//
//        UIView.animate(withDuration: 2, delay: 0, options: UIView.AnimationOptions.transitionFlipFromTop) {
//            self.iconImageView.alpha = 0.0
//        } completion: { finished in
//            self.iconImageView.isHidden = true
//        }
//
//         self.view.frame.origin.y =  50 - keyboardSize.height
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        UIView.animate(withDuration: 2, delay: 0, options: UIView.AnimationOptions.transitionFlipFromTop) {
//            self.iconImageView.alpha = 1
//        } completion: { finished in
//            self.iconImageView.isHidden = false
//        }
//
//        self.view.frame.origin.y = 0
//    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "RegisterViewController") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        login()
    }
    
    func login() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        spinner.show(in: view)
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Firebase.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
                
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.spinner.dismiss()
                }
                
                guard result != nil, error == nil
                else {
                    let alert = UIAlertController(title: "Error", message: "There was a problem signing in", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                UserDefaults.standard.set(email, forKey: "email")
                
//                if let vc = self.storyboard?.instantiateViewController(identifier: "TabBarViewController") {
//                    vc.modalPresentationStyle = .fullScreen
//                    self.present(vc, animated: true, completion: nil)
//                }
                //self.dismiss(animated: true, completion: nil)
                
                guard let vc = self.storyboard?.instantiateViewController(identifier: "ProfileNavigationViewController")
                else { return }
                
                guard let firstTabVc = self.tabBarController?.viewControllers?[0]
                else { return }
                
                self.tabBarController?.setViewControllers([firstTabVc, vc], animated: false)
                vc.tabBarItem.image = UIImage(systemName: "person.circle")
                vc.tabBarItem.title = "Profile"
            }
        }
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            login()
        }
        
        return true
    }
    
}
