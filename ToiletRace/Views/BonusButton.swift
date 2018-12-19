//
//  BonusButton.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 02/11/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit

protocol BonusButtonDelegate {
    func didTapButton(bonus: Bonus)
    func didFinishBonus(bonus: Bonus)
}

class BonusButton : UIButton {
    
    var circleLayer = CAShapeLayer()
    var bonus: Bonus
    var delegate: BonusButtonDelegate?
    
    init(frame: CGRect, bonus: Bonus, delegate: BonusButtonDelegate?) {
        self.bonus = bonus
        super.init(frame: frame)
        self.delegate = delegate
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        guard bonus != .NoBonus else {
            isHidden = true
            return }
        isHidden = false
        layer.cornerRadius = frame.height/2
        backgroundColor = UIColor.white
        setImage(bonus.image(), for: .normal)
        imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.addTarget(self, action: #selector(activateBonus), for: .touchUpInside)
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
    
    func updateBonus(bonus: Bonus) {
        self.bonus = bonus
        setup()
    }
    
    @objc func activateBonus() {
        // ENABLE POWER UP
        if let bonus = SessionData.shared.selectedPlayer.bonus() {
            guard SessionData.shared.selectedPlayer.canUseBonus == true else { return }
            isEnabled = false
            perform(#selector(recharge), with: nil, afterDelay: TimeInterval(bonus.duration()))
            delegate?.didTapButton(bonus: bonus)
        }
    }
    
    @objc func recharge() {
        delegate?.didFinishBonus(bonus: bonus)
        alpha = 0.2
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = CFTimeInterval(bonus.rechargeDuration())
        animation.fromValue = 0
        animation.toValue = 1
        circleLayer.add(animation, forKey: "strokeCircle")
        // recharge
        perform(#selector(ready), with: nil, afterDelay: TimeInterval(bonus.rechargeDuration()))
    }
    
    @objc func ready() {
        isEnabled = true
        alpha = 0.6
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (done) in
            
        }
    }
    
    
    
}
