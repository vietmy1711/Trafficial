//
//  AirQualityVC.swift
//  AppTraffic
//
//  Created by MAC OS on 10/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit
import CoreLocation

class AirQualityVC: UIViewController {
    
    @IBOutlet weak var morecity: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var namecityLabel: UILabel!
    @IBOutlet weak var aqius: UILabel!
    @IBOutlet weak var aqicnLabel: UILabel!
    @IBOutlet weak var viewnearestCity: UIView!
    @IBOutlet weak var weathertodayLabel: UILabel!
    
    @IBOutlet weak var recommendLabel: UILabel!
    var recommendString : [String] = ["Today is a beautiful day, it's clear, you should go out and get active, it is very suitable for playing sports and meeting friends","Today is a rainy day, you should bring a raincoat, it might be windy, you should watch the wind to see if you should go outside, limit going out if you are not busy","Today is a bad day, it might be windy, or thunderstorm, or snow, don't go out. maybe choose some activities at home to get out of the way at this time"]
    
    let activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
    var nearestCity : datanaircity?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData() {
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        let queue = DispatchQueue(label: "load")
        queue.async {
            AirAPI.instance.fetchNearestCity { (data) in
                print("---\(data)")
                self.nearestCity = data
                DispatchQueue.main.async {
                    self.setupUI()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func setupUI() {
        viewnearestCity.layer.cornerRadius = 10
        aqicnLabel.text = "AQI base on China: \(nearestCity?.data?.current?.pollution?.aqicn ?? 0)"
        aqius.text = "AQI base on US: \(nearestCity?.data?.current?.pollution?.aqius ?? 0)"
        namecityLabel.text = nearestCity?.data?.city
        humidityLabel.text = String(nearestCity?.data?.current?.weather?.hu ?? 0) + "%"
        windLabel.text = String(nearestCity?.data?.current?.weather?.ws ?? 0) + " m/s"
        temperatureLabel.text = String(nearestCity?.data?.current?.weather?.tp ?? 0) + " C"
        weatherImageView.image = UIImage(named: "\(nearestCity?.data?.current?.weather?.ic ?? "").png")
        let mystring = NSAttributedString(string: checkweather(name: nearestCity?.data?.current?.weather?.ic ?? ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        let first = NSMutableAttributedString(string: "Today is ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        let last = NSAttributedString(string: " Day", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        first.append(mystring)
        first.append(last)
        weathertodayLabel.attributedText = first
        switch checkweather(name: nearestCity?.data?.current?.weather?.ic ?? "") {
        case "Good":
            imageWeather.image = UIImage(named: "01.png")
            recommendLabel.text = recommendString[0]
        case "Rain":
            imageWeather.image = UIImage(named: "02.png")
            recommendLabel.text = recommendString[1]
        default:
            imageWeather.image = UIImage(named: "03.png")
            recommendLabel.text = recommendString[2]
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(showmorecity))
        morecity.isUserInteractionEnabled = true
        morecity.addGestureRecognizer(tap)
        
    }
    
    @objc func showmorecity() {
        let countryVC = CountryVC()
        countryVC.modalPresentationStyle = .fullScreen
        self.present(countryVC, animated: true, completion: nil)
    }
    
    func checkweather(name: String) -> String {
        var weather : String = ""
        switch name {
        case "01d", "01n", "02d", "02n", "03d", "04d":
            weather = "Good"
        case "09d", "10d", "10n":
            weather = "Rain"
        default:
            weather = "Bad"
        }
        return weather
    }
    
}
