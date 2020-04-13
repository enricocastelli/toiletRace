//
//  Colors.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 13/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let oceanBlue = UIColor(hex: "374D62")
    static let paperWhite = UIColor(hex: "E8E8EA")
    static let goGreen =  UIColor(hex: "1AD220")
    static let bonusBlue = UIColor(hex: "005CFF")
    static let aqua = UIColor(hex: "6F9C7A")
    static let labelBlack = UIColor(hex: "303030")
    static let gold = UIColor(hex: "FFB308")
    static let quiteGold = UIColor(hex: "FFD700")
    static let silver = UIColor(hex: "8E9EAB")
    static let quiteSilver = UIColor(hex: "B0B3B5")
    static let bronze = UIColor(hex: "97502D")
    static let quiteBronze = UIColor(hex: "B87B36")
    
    static let goldGradient = [UIColor.gold.cgColor,      UIColor.quiteGold.cgColor  ,UIColor.white.cgColor]
    static let silverGradient = [UIColor.silver.cgColor,  UIColor.quiteSilver.cgColor,UIColor.white.cgColor]
    static let bronzeGradient = [UIColor.bronze.cgColor,  UIColor.quiteBronze.cgColor,UIColor.white.cgColor]
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
