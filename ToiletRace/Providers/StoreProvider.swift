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
    static let level = "level"
    static let ID = "ID"
    static let name = "name"
    static let record = "record"
    static let badges = "badges"
    static let wins = "wins"
    static let multiWins = "multiWins"
}

protocol StoreProvider {}

extension StoreProvider {
    
    func isFirstTime() -> Bool {
        if UserDefaults.standard.object(forKey: StorageKeys.firstTime) != nil {
            return false
        } else {
            UserDefaults.standard.set(false, forKey: StorageKeys.firstTime)
            UserDefaults.standard.set([], forKey: StorageKeys.badges)
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
        return UserDefaults.standard.object(forKey: StorageKeys.name) as? String ?? playerName()
        #endif
    }
    
    func playerName() -> String {
        let device = UIDevice.current.name
        let nameString = device.replacingOccurrences(of: "iPhone", with: "").replacingOccurrences(of: "'s", with: "").replacingOccurrences(of: "di", with: "").replacingOccurrences(of: " ", with: "")
        guard nameString != "" && nameString != " " && nameString.count < 60 else { return "iPhone" }
        return nameString
    }
    
    private func testName() -> String {
        if UIDevice.current.name == "Enrico\'s iPhone" {
            return "test-6s"
        } else if UIDevice.current.name == "iPhone di Enrico" {
            return "test-7"
        } else if UIDevice.current.name == "iPhone 11 Pro Max" {
            return "test-sim-max"
        } else {
            return "test-sim"
        }
    }

    
    func saveLevel(_ level:Int) {
        UserDefaults.standard.setValue(level, forKey: StorageKeys.level)
    }
    
    func retrieveLevel() -> Int {
        UserDefaults.standard.value(forKey: StorageKeys.level) as? Int ?? 1
    }
    
    func isPooUnlocked(_ poo: Poo) -> Bool {
        guard poo.name != .GuanoStar && poo.name != .HoleRunner else { return true }
        if let int = UserDefaults.standard.value(forKey: StorageKeys.badges) as? [Int] {
            return !int.map { ( Badge($0)) }.filter { (badge) -> Bool in
                return badge.poo == poo.name
            }.isEmpty
        }
        return false
    }
    
    func storeRecord(_ record: TimeInterval) {
        if let savedRecord = getRecord() {
            if record < savedRecord {
                UserDefaults.standard.setValue(record, forKey: StorageKeys.record)
            }
        } else {
            UserDefaults.standard.setValue(record, forKey: StorageKeys.record)
        }
    }
    
    func getRecord() -> TimeInterval? {
        UserDefaults.standard.value(forKey: StorageKeys.record) as? TimeInterval
    }
    
    func saveBadge(_ badge: Badge) {
        var arr = getBadges()
        guard !arr.contains(badge) else { return }
        SessionData.shared.newBadges.append(badge)
        arr.append(badge)
        let mapped = arr.map {$0.index}
        UserDefaults.standard.setValue(mapped, forKey: StorageKeys.badges)
    }
    
    func getBadges() -> [Badge] {
        if let badges = UserDefaults.standard.value(forKey: StorageKeys.badges) as? [Int] {
            return badges.map { ( Badge($0)) }
        }
        return []
    }
    
    func saveWin() {
        UserDefaults.standard.setValue(getWin() + 1, forKey: StorageKeys.wins)
        if getWin() == 10 {
            saveBadge(.flushWinner)
        }
        if getWin() == 50 {
            saveBadge(.almightyPooper)
        }
    }
    
    func saveMultiWin() {
        UserDefaults.standard.setValue(getMultiWin() + 1, forKey: StorageKeys.multiWins)
        if getMultiWin() == 10 {
            saveBadge(.pipeDominator)
        }
    }
    
    func getWin() -> Int {
        UserDefaults.standard.value(forKey: StorageKeys.wins) as? Int ?? 0
    }
    
    func getMultiWin() -> Int {
        UserDefaults.standard.value(forKey: StorageKeys.multiWins) as? Int ?? 0
    }
}
