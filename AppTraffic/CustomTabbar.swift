//
//  CustomTabbar.swift
//  AppTraffic
//
//  Created by Edward Lauv on 10/7/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit

class CustomTabbar: UITabBarController {
    
    let first = BasicMapViewController()
    let second = GoogleStreetViewController()
    let third = AirQualityVC()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        first.title = "Map"
        second.title = "Street"
        third.title = "Weather"
        
        first.tabBarItem.image = UIImage(systemName: "map")
        second.tabBarItem.image = UIImage(systemName: "map.fill")
        third.tabBarItem.image = UIImage(systemName: "house")
        
        viewControllers = [first, second, third]
    }


}
extension CustomTabbar: UITabBarControllerDelegate {
}
