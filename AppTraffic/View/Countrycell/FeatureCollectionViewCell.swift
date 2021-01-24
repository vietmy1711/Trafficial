//
//  FeatureCollectionViewCell.swift
//  AppTraffic
//
//  Created by Edward Lauv on 1/5/21.
//  Copyright © 2021 Edward Lauv. All rights reserved.
//

import UIKit

class FeatureCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewbackground: UIView!
    @IBOutlet weak var imagebackground: UIImageView!
    @IBOutlet weak var namefeature: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(image : String, name : String) {
        viewbackground.layer.cornerRadius = 10
        imagebackground.layer.cornerRadius = 10
        imagebackground.image = UIImage(named: image)
        namefeature.text = name
    }

}
