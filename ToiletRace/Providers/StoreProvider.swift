//
//  StorageManager.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 21/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

enum StorageKeys {
    static let firstTime = "firstTime"
    static let level = "Level"
    static let ID = "ID"
    static let name = "name"
    static let badges = "badges"
}

protocol StoreProvider {}

extension StoreProvider {
    
    func isFirstTime() -> Bool {
        if UserDefaults.standard.object(forKey: StorageKeys.firstTime) != nil {
            return false
        } else {
            UserDefaults.standard.set(false, forKey: StorageKeys.firstTime)
            UserDefaults.standard.set(["Guano Star", "Hole Runner"], forKey: StorageKeys.badges)
            return true
        }
    }
        
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
   
    func setName(_ name: String) {
        UserDefaults.standard.set(name, forKey: StorageKeys.name)
    }
    
    func getName() -> String {
        #if DEBUG
        return testName()
        #else
        return UserDefaults.standard.object(forKey: StorageKeys.name) as? String ?? UIDevice.current.name.playerName
        #endif
    }
    
    func saveLevel(_ level:Int) {
        UserDefaults.standard.setValue(level, forKey: StorageKeys.level)
    }
    
    func retrieveLevel() -> Int {
        UserDefaults.standard.value(forKey: StorageKeys.level) as? Int ?? 1
    }
    
    func isPooUnlocked(_ poo: Poo) -> Bool {
        let badges = UserDefaults.standard.value(forKey: StorageKeys.badges) as? [String] ?? []
        return badges.contains(poo.name.rawValue)
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
