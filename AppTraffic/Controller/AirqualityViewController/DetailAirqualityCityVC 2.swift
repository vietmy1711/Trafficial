//
//  DetailAirqualityCityVC.swift
//  AppTraffic
//
//  Created by MAC OS on 11/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class DetailAirqualityCityVC: UIViewController {

    
    @IBOutlet weak var namecountryLabel: UILabel!
    @IBOutlet weak var namecityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var numerwindspeedLabel: UILabel!
    @IBOutlet weak var numbertemperLabel: UILabel!
    @IBOutlet weak var winddiLabel: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    @IBOutlet weak var humiLabel: UILabel!
    @IBOutlet weak var atmosLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    var aircity : datanaircity?
    var namecity : String = ""
    var namestate : String = ""
    var namecountry : String = ""
    var weatherString : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchdata()
    }
    func fetchdata() {
        let queue = DispatchQueue(label: "load")
        queue.async {
            AirAPI.instance.fetchAirQuality(namecity: self.namecity, namestate: self.namestate, namecountry: self.namecountry) { (data) in
                self.aircity = data
                DispatchQueue.main.async {
                    self.setupUI()
                }
                //print(self.aircity)
            }
        }
    }
    
    func setupUI() {
        self.namecityLabel.text = self.aircity?.data?.city
        self.namecountryLabel.text = self.aircity?.data?.country
        self.weatherLabel.text = checkweather(name: aircity?.data?.current?.weather?.ic ?? "")
        self.numbertemperLabel.text = String(self.aircity?.data?.current?.weather?.tp ?? 0) + "C"
        self.windspeedLabel.attributedText = setAttributes(firststring: "Wind speed ", secondestring: String(self.aircity?.data?.current?.weather?.ws ?? 0))
        self.winddiLabel.attributedText = setAttributes(firststring: "Wind Direction ", secondestring: String(self.aircity?.data?.current?.weather?.wd ?? 0))
        self.aqiLabel.attributedText = setAttributes(firststring: "AQI ", secondestring: String(self.aircity?.data?.current?.pollution?.aqius ?? 0))
        self.humiLabel.attributedText = setAttributes(firststring: "Humidity ", secondestring: String(self.aircity?.data?.current?.weather?.hu ?? 0))
        self.atmosLabel.attributedText = setAttributes(firststring: "Atmospheric ", secondestring: String(self.aircity?.data?.current?.weather?.pr ?? 0))
        self.numerwindspeedLabel.text = String(self.aircity?.data?.current?.weather?.ws ?? 0) + "m/s"
        self.temperatureLabel.attributedText = setAttributes(firststring: "Temperature ", secondestring: String(self.aircity?.data?.current?.weather?.tp ?? 0))
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
    
    func setAttributes(firststring: String, secondestring: String) -> NSMutableAttributedString {
        let stringattributes = NSMutableAttributedString()
        let firstAttr = NSAttributedString(string: firststring, attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        let secondAttr = NSAttributedString(string: secondestring, attributes: [NSAttributedString.Key.foregroundColor : UIColor.brown])
        stringattributes.append(firstAttr)
        stringattributes.append(secondAttr)
        return stringattributes
    }
}
