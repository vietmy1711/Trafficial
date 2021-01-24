//
//  CountryCell.swift
//  AppTraffic
//
//  Created by MAC OS on 09/12/2020.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class CountryCell: UICollectionViewCell {

    @IBOutlet weak var namecountryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configcell(country : String) {
        namecountryLabel.text = country
    }

}
