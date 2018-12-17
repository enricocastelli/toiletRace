//
//  Loading.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 22/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit

class Loading: UIViewController {
    
    var pooImage = UIImageView(image: UIImage(named: "poo0"))
    var timer = Timer()
    var animationCount = 0
    var label = UILabel()
    
    func startAnimating() {
        view.backgroundColor = UIColor(red: 247/255, green: 253/255, blue: 1, alpha: 1)
        pooImage.center = view.center
        label.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        label.center = CGPoint(x: view.center.x, y: view.frame.height - 80)
        label.text = "LOADING..."
        label.textColor = UIColor.brown
        view.addSubview(pooImage)
        view.addSubview(label)
        startTimer()
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.alpha = 0
        }) { (done) in
            self.timer.invalidate()
            self.view.removeFromSuperview()
            self.dismiss(animated: false, completion: nil)
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
}
