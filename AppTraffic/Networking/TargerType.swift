//
//  API.swift
//  AppTraffic
//
//  Created by MAC OS on 11/30/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation
import Alamofire

class ResponseError : Codable {
    var key : String?
    var messag : String?
}

protocol TargetType {
    var baseURL : String { get }
    var path : String { get }
    var param : Parameters { get }
    var httpMethod : HTTPMethod { get }
    var headers : HTTPHeaders { get }
    var url : URL { get }
    var encoding : ParameterEncoding { get }
}
