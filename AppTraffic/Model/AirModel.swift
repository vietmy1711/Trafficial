//
//  AirModel.swift
//  AppTraffic
//
//  Created by MAC OS on 10/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation
//"location": {
//            "type": "Point",
//            "coordinates": [
//                106.700035,
//                10.782773
//            ]
//        }

struct location : Decodable {
    let type : String?
    let coordinates : [Float]?
    
    enum CodingKeys : String, CodingKey {
        case type = "type"
        case coordinates = "coordinates"
    }
}

struct weather : Decodable {
    let ts : String?
    let tp : Int?
    let pr : Int?
    let hu : Int?
    let ws : Float?
    let wd : Int?
    let ic : String?
    enum CodingKeys : String, CodingKey {
        case ts = "ts"
        case tp = "tp"
        case pr = "pr"
        case hu = "hu"
        case ws = "ws"
        case wd = "wd"
        case ic = "ic"
    }
}

struct pollution : Decodable {
    let ts : String?
    let aqius : Int?
    let mainus : String?
    let aqicn : Int?
    let maincn : String?
    
    enum CodingKeys : String, CodingKey {
        case ts = "ts"
        case aqius = "aqius"
        case mainus = "mainus"
        case aqicn = "aqicn"
        case maincn = "maincn"
    }
}

struct current : Decodable {
    let weather : weather?
    let pollution : pollution?
    
    enum CodingKeys : String, CodingKey {
        case weather = "weather"
        case pollution = "pollution"
    }
}

struct airtcity : Decodable {
    let city : String?
    let state : String?
    let country : String?
    let location : location?
    let current : current?
    
    enum CodingKeys : String, CodingKey {
        case city = "city"
        case state = "state"
        case country = "country"
        case location = "location"
        case current = "current"
    }
}
struct datanaircity : Decodable {
    let data : airtcity?
    enum CodingKeys : String, CodingKey {
        case data = "data"
    }
}
