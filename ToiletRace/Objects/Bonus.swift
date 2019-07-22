//
//  Bonus.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 06/11/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit


enum Bonus {
    
    case NoBonus
    /// Get double speed
    case Sprint
    /// Makes opponents slower
    case Slower
    /// Passes trough obstacles
    case Ghost
    /// Teleports 20 points forward
    case Teleport
    /// Shot mini poo behind
    case MiniPoo
    // SuperBonus for Mighty Poop
    case Almighty
    
    func image() -> UIImage {
        switch self {
        case .NoBonus:
            return UIImage()
        case .Sprint:
            return UIImage(named: "sprint")!
        case .Ghost:
            return UIImage(named: "ghost")!
        case .Slower:
            return UIImage(named: "slower")!
        case .Teleport:
            return UIImage(named: "teleport")!
        case .MiniPoo:
            return UIImage(named: "minipoo")!
        case .Almighty:
            return UIImage()
        }
    }
    
    func duration() -> Float {
        switch self {
        case .NoBonus:
            return 0
        case .Sprint:
            return 1.5
        case .Ghost:
            return 2
        case .Slower:
            return 3
        case .Teleport:
            return 0
        case .MiniPoo:
            return 0
        case .Almighty:
            return 10
        }
    }
    
    func rechargeDuration() -> Float {
        switch self {
        case .NoBonus:
            return 0
        case .Sprint:
            return 14
        case .Ghost:
            return 10
        case .Slower:
            return 11
        case .Teleport:
            return 15
        case .MiniPoo:
            return 5
        case .Almighty:
            return 4
        }
    }
}
