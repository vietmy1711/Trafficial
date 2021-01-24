//
//  CityCell.swift
//  AppTraffic
//
//  Created by MAC OS on 09/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class CityCell: UICollectionViewCell {

    @IBOutlet weak var namecity: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configcell(city : String) {
        namecity.text = city
    }

}
