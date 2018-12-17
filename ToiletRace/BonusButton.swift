//
//  BonusButton.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 02/11/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit

class BonusButton : UIButton {
    
    var circleLayer = CAShapeLayer()
    var bonus: Bonus?
    
    func initWithBonus(bonus: Bonus) {
        guard bonus != .NoBonus else { return }
        layer.cornerRadius = frame.height/2
        backgroundColor = UIColor.white
        setImage(bonus.image(), for: .normal)
        imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.bonus = bonus
        alpha = 0.6
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: frame.height/2, height: frame.height/2))
        circleLayer.path = path.cgPath
        circleLayer.strokeColor = UIColor.blue.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 4
        guard layer.sublayers != nil else {
            layer.addSublayer(circleLayer)
            return }
        if !layer.sublayers!.contains(circleLayer) {
            layer.addSublayer(circleLayer)
        }
    }
    
    func stopped() {
        alpha = 0.2
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = CFTimeInterval((bonus?.rechargeDuration()) ?? 10)
        animation.fromValue = 0
        animation.toValue = 1
        circleLayer.add(animation, forKey: "strokeCircle")
    }
    
    func ready() {
        alpha = 0.6
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (done) in
            
        }
    }
}
