//
//  WhirlView.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 11/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class WhirlView: UIView {
    
    var circleLayer = CAShapeLayer()
    var endAngle: CGFloat = 0.8
    var lineWidth: CGFloat = 2
    var circlePath: UIBezierPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor.blue
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2.0
        circlePath = UIBezierPath(roundedRect: bounds, cornerRadius: frame.height/2)
        circlePath.rotateAroundCenter(angle: CGFloat(arc4random_uniform(50))/10)
    }
    
    func start() {
        circlePath.rotateAroundCenter(angle: CGFloat(arc4random_uniform(50))/10)
        animateCircle(0.8) {
            
        }
    }
    
    private func setup() {
        circlePath = UIBezierPath(roundedRect: bounds, cornerRadius: frame.height/2)
        circlePath.move(to: center)
    }
    
    func animateCircle(_ value: CGFloat, duration: TimeInterval? = nil, completion: @escaping () -> ()) {
        setCircleLayer()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration ?? 0.5
        animation.fromValue = 0
        animation.toValue = value*endAngle
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        circleLayer.strokeEnd = value*endAngle
        let _ = Animation(animation: animation, object: circleLayer, completion: completion)
    }
    
    func animateCircleBack(_ duration: TimeInterval? = nil, completion: @escaping () -> ()) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration ?? 0.5
        animation.toValue = 0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        circleLayer.strokeEnd = 0
        let _ = Animation(animation: animation, object: circleLayer, completion: completion)
    }
    
    private func setCircleLayer() {
        guard !(layer.sublayers?.contains(circleLayer) ?? false) else { return }
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeEnd = 0
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = tintColor.cgColor
        circleLayer.lineWidth = lineWidth
        layer.addSublayer(circleLayer)
    }
    
    func reset() {
        layer.sublayers?.removeAll()
        setup()
    }
    
    
}

extension UIBezierPath {
  
    func rotateAroundCenter(angle: CGFloat) {
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: angle)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        apply(transform)
    }
}

class Animation: NSObject, CAAnimationDelegate {
    
    let completion: (()->Void)

    init(animation: CAAnimation, object: CALayer, completion: @escaping()->()) {
        self.completion = completion
        super.init()
        animation.delegate = self
        object.add(animation, forKey: "")
    }
    
    func load() {}
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completion()
    }
    
}
