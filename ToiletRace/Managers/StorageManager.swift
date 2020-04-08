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
   
    case Level
    
}

class StorageManager {
    
    static var defaults = UserDefaults.standard
    
    static func saveLevel(_ level:Int) {
        defaults.setValue(level, forKey: StorageKeys.Level.rawValue)
    }
    
    static func retrieveLevel() -> Int {
        defaults.value(forKey: StorageKeys.Level.rawValue) as? Int ?? 1
    }
}
