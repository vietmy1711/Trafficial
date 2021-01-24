//
//  DirectionModel.swift
//  AppTraffic
//
//  Created by MM on 23/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation

struct DirectionModel: Decodable {
    var routes: [Route?]?
    
    enum CodingKeys : String, CodingKey {
        case routes
    }
}

struct Route: Decodable {
    var legs: [Leg]?
    var polyline: Polyline?
    enum CodingKeys : String, CodingKey {
        case legs
        case polyline = "overview_polyline"
    }
}

struct Leg: Decodable {
    var distance: Distance?
    var duration: Duration?
    enum CodingKeys : String, CodingKey {
        case distance
        case duration
    }
}

struct Distance: Decodable {
    var text: String?
    var value: Int?
    enum CodingKeys : String, CodingKey {
        case text
        case value
    }
}

struct Duration: Decodable {
    var text: String?
    var value: Int?
    enum CodingKeys : String, CodingKey {
        case text
        case value
    }
}

struct Polyline: Decodable {
    var points: String?
    enum CodingKeys : String, CodingKey {
        case points
    }
}
