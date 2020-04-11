//
//  Stuff.swift
//  TheRace
//
//  Created by Enrico Castelli on 02/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class Logger {
    
    static func error(_ error: Error) {
        print("💩💔 \(error.message)")
    }
    
    static func Warning(_ warning: String) {
        print("💩⚠️ \(warning)")
    }
}

enum Style {
    case hairline, thin, light, medium, bold
    
    var name: String {
        switch self {
        case .hairline: return "Lato-Hairline"
        case .thin: return "Lato-Thin"
        case .light: return "Lato-Light"
        case .medium: return "Lato-Medium"
        case .bold: return "Lato-Bold"
        }
    }
}

class Font {
    
    static func with(_ style: Style, _ size: Int) -> UIFont {
        return UIFont(name: style.name, size: CGFloat(size))!
    }
    
}

class Values {
    /// Ydistance of camera from user poop
    static var yTot : Float = 4.0
    
    /// Zdistance of camera from user poop
    static var zTot : Float = 4.0
    
    /// Zdistance of camera from user poop
    static var xTot : Float = 0
    
}

enum Direction: Int {
    
    case left
    case right
    case straight
}

class SessionData {
    
    static let shared = SessionData()
    var selectedPlayer = Poo(name: .GuanoStar)
}

// BEWARE OF THE ALMIGHTYYY POOOOPPPP
var shouldShowMighty = false

