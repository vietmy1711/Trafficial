//
//  AirApi.swift
//  AppTraffic
//
//  Created by MAC OS on 11/26/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation
import Alamofire

class AirAPI {
    static var instance = AirAPI()
    private init () {
        
    }
    
    func fetchCountry(completion: @escaping ([CountryModel])->Void) {
        AF.request("http://api.airvisual.com/v2/countries?key=\(APIKey.shared.airqualityAPI)").responseJSON { (data) in
            switch data.result {
            case .success(_):
                do {
                    let listcountry = try JSONDecoder().decode(Data.self, from: data.data!)
                    completion(listcountry.data!)
                } catch let error as NSError{
                    print("Failed to load: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Request error: \(error.localizedDescription)")
            }
        }
    }
    func fetchState(namecountry: String, completion: @escaping(([state]) -> Void)) {
        guard let country = namecountry.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else { return }

        AF.request("http://api.airvisual.com/v2/states?country=\(country)&key=\(APIKey.shared.airqualityAPI)").responseJSON { (data) in
            switch data.result {
            case .success(_):
                do {
                    let Statewithcountry = try JSONDecoder().decode(Datastate.self, from: data.data!)
                    completion(Statewithcountry.data!)
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("request error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchCity(namestate : String ,namecountry: String, completion: @escaping(([City]) -> Void)) {
            guard let state = namestate.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else { return }
            guard let country = namecountry.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else { return }

            let url = "http://api.airvisual.com/v2/cities?state=\(state)&country=\(country)&key=\(APIKey.shared.airqualityAPI)"
            AF.request(url).responseJSON { (data) in
                switch data.result {
                case .success(_):
                    do {
                        let citywithState = try JSONDecoder().decode(DataCity.self, from: data.data!)
                        completion(citywithState.data!)
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("request error: \(error.localizedDescription)")
                }
            }
        }
    
    func fetchNearestCity(completion: @escaping((datanaircity) -> Void)) {
        AF.request("http://api.airvisual.com/v2/nearest_city?key=\(APIKey.shared.airqualityAPI)").responseJSON { (data) in
            switch data.result {
            case .success(_):
                do {
                    let nearest = try JSONDecoder().decode(datanaircity.self, from: data.data!)
                    completion(nearest)
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("request error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchAirQuality(namecity: String, namestate: String, namecountry: String, completion: @escaping ((datanaircity) -> Void)) {
        guard let city = namecity.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else { return }
        guard let state = namestate.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else { return }
        guard let country = namecountry.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else { return }

        AF.request("http://api.airvisual.com/v2/city?city=\(city)&state=\(state)&country=\(country)&key=\(APIKey.shared.airqualityAPI)").responseJSON { (data) in
        switch data.result {
        case .success(_):
            do {
                let nearest = try JSONDecoder().decode(datanaircity.self, from: data.data!)
                completion(nearest)
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        case .failure(let error):
            print("request error: \(error.localizedDescription)")
        }
    }
    }
}
