//
//  SplashScreenViewController.swift
//  AppTraffic
//
//  Created by MAC OS on 11/7/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var contractLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapview)))
    }
    
    @objc func tapview() {
        UIView.animate(withDuration: 0.3, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.titleLabel.transform = CGAffineTransform(translationX: -30, y: 0)
        }) { (_) in
            UIView.animate(withDuration: 0.3, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.titleLabel.alpha = 0
                self.titleLabel.transform = self.titleLabel.transform.translatedBy(x: 0, y: -150)
            }) { (_) in
                UIView.animate(withDuration: 0.3, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.descriptionLabel.transform = CGAffineTransform(translationX: -30, y: 0)
                    self.contractLabel.transform = CGAffineTransform(translationX: -30, y: 0)
                }) { (_) in
                    UIView.animate(withDuration: 0.3, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                        self.descriptionLabel.alpha = 0
                        self.contractLabel.alpha = 0
                        self.descriptionLabel.transform =  self.descriptionLabel.transform.translatedBy(x: 0, y: -200)
                        self.contractLabel.transform = self.contractLabel.transform.translatedBy(x: 0, y: -200)
                    }) { (_) in
                        let homeVC = AirQualityVC()
                        let keywindow = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
                        keywindow?.rootViewController = homeVC
                    }
                }
            }
        }
    }
}
