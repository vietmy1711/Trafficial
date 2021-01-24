//
//  NSObject+Extension.swift
//  AppTraffic
//
//  Created by Edward Lauv on 1/6/21.
//  Copyright © 2021 Edward Lauv. All rights reserved.
//

import Foundation
extension NSObject {
    var className : String {
        return String(describing: type(of: self))
    }
}
