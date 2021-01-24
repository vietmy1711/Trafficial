//
//  BasicMapViewController.swift
//  AppTraffic
//
//  Created by MM on 11/10/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMobileAds
import Toast_Swift
import FirebaseFirestore
import GoogleMapsUtils

class BasicMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnClearMarker: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    var bannerView: GADBannerView!
    
    var locationManager: CLLocationManager!
    var currentLocationCoordinate: CLLocationCoordinate2D!
    var firstTime = true
    
    var reportViewModel: ReportViewModel?
    
    let db = Firestore.firestore()
    
    var listener: ListenerRegistration!
    
    var floods: [GeoPoint] = [] {
        didSet {
            self.checkDistance()
        }
    }
    var incidents: [GeoPoint] = [] {
        didSet {
            self.checkDistance()
        }
    }
    var trafficJams: [GeoPoint] = [] {
        didSet {
            self.checkDistance()
        }
    }
    
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
        setupMarkerClustering()
        setupStyle()
        setupAds()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reportViewModel?.stopListening()
    }
    
    private func setupUI() {
        btnClearMarker.isHidden = true
        
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
    }
    
    private func setupMap() {
        mapView.delegate = self
        mapView.settings.compassButton = true
        mapView.isTrafficEnabled = true
        mapView.isMyLocationEnabled = true
        mapView.mapType = .normal
        mapView.settings.myLocationButton = true
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
    
    @IBAction func clearAllMarkersClicked(_ sender: UIButton) {
        mapView.clear()
        btnClearMarker.isHidden = true
    }
    
    func setupAds() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    private func handleFailToReport() {
        self.view.makeToast("Fail to report!")
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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

//MARK: - GMSMapViewDelegate

extension BasicMapViewController: GMSMapViewDelegate {
    //    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    //        let marker = GMSMarker(position: coordinate)
    //        marker.isDraggable = true
    //        marker.map = mapView
    //
    //        btnClearMarker.isHidden = false
    //
    //        let geocoder = GMSGeocoder()
    //        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
    //            guard error == nil else { return }
    //            if let result = response?.firstResult() {
    //                let marker = GMSMarker()
    //                if result.lines?.count ?? 0 > 0 {
    //                    if let title = result.lines?[0] {
    //                        marker.title = title
    //                    }
    //                    if result.lines?.count ?? 0 > 1 {
    //                        if let snippet = result.lines?[1] {
    //                            marker.snippet = snippet
    //                        }
    //                    }
    //                    marker.map = mapView
    //                }
    //
    //            }
    //        }
    //    }
}

//MARK: - CLLocationManagerDelegate

extension BasicMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocationCoordinate = locations.last?.coordinate
        if firstTime {
            mapView.camera = GMSCameraPosition.camera(withTarget: currentLocationCoordinate, zoom: 16)
            firstTime = false
        }
    }
}

//MARK: - ReportViewModelEvents

extension BasicMapViewController: ReportViewModelEvents {
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
