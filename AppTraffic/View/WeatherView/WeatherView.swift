//
//  WeatherView.swift
//  AppTraffic
//
//  Created by Edward Lauv on 1/6/21.
//  Copyright © 2021 Edward Lauv. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class WeatherView: UIView {
    
    let animationView = AnimationView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        guard let view = loadViewFromNib(nibName: className.self) else {
            return
        }
        view.frame = self.bounds
        view.addSubview(animationView)
        self.addSubview(view)
    }
    func setupAnimation(nameAnimation : String){
        animationView.animation = Animation.named(nameAnimation)
        animationView.frame = self.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        self.addSubview(animationView)
    }
}
