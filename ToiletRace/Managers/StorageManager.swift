//
//  StorageManager.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 21/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

enum StorageKeys {
    static let Level = "Level"
    static let ID = "ID"
}

class StorageManager {
    
    
    static var defaults = UserDefaults.standard
    
    func setID(_ id: String) {
        UserDefaults.standard.set(id, forKey: StorageKeys.ID)
    }
    
    func getID() -> String {
        if let existingID = UserDefaults.standard.object(forKey: StorageKeys.ID) as? String {
            return existingID
        } else {
            #if DEBUG
            setID(testName())
            return testName()
            #else
            let uuid = getName() + "-" + String(UUID().uuidString.prefix(5))
            setID(uuid.lowercased())
            return uuid.lowercased()
            #endif
        }
    }
    
    static func saveLevel(_ level:Int) {
        defaults.setValue(level, forKey: StorageKeys.Level)
    }
    
    static func retrieveLevel() -> Int {
        defaults.value(forKey: StorageKeys.Level) as? Int ?? 1
    }
}

func testName() -> String {
    if UIDevice.current.name == "Enrico\'s iPhone" {
        return "test-6s"
    } else if UIDevice.current.name == "iPhone di Enrico" {
        return "test-7"
    } else {
        return "test-sim"
    }
}
