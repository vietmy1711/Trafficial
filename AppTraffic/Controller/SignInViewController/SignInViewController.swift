//
//  SignInViewController.swift
//  AppTraffic
//
//  Created by MAC OS on 11/8/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit
import CoreLocation

class SignInViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var showPasswordView: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signupLabel: UILabel!
    var locationManager: CLLocationManager?
    var showPassword : Bool = false {
        didSet {
            if showPassword {
                imageview.image = UIImage(named: "check-box")
                passwordTextfield.isSecureTextEntry = false
            } else {
                imageview.image = UIImage(named: "blank-check-box")
                passwordTextfield.isSecureTextEntry = true
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.handleKeyboard()
        self.hideKeyboardWhenTappedAround()
    }
    
    func setupUI() {
        determineMyCurrentLocation()
        self.showPassword = false
        passwordTextfield.isSecureTextEntry = true
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSignUp)))
        showPasswordView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapshowpassword)))
    }
    
    @objc func tapshowpassword() {
        showPassword = !showPassword
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.startUpdatingLocation()
                //locationManager.startUpdatingHeading()
        }
    }
    
    @objc func tapSignUp() {
        let signupVC = SignUpViewController()
        signupVC.modalPresentationStyle = .fullScreen
        self.present(signupVC,animated: true)
    }
    @IBAction func clickSignIn(_ sender: Any) {
        UserNetworking.instance.signIn(email: emailTextfield.text ?? "", password: passwordTextfield.text ?? "") { [weak self] isSuccess, message in
            if isSuccess {
                let homeVC = AirQualityVC()
                let keywindow = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
                keywindow?.rootViewController = homeVC
            }
            else {
                let alertController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true)
            }
        }
    }
}

extension SignInViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextfield {
            passwordTextfield.becomeFirstResponder()
            return false
        }
        self.view.endEditing(true)
        return false
    }
}
