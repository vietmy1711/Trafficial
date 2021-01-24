//
//  MapAPI.swift
//  AppTraffic
//
//  Created by MM on 23/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation
import Alamofire

class MapAPI {
    static var shared = MapAPI()
    
    func fetchDirection(originPlace: PlaceModel, destinationPlace: PlaceModel ,completion: @escaping (DirectionModel)->Void) {
        let origin = "\(originPlace.coordinate.latitude),\(originPlace.coordinate.longitude)"
        let destination = "\(destinationPlace.coordinate.latitude),\(destinationPlace.coordinate.longitude)"

        AF.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(APIKey.shared.googleMapsAPI)").responseJSON { (data) in
            switch data.result {
            case .success(_):
                do {
                    let direction = try JSONDecoder().decode(DirectionModel.self, from: data.data!)
                    completion(direction)
                } catch let error as NSError{
                    print("Failed to load: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Request error: \(error.localizedDescription)")
            }
        }
    }
}
