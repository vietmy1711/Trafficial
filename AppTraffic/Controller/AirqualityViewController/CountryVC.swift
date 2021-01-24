//
//  CountryVC.swift
//  AppTraffic
//
//  Created by MAC OS on 09/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class CountryVC: UIViewController {

    var searchActive : Bool = false
    var filtered:[CountryModel] = []
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    var listcountry = [CountryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    func setupUI(){
        searchbar.delegate = self
        searchbar.isTranslucent = true
        searchbar.isUserInteractionEnabled = true
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.register(UINib(nibName: "CountryCell", bundle: nil), forCellWithReuseIdentifier: "cellcountry")
    }
    
    func fetchData() {
        let queue = DispatchQueue(label: "loadcountry")
        queue.async {
                AirAPI.instance.fetchCountry { [weak self] (result) in
                self?.listcountry = result
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

extension CountryVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        } else {
            return listcountry.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "cellcountry", for: indexPath) as! CountryCell
        if searchActive {
            cell.configcell(country: filtered[indexPath.row].namecountry ?? "")
        } else {
            cell.configcell(country: listcountry[indexPath.row].namecountry ?? "")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cityVC = StateVC()
        if searchActive {
            cityVC.country = filtered[indexPath.row].namecountry
        } else {
            cityVC.country = listcountry[indexPath.row].namecountry
        }
        cityVC.modalPresentationStyle = .fullScreen
        self.present(cityVC, animated: true)
    }
    
}

extension CountryVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension CountryVC : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            searchActive = false
            collectionview.reloadData()
        } else {
            searchActive = true
            filtered = listcountry.filter({ (country) -> Bool in
                (country.namecountry?.contains(searchBar.text ?? "") ?? false)
            })
            collectionview.reloadData()
        }
    }
}

