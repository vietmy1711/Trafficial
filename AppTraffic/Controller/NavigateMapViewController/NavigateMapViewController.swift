//
//  NavigateMapViewController.swift
//  AppTraffic
//
//  Created by MM on 23/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class NavigateMapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var startDrivingButton: UIButton!
    @IBOutlet weak var currentLocationSwitch: UISwitch!
    @IBOutlet weak var backButton: UIButton!
    
    var placesClient = GMSPlacesClient()
    var resultsViewController = GMSAutocompleteResultsViewController()
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D!
    var firstTime = true
    
    var lat: Double = 0
    var lon: Double = 0
    
    var totalDistance: Int = 0
    var totalDuration: Int = 0
    
    var sourceMarker: GMSMarker?
    var sourcePlace: PlaceModel?
    
    var destinationMarker: GMSMarker?
    var destinationPlace: PlaceModel?
    
    var polyline: GMSPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocation()
        setupMap()
        setupStyle()
        setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 16
        
        backButton.layer.cornerRadius = 30
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.2
        backButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        backButton.layer.shadowRadius = 5
        
        startDrivingButton.isEnabled = false
    }
    
    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    private func setupMap() {
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.mapType = .normal
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: containerView.bounds.height + 4, right: 0)
        guard let coordinate = mapView.myLocation?.coordinate else { return }
        mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 16)
    }
    
    private func setupStyle() {
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: MapStyle.shared.standardMode)
        }  catch {
            print("error loading map style")
        }
    }
    
    private func setupTextField() {
        originTextField.addTarget(self, action: #selector(autocompleteClicked(_:)), for: .touchDown)
        destinationTextField.addTarget(self, action: #selector(autocompleteClicked(_:)), for: .touchDown)

    }
    
    @objc func autocompleteClicked(_ sender: UITextField) {
        let autocompleteController = SearchMapViewController()
        if sender == destinationTextField {
            autocompleteController.toGo = true
        }
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func setDesinationWithPlace(place: PlaceModel) {
        destinationTextField.text = place.name
        destinationPlace = place
        mapView.clear()
        destinationMarker = GMSMarker(position: place.coordinate)
        destinationMarker?.icon = GMSMarker.markerImage(with: .systemPink)
        destinationMarker?.appearAnimation = .pop
        destinationMarker?.title = place.name
        destinationMarker?.snippet = place.address
        destinationMarker?.map = mapView
        mapView.animate(toLocation: destinationPlace!.coordinate)
        if currentLocationSwitch.isOn {
            guard let currentLat = self.mapView.myLocation?.coordinate.latitude else { return }
            guard let currentLon = self.mapView.myLocation?.coordinate.longitude else { return }
            let currentLocation = PlaceModel(name: "", address: "", coordinate: CLLocationCoordinate2DMake(currentLat, currentLon))
            drawRoute(currentLocation, destinationPlace!)
            return
        }
        if var origin = sourcePlace {
            if origin.coordinate.latitude == -180 && origin.coordinate.longitude == -180 {
                origin.coordinate = CLLocationCoordinate2DMake(lat, lon)
                sourcePlace!.coordinate = CLLocationCoordinate2DMake(lat, lon)
            }
            sourceMarker = GMSMarker(position: origin.coordinate)
            sourceMarker?.icon = GMSMarker.markerImage(with: .blue)
            sourceMarker?.appearAnimation = .pop
            sourceMarker?.title = origin.name
            sourceMarker?.snippet = origin.address
            sourceMarker?.map = mapView
            drawRoute(origin, destinationPlace!)
        } 
    }
    
    func setOriginWithPlace(place: PlaceModel) {
        originTextField.text = place.name
        sourcePlace = place
        mapView.clear()
        sourceMarker = GMSMarker(position: place.coordinate)
        sourceMarker?.icon = GMSMarker.markerImage(with: .blue)
        sourceMarker?.appearAnimation = .pop
        sourceMarker?.title = place.name
        sourceMarker?.snippet = place.address
        sourceMarker?.map = mapView
        mapView.animate(toLocation: sourcePlace!.coordinate)
        if let destination = destinationPlace {
            destinationMarker = GMSMarker(position: destination.coordinate)
            destinationMarker?.icon = GMSMarker.markerImage(with: .systemPink)
            destinationMarker?.appearAnimation = .pop
            destinationMarker?.title = destination.name
            destinationMarker?.snippet = destination.address
            destinationMarker?.map = mapView
            drawRoute(sourcePlace!, destination)
        }
    }
    
    func focusMapToShowAllMarkers() {
        guard let destination = destinationPlace else { return }
        if let source = sourcePlace {
            let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: destination.coordinate, coordinate: source.coordinate)
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 15.0))
        } else if let currentCoordinate = mapView.myLocation?.coordinate {
            let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: destination.coordinate, coordinate: currentCoordinate)
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 15.0))
        }
    }
    
    func drawRoute(_ originPlace: PlaceModel, _ destinationPlace: PlaceModel) {
        MapAPI.shared.fetchDirection(originPlace: originPlace, destinationPlace: destinationPlace) { [weak self] (direction) in
            var distance: Int = 0 //1000 distance = 1km
            var duration: Int = 0 //1 duration = 1 second
            guard let routes = direction.routes else { return }
            for route in routes {
                guard let points = route?.polyline?.points else { return }
                let path = GMSPath.init(fromEncodedPath: points)
                guard let legs = route?.legs else { return }
                for leg in legs {
                    distance += leg.distance?.value ?? 0
                    duration += leg.duration?.value ?? 0
                }
                self?.polyline = GMSPolyline(path: path)
                self?.polyline?.strokeColor = .systemBlue
                self?.polyline?.strokeWidth = 10.0
                self?.polyline?.map = self?.mapView
            }
            self?.calculate(distance: distance, duration: duration)
            self?.focusMapToShowAllMarkers()
        }
    }
    
    func calculate(distance: Int, duration: Int) {
        totalDistance = distance
        totalDuration = duration
    }
    
    @IBAction func toggleTrafficSwitch(_ sender: UISwitch) {
        mapView.isTrafficEnabled = sender.isOn
    }
    
    @IBAction func toggleUseCurrentLocationSwitch(_ sender: UISwitch) {
        originTextField.isUserInteractionEnabled = !sender.isOn
        startDrivingButton.isEnabled = sender.isOn
        if sender.isOn {
            originTextField.text = ""
        }
        if let source = sourcePlace {
            setOriginWithPlace(place: source)
        }
        if let destination = destinationPlace {
            setDesinationWithPlace(place: destination)
        }
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearBtnClicked(_ sender: UIButton) {
        mapView.clear()
        sourcePlace = nil
        destinationPlace = nil
        polyline = nil
        totalDistance = 0
        totalDuration = 0
        originTextField.text = ""
        destinationTextField.text = ""
        startDrivingButton.isEnabled = false
    }
    
    @IBAction func startDrivingBtnClicked(_ sender: UIButton) {
        let drivingMapVC = DrivingViewController()
        drivingMapVC.destinationPlace = destinationPlace
        drivingMapVC.polyline = self.polyline
        self.navigationController?.pushViewController(drivingMapVC, animated: true)
    }
}

//MARK: - CLLocationManagerDelegate

extension NavigateMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
        if firstTime {
            mapView.camera = GMSCameraPosition.camera(withTarget: currentLocation, zoom: 16)
            firstTime = false
        }
    }
}

//MARK: - SearchMapViewControllerDelegate

extension NavigateMapViewController: SearchMapViewControllerDelegate {
    
    func didUpdateWithPlace(place: PlaceModel, toGo: Bool) {
        if toGo == true {
            setDesinationWithPlace(place: place)
            if currentLocationSwitch.isOn {
                self.startDrivingButton.isEnabled = true
            }
        } else {
            setOriginWithPlace(place: place)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

