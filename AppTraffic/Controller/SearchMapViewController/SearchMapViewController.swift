//
//  SearchMapViewController.swift
//  AppTraffic
//
//  Created by MM on 23/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit
import GooglePlaces

protocol SearchMapViewControllerDelegate {
    func didUpdateWithPlace(place: PlaceModel, toGo: Bool)
    func didFailWithError(error: Error)
}

class SearchMapViewController: UIViewController {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var delegate: SearchMapViewControllerDelegate?
    
    var toGo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 350.0, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        //        searchController?.searchBar.becomeFirstResponder()
        let filter = GMSAutocompleteFilter()
        filter.country = "vn"
        filter.type = .noFilter
        resultsViewController?.autocompleteFilter = filter
    }
}

// Handle the user's selection.
extension SearchMapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false

        let place = PlaceModel(name: place.name ?? "No name", address: place.formattedAddress ?? "No address", coordinate: place.coordinate)
        delegate?.didUpdateWithPlace(place: place, toGo: toGo)
        self.dismiss(animated: true)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        delegate?.didFailWithError(error: error)
    }
}

