//
//  CountryNetwoking.swift
//  AppTraffic
//
//  Created by MAC OS on 11/26/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation
import Alamofire

enum  CountryNetwoking {
    case Country
    case CityWithCountry(countryname : String)
}

extension CountryNetwoking : TargetType {
    
    var baseURL: String {
        "http://api.airvisual.com/v2/"
    }
    
    var path: String {
        switch self {
        case .Country, .CityWithCountry:
            return "countries"
        default:
            return ""
        }
    }
    
    var param: Parameters {
        return ["key" : "2768dcd1-4be3-45a9-89c7-b35e29a7012e"]
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .Country,
             .CityWithCountry:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        return ["Content-Type" : "application/json"]
    }
    
    var url: URL {
        return URL(string: self.baseURL + self.path)!
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .CityWithCountry, .Country:
            return JSONEncoding.default
        }
    }
    
    
}
