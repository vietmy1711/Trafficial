//
//  User.swift
//  AppTraffic
//
//  Created by MAC OS on 11/20/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation
import FirebaseAuth

struct UserModel {
    var email: String?
    var fullname: String?
    var photo: String?
    var long: Double?
    var lat: Double?
    var password: String?
    
    init(email: String, fullname: String, photo: String, long: Double, lat: Double, password: String) {
        self.email = email
        self.fullname = fullname
        self.photo = photo
        self.lat = lat
        self.long = long
        self.password = password
    }
}
