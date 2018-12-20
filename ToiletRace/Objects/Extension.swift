//
//  Extension.swift
//  TheRace
//
//  Created by Enrico Castelli on 05/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}


public extension SCNNode {
    
    internal func moveCasually(direction: Direction) {
        let forceX : Float = {
            if presentation.position.x < -5 {
                return 1
            } else if presentation.position.x > 5 {
                return -1
            }
            return (direction == .right) ? 0.8 : -0.8
        }()
        let force = SCNVector3(forceX, 0.0, 0)
        physicsBody?.applyForce(force, asImpulse: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            let counterForce = SCNVector3(-forceX/8, 0.0, 0)
            self.physicsBody?.applyForce(counterForce, asImpulse: true)
        })
    }
    
    internal func moveStrong(direction: Direction) {
        let forceX : Float = {
            if presentation.position.x < -5 {
                return 1.5
            } else if presentation.position.x > 5 {
                return -1.5
            }
            return (direction == .right) ? 0.8 : -0.8
        }()
        let force = SCNVector3(forceX, 0.0, 0)
        physicsBody?.applyForce(force, asImpulse: true)
    }
    
    func moveSpecific(specificX : Float) {
        let force = SCNVector3(specificX, 0.0, 0.0)
        physicsBody?.applyForce(force, asImpulse: true)
    }
    
    // For rolling pill bottle
    func moveForever() {
        moveForward()
    }
    
    private func moveForward() {
        let currentPosition = self.position
        let action = SCNAction.move(to: SCNVector3(-6, currentPosition.y, currentPosition.z), duration: 1)
        self.runAction(action) {
            self.moveBack()
        }
    }
    
    private func moveBack() {
        let currentPosition = self.position
        let action = SCNAction.move(to: SCNVector3(6, currentPosition.y, currentPosition.z), duration: 1)
        self.runAction(action) {
            self.moveForward()
        }
    }
}

public extension Float {
    
    func string() -> String {
        return String(format: "%.2f", self)
    }
}

extension UIView {
    
    func setConstraint(constraint: NSLayoutConstraint.Attribute, constant: CGFloat) {
        guard let superview = superview else { return }
        if translatesAutoresizingMaskIntoConstraints == true {
            translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.init(item: self,
                                attribute: constraint,
                                relatedBy: .equal,
                                toItem: superview,
                                attribute: constraint,
                                multiplier: 1,
                                constant: constant).isActive = true
    }
    
    func setAdaptingConstraint() {
        self.setConstraint(constraint: .bottom, constant: 0)
        self.setConstraint(constraint: .leading, constant: 0)
        self.setConstraint(constraint: .trailing, constant: 0)
        self.setConstraint(constraint: .top, constant: 0)
    }
}
