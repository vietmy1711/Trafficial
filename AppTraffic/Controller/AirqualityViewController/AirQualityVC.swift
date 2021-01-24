//
//  AirQualityVC.swift
//  AppTraffic
//
//  Created by MAC OS on 10/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class AirQualityVC: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var weatherView: WeatherView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var morecity: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var namecityLabel: UILabel!
    @IBOutlet weak var viewnearestCity: WeatherView!
    @IBOutlet weak var weathertodayLabel: UILabel!
    let userdata = UserDefaultsDataStore()
    
    @IBOutlet weak var recommendLabel: UILabel!
    
    //var feature : [Dictionary] = ["":"", "":"", "":"", "":""]
    var recommendString : [String] = ["Today is a beautiful day, it's clear, you should go out and get active, it is very suitable for playing sports and meeting friends","Today is a rainy day, you should bring a raincoat, it might be windy, you should watch the wind to see if you should go outside, limit going out if you are not busy","Today is a bad day, it might be windy, or thunderstorm, or snow, don't go out. maybe choose some activities at home to get out of the way at this time"]
    
    var activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
    var nearestCity : datanaircity?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        weatherView.animationView.play()
        viewnearestCity.animationView.play()
    }
    
    func fetchData() {
        ActivityIndicator.show(in: self)
        view.addSubview(activityIndicator)
        let queue = DispatchQueue(label: "load")
        queue.async {
            AirAPI.instance.fetchNearestCity { [weak self] (data) in
                self?.nearestCity = data
                if let userid = UserDefaultsDataStore.userdeaultsdatastore.fetch(type: String.self, forKey: USER_ID) {
                    UserNetworking.instance.loadimageFromFirebase(userid) {  (image) in
                        DispatchQueue.main.async {
                            self?.avatarImageView.image = image
                            self?.setupUI()
                            ActivityIndicator.hide(in: self!)
                            self?.weatherView.animationView.play()
                            self?.viewnearestCity.animationView.play()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.setupUI()
                        ActivityIndicator.hide(in: self!)
                        self?.weatherView.animationView.play()
                        self?.viewnearestCity.animationView.play()
                    }
                }
            }
        }
    }
    
    func setupUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FeatureCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        avatarImageView.layer.cornerRadius = 25
        weatherView.setupAnimation(nameAnimation: weather(name:nearestCity?.data?.current?.weather?.ic ?? ""))
        viewnearestCity.setupAnimation(nameAnimation: "cityscape")
        let tap = UITapGestureRecognizer(target: self, action: #selector(showmorecity))
        morecity.isUserInteractionEnabled = true
        morecity.addGestureRecognizer(tap)
        viewnearestCity.bringSubviewToFront(namecityLabel)
        viewnearestCity.bringSubviewToFront(morecity)
        usernameLabel.text = userdata.fetch(type: String.self, forKey: USER_NAME) ?? ""
        
        activityIndicator.style = .medium
        viewnearestCity.layer.cornerRadius = 10
        //aqius.text = "AQI base on US: \(nearestCity?.data?.current?.pollution?.aqius ?? 0)"
        recommendLabel.text = recommendString[0]
        recommendLabel.isUserInteractionEnabled = true
        namecityLabel.text = nearestCity?.data?.city
        humidityLabel.text = String(nearestCity?.data?.current?.weather?.hu ?? 0) + "%"
        windLabel.text = String(nearestCity?.data?.current?.weather?.ws ?? 0) + " m/s"
        temperatureLabel.text = String(nearestCity?.data?.current?.weather?.tp ?? 0) + " C"
        let mystring = NSAttributedString(string: checkweather(name: nearestCity?.data?.current?.weather?.ic ?? ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        let first = NSMutableAttributedString(string: "Today is a ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        let last = NSAttributedString(string: " Day", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        first.append(mystring)
        first.append(last)
        weathertodayLabel.attributedText = first
        
    }
    
    @objc func showmorecity() {
        let countryVC = CountryVC()
        countryVC.modalPresentationStyle = .fullScreen
        self.present(countryVC, animated: true, completion: nil)
    }
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let logout = UIAlertAction(title: "Log out anway", style: .default) { (_) in
            self.handleLogout()
        }
        alert.addAction(logout)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogout() {
        ActivityIndicator.show(in: self)
        do {
            try Auth.auth().signOut()
        } catch {
            print("error")
        }
        UserDefaultsDataStore.userdeaultsdatastore.deleteAll()
        let login = SignInViewController()
        ActivityIndicator.hide(in: self)
        let keywindow = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
        keywindow?.rootViewController = login

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
    
    func weather(name: String) -> String{
        var weather : String = ""
        switch name {
        case "01d", "01n":
            weather = "sunny"
        case "02d", "02n":
            weather = "windy"
        case "03d", "04d":
            weather = "partlycloudy"
        case "09d","10d", "10n":
            weather = "partlyshower"
        case "11d":
            weather = "thunder"
        case "13d":
            weather = "snowsunny"
        default:
            return ""
        }
        return weather
    }
    
}

extension AirQualityVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FeatureCollectionViewCell
        switch indexPath.row {
        case 0:
            cell.setupUI(image: "basicmap", name: "Basic Map")
        case 1:
            cell.setupUI(image: "negativemap", name: "Navigate Map")
        case 2:
            cell.setupUI(image: "traffic", name: "Street View")
        default:
            cell.setupUI(image: "compass", name: "Compass")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let basicMapVC = BasicMapViewController()
            basicMapVC.modalPresentationStyle = .fullScreen
            self.present(basicMapVC, animated: true, completion: nil)
        case 1:
            let navMapVC = NavigateMapViewController()
            let navVC = UINavigationController(rootViewController: navMapVC)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true, completion: nil)
        case 2:
            let streetViewVC = GoogleStreetViewController()
            streetViewVC.modalPresentationStyle = .fullScreen
            self.present(streetViewVC, animated: true, completion: nil)
        default:
            let compassVC = CompassViewController()
            compassVC.modalPresentationStyle = .fullScreen
            self.present(compassVC, animated: true, completion: nil)
        }
    }
}

extension AirQualityVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: collectionView.bounds.height)
        //CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
