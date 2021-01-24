//
//  Checkbox.swift
//  AppTraffic
//
//  Created by MAC OS on 24/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation
import UIKit
class Checbox : UIButton {
    let checkedimage = UIImage(systemName: "check-box")
    let uncheckedimage = UIImage(systemName: "blank-check-box" )
    
    var isChecked : Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedimage, for: .normal)
            } else {
                self.setImage(uncheckedimage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpOutside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender : UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
