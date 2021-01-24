//
//  CityVC.swift
//  AppTraffic
//
//  Created by MAC OS on 09/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class CityVC: UIViewController {

    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var namestateLabel: UILabel!
    
    var listcity = [City]()
    var listfilterdcity = [City]()
    var searchActive : Bool = false
    var namestate : String?
    var namecountry : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        setupUI()
    }
    
    func setupUI() {
        searchBar.delegate = self
        namestateLabel.text = namestate
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.register(UINib(nibName: "CityCell", bundle: nil), forCellWithReuseIdentifier: "citycell")
    }
    
    func fetchData() {
        let queue = DispatchQueue(label: "loadcity")
        queue.async {
            AirAPI.instance.fetchCity(namestate: self.namestate ?? "", namecountry: self.namecountry ?? "") { [weak self] (results) in
                self?.listcity = results
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

extension CityVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return listfilterdcity.count
        } else {
            return listcity.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "citycell", for: indexPath) as! CityCell
        if searchActive {
            cell.configcell(city: listfilterdcity[indexPath.row].namecity)
        } else {
            cell.configcell(city: listcity[indexPath.row].namecity)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = DetailAirqualityCityVC()
        detail.modalPresentationStyle = .fullScreen
        if searchActive {
            detail.namecity = listfilterdcity[indexPath.row].namecity
        } else {
            detail.namecity = listcity[indexPath.row].namecity
        }
        guard let namestate = namestate else {
            return
        }
        detail.namestate = namestate
        guard let namecountry = namecountry else {
            return
        }
        detail.namecountry = namecountry
        self.present(detail, animated: true, completion: nil)
    }
    
}

extension CityVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 50)
    }
}

extension CityVC : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchActive = false
            collectionview.reloadData()
        } else {
            searchActive = true
            listfilterdcity = listcity.filter({ (City) -> Bool in
                (City.namecity.contains(searchBar.text ?? ""))
            })
            collectionview.reloadData()
        }
    }
}
