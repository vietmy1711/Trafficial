//
//  ActivityIndicator.swift
//  AppTraffic
//
//  Created by Edward Lauv on 1/11/21.
//  Copyright © 2021 Edward Lauv. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicator {
    // MARK: - Properties
    private static let shared = ActivityIndicator()
    private let TAG: Int = 7771
    
    // MARK: - Init
    private init() { }
    
    private func show(in viewController: UIViewController, timeOut: Double? = nil) {
        let activityIndicator = createActivityIndicator()
        activityIndicator.center = UIWindow(frame: UIScreen.main.bounds).center
        activityIndicator.startAnimating()
        viewController.view.addSubview(activityIndicator)
        viewController.view.bringSubviewToFront(activityIndicator)
        if let deadline = timeOut {
            weak var _viewController = viewController
            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
                if let viewController = _viewController {
                    self.hide(in: viewController)
                }
            }
        }
    }
    
    private func hide(in viewController: UIViewController) {
        if !isShowing(in: viewController) {
            return
        }
        
        let activityIndicator = getActivityIndicator(in: viewController)
        
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = UIScreen.main.bounds
        activityIndicator.color = .white
        //activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        //activityIndicator.layer.cornerRadius = 10
        activityIndicator.backgroundColor = UIColor.gray
        activityIndicator.tag = TAG
        return activityIndicator
    }
    
    private func isShowing(in viewController: UIViewController) -> Bool {
        if let _ = getActivityIndicator(in: viewController) {
            return true
        }
        
        return false
    }
    
    private func getActivityIndicator(in viewController: UIViewController) -> UIActivityIndicatorView? {
        return viewController.view.viewWithTag(TAG) as? UIActivityIndicatorView
    }
    
    // MARK: - Static functions
    static func show(in viewController: UIViewController, timeOut: Double? = nil) {
        shared.show(in: viewController, timeOut: timeOut)
    }
    
    static func hide(in viewController: UIViewController) {
        shared.hide(in: viewController)
    }
}
