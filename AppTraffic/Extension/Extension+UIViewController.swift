//
//  Extension+UIViewController.swift
//  AppTraffic
//
//  Created by Edward Lauv on 1/8/21.
//  Copyright © 2021 Edward Lauv. All rights reserved.
//

import UIKit
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleKeyboard() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notication:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notication:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notication:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        
        @objc func keyboardWillChange(notication: Notification) {
            guard let keyboard = (notication.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            if notication.name == UIResponder.keyboardWillShowNotification {
                view.frame.origin.y = -keyboard.height/2
            } else {
                view.frame.origin.y = 0
            }
        }
}
