//
//  SignUpViewController.swift
//  AppTraffic
//
//  Created by MAC OS on 11/8/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        avatarImageView.image = image
        print("hello")
    }
    
    
    var imagepicker : ImagePicker!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var showPasswordImagView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullnameTextField: UITextField!
    var isSignUpSuccess : Bool = true //false
    var showPassword : Bool = false {
        didSet{
            if showPassword {
                showPasswordImagView.image = UIImage(named: "check-box")
                passwordTextField.isSecureTextEntry = false
            } else {
                showPasswordImagView.image = UIImage(named: "blank-check-box")
                passwordTextField.isSecureTextEntry = true
            }
        }
    }
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagepicker.present(from: sender)
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func showpassword() {
        showPassword = !showPassword
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.handleKeyboard()
        self.hideKeyboardWhenTappedAround()
        passwordTextField.isSecureTextEntry = true
    }
    func setupUI() {
        showPasswordImagView.isUserInteractionEnabled = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        fullnameTextField.delegate = self
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
        imagepicker = ImagePicker(presentationController: self, delegate: self)
        showPasswordImagView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showpassword)))
    }
    @IBAction func touchSignUp(_ sender: Any) {
        let user = UserModel(email: emailTextField.text ?? "", fullname: fullnameTextField.text ?? "", photo: "", long: 0.0, lat: 0.0, password: passwordTextField.text ?? "")
        UserNetworking.instance.createUser(user: user, image: avatarImageView.image!) {[weak self](isSuccess, message) in
            if isSuccess {
                let splashscreen = SplashScreenViewController()
                let keywindow = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
                keywindow?.rootViewController = splashscreen

            }
            else {
                let alert = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
            }
        }
    }
}

extension SignUpViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return false
        } else if textField == passwordTextField {
            fullnameTextField.becomeFirstResponder()
            return false
        }
        self.view.endEditing(true)
        return false
    }
}



