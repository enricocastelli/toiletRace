//
//  StorageManager.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 21/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit

enum StorageKeys: String {
   
    case savedBolus
    
}

class StorageManager {
    
    static var defaults = UserDefaults.standard
    
    static func saveBolus(_ bolus: BolusItem) {
        let dictionary: [String:Float] = ["colorR":  bolus.colorR,
                                          "colorG": bolus.colorG,
                                          "colorB": bolus.colorR,
                                          "radius": bolus.radius,
                                          "restitution": bolus.restitution,
                                          "displacement": bolus.displacement,
                                          "mass": bolus.mass,
                                          ]
        defaults.setValue(dictionary, forKey: StorageKeys.savedBolus.rawValue)
    }
    
    static func retrieveBolus() -> BolusItem? {
        if let value = defaults.value(forKey: StorageKeys.savedBolus.rawValue) as? [String:Float] {
            guard let colorR = value["colorR"], let colorG = value["colorG"], let colorB = value["colorB"], let radius = value["radius"], let restitution = value["restitution"], let displacement = value["displacement"], let mass = value["mass"] else { return nil }
            return BolusItem(colorR: colorR, colorG: colorG, colorB: colorB, radius: radius, restitution: restitution, displacement: displacement, mass: mass)
        }
        return nil
    }
}
