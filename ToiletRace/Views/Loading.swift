//
//  Loading.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 22/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit

class Loading: UIView {
    
    var pooImage = UIImageView(image: UIImage(named: "poo0"))
    var timer = Timer()
    var animationCount = 0
    var label = UILabel()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor(red: 247/255, green: 253/255, blue: 1, alpha: 1)
        pooImage.center = center
        label.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        label.center = CGPoint(x: center.x, y: frame.height - 80)
        label.text = "LOADING..."
        label.textColor = UIColor.brown
        label.font = Font.with(.medium, 27)
        addSubview(pooImage)
        addSubview(label)
        alpha = 0
    }
    
    
    func startAnimating() {
        self.startTimer()
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 1
        }) { (_) in
            
        }
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0
        }) { (_) in
            self.timer.invalidate()
            self.removeFromSuperview()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
    }
    
    @objc func changeImage() {
        DispatchQueue.main.async {
            self.pooImage.image = UIImage(named: "poo\(self.animationCount)")
            self.animationCount += 1
            if self.animationCount == 15 {
                self.animationCount = 0
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
