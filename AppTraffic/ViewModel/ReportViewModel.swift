//
//  ReportViewModel.swift
//  AppTraffic
//
//  Created by MM on 12/01/2021.
//  Copyright © 2021 Edward Lauv. All rights reserved.
//

import FirebaseFirestore
import CoreLocation

protocol ReportViewModelProtocols:class {
    func startListening()
    func stopListening()
    
    func reportNewFlood(flood: CLLocationCoordinate2D)
    func reportNewIncident(incident: CLLocationCoordinate2D)
    func reportNewTrafficJam(trafficJam: CLLocationCoordinate2D)
}

protocol ReportViewModelEvents:class {
    func newFloodReported(flood: GeoPoint)
    func newIncidentReported(incident: GeoPoint)
    func newTrafficJamReported(trafficJam: GeoPoint)
    func didUpdate()
}

class ReportViewModel: ReportViewModelProtocols {
       
    weak var delegate: ReportViewModelEvents?
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration!
    
    var floods: [GeoPoint] = [] {
        didSet {
            delegate?.didUpdate()
        }
    }
    var incidents: [GeoPoint] = [] {
        didSet {
            delegate?.didUpdate()
        }
    }
    var trafficJams: [GeoPoint] = [] {
        didSet {
            delegate?.didUpdate()
        }
    }
    
    init(delegate: ReportViewModelEvents) {
        self.delegate = delegate
    }
    
    func startListening() {
        listener = db.collection("REPORTS").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else { return }
            guard let documents = querySnapshot?.documents else {
                print("Error fetching document: \(error!)")
                return
            }
            let floodsData = documents[0].data()
            let incidentsData = documents[1].data()
            let trafficJamsData = documents[2].data()
            
            self?.floods = floodsData["floods"] as! [GeoPoint]
            self?.incidents = incidentsData["incidents"] as! [GeoPoint]
            self?.trafficJams = trafficJamsData["trafficjams"] as! [GeoPoint]
            
            querySnapshot?.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    let data = diff.document.data()
                    if let _ = data["floods"] {
                        guard let latestFlood = self?.floods.last else { return }
                        self?.delegate?.newFloodReported(flood: latestFlood)
                    }
                    if let _ = data["incidents"] {
                        guard let latestIncidents = self?.incidents.last else { return }
                        self?.delegate?.newIncidentReported(incident: latestIncidents)
                    }
                    if let _ = data["trafficjams"] {
                        guard let latestTrafficJam = self?.trafficJams.last else { return }
                        self?.delegate?.newTrafficJamReported(trafficJam: latestTrafficJam)
                    }
                }
            }
        }
    }
    
    func stopListening() {
        listener.remove()
    }
    
    func reportNewFlood(flood: CLLocationCoordinate2D) {
        self.db.collection("REPORTS").document("Floods").updateData([
            "floods" : FieldValue.arrayUnion([GeoPoint(latitude: flood.latitude, longitude: flood.longitude)])
        ])
    }
    
    func reportNewIncident(incident: CLLocationCoordinate2D) {
        self.db.collection("REPORTS").document("Indicents").updateData([
            "incidents" : FieldValue.arrayUnion([GeoPoint(latitude: incident.latitude, longitude: incident.longitude)])
        ])
    }
    
    func reportNewTrafficJam(trafficJam: CLLocationCoordinate2D) {
        self.db.collection("REPORTS").document("TrafficJams").updateData([
            "trafficjams" : FieldValue.arrayUnion([GeoPoint(latitude: trafficJam.latitude, longitude: trafficJam.longitude)])
        ])
    }
}
