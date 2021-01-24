//
//  AppDelegate.swift
//  AppTraffic
//
//  Created by Edward Lauv on 10/7/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey(APIKey.shared.googleMapsAPI)
        GMSPlacesClient.provideAPIKey(APIKey.shared.googleMapsAPI)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "1598dc7e8461c28572e6a0484fd0fef7", "7f8b64d38cc458061dd00b91802d6e5a" ];
        window = UIWindow(frame: UIScreen.main.bounds)
        if UserDefaultsDataStore.userdeaultsdatastore.fetch(type: String.self, forKey: USER_ID) != nil {
            window?.rootViewController = AirQualityVC()
        } else {
            window?.rootViewController = SignInViewController()
        }
        window?.makeKeyAndVisible()
        return true
    }
}

