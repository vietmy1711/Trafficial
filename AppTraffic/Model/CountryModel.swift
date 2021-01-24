//
//  CountryModel.swift
//  AppTraffic
//
//  Created by MAC OS on 11/26/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation

// status
struct Status : Decodable {
    var statuscountry : String?
    
    enum CodingKeys: String, CodingKey {
        case statuscountry = "status"
    }
}
// fetch country
struct CountryModel :Decodable {
    var namecountry: String?
    
    enum CodingKeys : String, CodingKey {
        case namecountry = "country"
    }
    
}

struct Data : Decodable {
    var data : [CountryModel]?
    
    enum CodingKeys : String, CodingKey {
        case data = "data"
    }
}
// fetch state
struct state : Decodable {
    var namestate: String?
    
    enum CodingKeys : String, CodingKey {
        case namestate = "state"
    }
}

struct Datastate : Decodable {
    var data : [state]?
    
    enum CodingKeys : String, CodingKey {
        case data = "data"
    }
}

// fetch city
struct City : Decodable {
    var namecity : String
    
    enum CodingKeys: String, CodingKey {
        case namecity = "city"
    }
}

struct DataCity : Decodable {
    var data : [City]?
    enum CodingKeys : String, CodingKey {
        case data = "data"
    }
}
