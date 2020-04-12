//
//  Extension.swift
//  TheRace
//
//  Created by Enrico Castelli on 05/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import SceneKit

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
    
    func setSelfConstraint(constraint: NSLayoutConstraint.Attribute, constant: CGFloat) {
        if translatesAutoresizingMaskIntoConstraints == true {
            translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: constraint,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: constraint,
                                         multiplier: 1,
                                         constant: constant))
    }
    
    
    func setAspectRatio(_ w: Float, _ h: Float) {
        if translatesAutoresizingMaskIntoConstraints == true {
            translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .width,
                                         multiplier: CGFloat(w/h),
                                         constant: 0))
    }
    
    
    func addContentView(_ contentView: UIView, _ atIndex: Int? = nil) {
        let containerView = self
        contentView.translatesAutoresizingMaskIntoConstraints = false
        if let atIndex = atIndex {
            containerView.insertSubview(contentView, at: atIndex)
        } else {
            containerView.addSubview(contentView)
        }
        NSLayoutConstraint.init(item: contentView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: containerView,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: contentView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: containerView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: contentView,
                                attribute: .right,
                                relatedBy: .equal,
                                toItem: containerView,
                                attribute: .right,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: contentView,
                                attribute: .left,
                                relatedBy: .equal,
                                toItem: containerView,
                                attribute: .left,
                                multiplier: 1,
                                constant: 0).isActive = true
    }
    
    func addShadow(size: CGSize = CGSize(width: -1.3, height: 2)) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0
        layer.shadowOffset = size
        layer.shadowRadius = 1
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}


extension UIViewController {
    
    var navigation: Navigation {
        return self.navigationController as? Navigation ??
            UIApplication.shared.windows.first?.rootViewController as! Navigation
    }
}

extension UIImage {
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
    
    
    static var paper: UIImage {
        return  UIImage(named: "paper")!
    }
    
    static var paperTop: UIImage {
        return  UIImage(named: "paperTop")!
    }
    
    static var greenLight: UIImage {
        return  UIImage(named: "green")!
    }
    
    static var redLight: UIImage {
        return  UIImage(named: "red")!
    }
}


extension SCNNode {
    
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

extension Float {
    
    func string() -> String {
        return String(format: "%.2f", self)
    }
}

extension String {

    func float() -> Float? {
        return Float(self)
    }
    
}

extension UILayoutPriority {
    
    static let high = UILayoutPriority(rawValue: 999)
    static let low = UILayoutPriority(rawValue: 1)

}

extension UIColor {
    
    convenience init(hex: String) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: 1)
    }
}

extension UIImageView {
    
    func changeImage(_ image: UIImage) {
        UIView.transition(with: self,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.image = image
        },
                          completion: nil)
    }
}

enum GestureDirection: Int {
    case Up
    case Down
    case Left
    case Right

    public var isX: Bool { return self == .Left || self == .Right }
    public var isY: Bool { return !isX }
}

extension UIPanGestureRecognizer {

    var direction: GestureDirection? {
        let vel = velocity(in: view)
        let vertical = abs(vel.y) > abs(vel.x)
        switch (vertical, vel.x, vel.y) {
        case (true, _, let y) where y < 0: return .Up
        case (true, _, let y) where y > 0: return .Down
        case (false, let x, _) where x > 0: return .Right
        case (false, let x, _) where x < 0: return .Left
        default: return nil
        }
    }
}
