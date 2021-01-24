//
//  DrivingViewController.swift
//  AppTraffic
//
//  Created by MM on 12/01/2021.
//  Copyright © 2021 Edward Lauv. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseFirestore
import GoogleMapsUtils

class DrivingViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    var reportViewModel: ReportViewModel?
    
    var locationManager: CLLocationManager!
    
    var destinationPlace: PlaceModel?
    var polyline: GMSPolyline?
    
    private var floodClusterManager: GMUClusterManager!
    private var incidentClusterManager: GMUClusterManager!
    private var trafficJamClusterManager: GMUClusterManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportViewModel = ReportViewModel(delegate: self)
        reportViewModel?.startListening()
        setupUI()
        setupLocation()
        setupMap()
        setupMarker()
        setupStyle()
        setupMarkerClustering()
        drawRoute()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reportViewModel?.stopListening()
    }
    
    func setupUI() {
        reportButton.layer.cornerRadius = 30
        reportButton.layer.shadowColor = UIColor.black.cgColor
        reportButton.layer.shadowOpacity = 0.2
        reportButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        reportButton.layer.shadowRadius = 5
        
        backButton.layer.cornerRadius = 30
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.2
        backButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        backButton.layer.shadowRadius = 5
    }
    
    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func setupMap() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.isTrafficEnabled = true
        guard let coordinate = mapView.myLocation?.coordinate else { return }
        mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 16)
    }
    
    private func setupStyle() {
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: MapStyle.shared.nightMode)
        }  catch {
            print("error loading map style")
        }
    }
    
    func setupMarker() {
        guard let destinationPlace = destinationPlace else { return }
        let marker = GMSMarker(position: destinationPlace.coordinate)
        marker.title = destinationPlace.name
        marker.snippet = destinationPlace.address
        marker.map = self.mapView
    }
    
    func drawRoute() {
        guard let path = polyline?.path else { return }
        let gmsPolyline = GMSPolyline(path: path)
        gmsPolyline.strokeColor = .systemBlue
        gmsPolyline.strokeWidth = 10.0
        gmsPolyline.map = self.mapView
    }
    
    private func handleFailToReport() {
        self.view.makeToast("Fail to report!")
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reportBtnClicked(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Report", message: "Choose a type", preferredStyle: .actionSheet)
        let incident = UIAlertAction(title: "Incident", style: .default) { (_) in
            guard let coordinate = self.mapView.myLocation?.coordinate else {
                self.handleFailToReport()
                return
            }
            self.reportViewModel?.reportNewIncident(incident: coordinate)
        }
        actionSheet.addAction(incident)
        
        let trafficJam = UIAlertAction(title: "Traffic jam", style: .default) { (_) in
            guard let coordinate = self.mapView.myLocation?.coordinate else {
                self.handleFailToReport()
                return
            }
            self.reportViewModel?.reportNewTrafficJam(trafficJam: coordinate)
        }
        actionSheet.addAction(trafficJam)
        
        let flood = UIAlertAction(title: "Flood", style: .default) { (_) in
            guard let coordinate = self.mapView.myLocation?.coordinate else {
                self.handleFailToReport()
                return
            }
            self.reportViewModel?.reportNewFlood(flood: coordinate)
        }
        actionSheet.addAction(flood)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func setupMarkerClustering() {
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        
        let floodIcon = GMUDefaultClusterIconGenerator(buckets: [100], backgroundColors: [.blue])
        let floodRender = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: floodIcon)
        floodClusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: floodRender)
        floodClusterManager.setMapDelegate(self)
        
        let incidentIcon = GMUDefaultClusterIconGenerator(buckets: [100], backgroundColors: [.black])
        let incidentRenderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: incidentIcon)
        incidentClusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: incidentRenderer)
        incidentClusterManager.setMapDelegate(self)
        
        let trafficJamIcon = GMUDefaultClusterIconGenerator(buckets: [100], backgroundColors: [.brown])
        let trafficJamRenderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: trafficJamIcon)
        
        trafficJamClusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: trafficJamRenderer)
        trafficJamClusterManager.setMapDelegate(self)
    }
    
    func checkDistance() {
        mapView.clear()
        floodClusterManager.clearItems()
        incidentClusterManager.clearItems()
        trafficJamClusterManager.clearItems()
        drawRoute()
        
        guard let reportViewModel = reportViewModel else { return }
        for flood in reportViewModel.floods {
            let location = CLLocation(latitude: flood.latitude, longitude: flood.longitude)
            let marker = GMSMarker(position: location.coordinate)
            marker.title = "Flood"
            marker.icon = GMSMarker.markerImage(with: UIColor.blue)
            floodClusterManager.add(marker)
        }
        floodClusterManager.cluster()
        
        for incident in reportViewModel.incidents {
            let location = CLLocation(latitude: incident.latitude, longitude: incident.longitude)
            let marker = GMSMarker(position: location.coordinate)
            marker.title = "Incident"
            marker.icon = GMSMarker.markerImage(with: UIColor.black)
            incidentClusterManager.add(marker)
        }
        incidentClusterManager.cluster()
        
        for trafficJam in reportViewModel.trafficJams {
            let location = CLLocation(latitude: trafficJam.latitude, longitude: trafficJam.longitude)
            let marker = GMSMarker(position: location.coordinate)
            marker.title = "Traffic Jam"
            marker.icon = GMSMarker.markerImage(with: UIColor.yellow)
            trafficJamClusterManager.add(marker)
        }
        trafficJamClusterManager.cluster()
    }
}

extension DrivingViewController: GMSMapViewDelegate {
}

extension DrivingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = mapView.myLocation else { return }
        mapView.animate(toViewingAngle: 60)
        mapView.animate(toZoom: 18)
        mapView.animate(toLocation: location.coordinate)
//        mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapView.animate(toBearing: newHeading.trueHeading)
    }
}

//MARK: - ReportViewModelEvents

extension DrivingViewController: ReportViewModelEvents {
    func newFloodReported(flood: GeoPoint) {
        guard let currentLocation = self.mapView.myLocation else { return }
        let distance = currentLocation.distance(from: CLLocation(latitude: flood.latitude, longitude: flood.longitude))
        if distance <= 1000 {
            self.view.makeToast("Flood reported nearby: \(Double(round(10*distance)/10)) meters away")
        }
    }
    
    func newIncidentReported(incident: GeoPoint) {
        guard let currentLocation = self.mapView.myLocation else { return }
        let distance = currentLocation.distance(from: CLLocation(latitude: incident.latitude, longitude: incident.longitude))
        if distance <= 1000 {
            self.view.makeToast("Incident reported nearby: \(Double(round(10*distance)/10)) meters away")
        }
    }
    
    func newTrafficJamReported(trafficJam: GeoPoint) {
        guard let currentLocation = self.mapView.myLocation else { return }
        let distance = currentLocation.distance(from: CLLocation(latitude: trafficJam.latitude, longitude: trafficJam.longitude))
        if distance <= 1000 {
            self.view.makeToast("Traffic jam reported nearby: \(Double(round(10*distance)/10)) meters away")
        }
    }
    
    func didUpdate() {
        checkDistance()
    }
}
