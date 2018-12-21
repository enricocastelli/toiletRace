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
}
