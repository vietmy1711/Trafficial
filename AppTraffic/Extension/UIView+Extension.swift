//
//  UIView+Extension.swift
//  AppTraffic
//
//  Created by Edward Lauv on 1/6/21.
//  Copyright © 2021 Edward Lauv. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    func loadViewFromNib(nibName : String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
