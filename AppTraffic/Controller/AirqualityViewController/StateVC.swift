//
//  StateVC.swift
//  AppTraffic
//
//  Created by MAC OS on 09/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class StateVC: UIViewController {

    var searchActive : Bool = false
    var filtered:[state] = []
    @IBOutlet weak var namecountry: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionview: UICollectionView!
    var liststate = [state]()
    var country : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        setupUI()
    }
    
    func setupUI() {
        searchBar.delegate = self
        namecountry.text = country
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.register(UINib(nibName: "CityCell", bundle: nil), forCellWithReuseIdentifier: "citycell")
    }
    
    func fetchData() {
        let queue = DispatchQueue(label: "loadcity")
        queue.async {
            AirAPI.instance.fetchState(namecountry: self.country ?? "") {[weak self] (results) in
                self?.liststate = results
                DispatchQueue.main.async {
                    self?.collectionview.reloadData()
                }
            }
        }
    }
    @IBAction func clickback(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension StateVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        } else {
            return liststate.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "citycell", for: indexPath) as! CityCell
        if searchActive {
            cell.configcell(city: filtered[indexPath.row].namestate!)
        } else {
            
            cell.configcell(city: liststate[indexPath.row].namestate!)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cityVC = CityVC()
        if searchActive {
            cityVC.namestate = filtered[indexPath.row].namestate
        } else {
            cityVC.namestate = liststate[indexPath.row].namestate
        }
        cityVC.namecountry = country
        cityVC.modalPresentationStyle = .fullScreen
        self.present(cityVC, animated: true)
    }
}

extension StateVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 50)
    }
}

extension StateVC : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchActive = false
            collectionview.reloadData()
        } else {
            searchActive = true
            filtered = liststate.filter({ (state) -> Bool in
                (state.namestate?.contains(searchBar.text ?? "") ?? false)
            })
            collectionview.reloadData()
        }
    }
}



