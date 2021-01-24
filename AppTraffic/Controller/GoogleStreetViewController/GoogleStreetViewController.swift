//
//  GoogleStreetViewController.swift
//  AppTraffic
//
//  Created by MM on 16/11/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleStreetViewController: UIViewController {

    @IBOutlet weak var panoramaView: GMSPanoramaView!
    @IBOutlet weak var backButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
//        setupPanoramaView()
        setupLocation()
    }
    
    private func setupUI() {
        backButton.layer.cornerRadius = 30
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.2
        backButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        backButton.layer.shadowRadius = 5
    }

    private func setupPanoramaView() {
        panoramaView.moveNearCoordinate(CLLocationCoordinate2D(latitude: -33.732, longitude: 150.312))
    }
    
    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - CLLocationManagerDelegate

extension GoogleStreetViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if firstTime {
            guard let lastestLocation = locations.last else { return }
            firstTime = false
            panoramaView.moveNearCoordinate(lastestLocation.coordinate)
        }
    }
}
