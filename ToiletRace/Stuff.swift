//
//  Stuff.swift
//  TheRace
//
//  Created by Enrico Castelli on 02/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit

//typedef NS_OPTIONS(NSUInteger, CollisionCategory) {
//    CollisionCategoryMissile    = 1 << 0,
//    CollisionCategoryRocket     = 1 << 1,
//    CollisionCategoryAsteroid   = 1 << 2,
//};
//
//missile.physicsBody.categoryBitMask = CollisionCategoryMissile;
//rocket.physicsBody.categoryBitMask = CollisionCategoryRocket;
//asteroid.physicsBody.categoryBitMask = CollisionCategoryAsteroid;
//Use bitwise OR on these constants to create collisionBitMask values that fill in the table.
//
//missile.physicsBody.collisionBitMask =
//CollisionCategoryRocket | CollisionCategoryAsteroid;
//rocket.physicsBody.collisionBitMask =
//CollisionCategoryRocket | CollisionCategoryAsteroid;
//asteroid.physicsBody.collisionBitMask = CollisionCategoryAsteroid;

class Collider {
    static let ball: Int = 4
    static let bounds : Int = 8
    static let impediment: Int = 16
    static let floor: Int = 32
}


struct Result {
    var player: Poo
    var time: Float
    var timeToWinner: Float?
    var points: Float
    var totalPoints: Float
    
}

enum World: Int {
    
    case house = 0
    case toilet = 1
    case pipe = 2
    case falling = 3
    case water = 4
//    case ground = 5
}

enum Keys : String {
    
    case TotalPoints
    case Level
}

class Data {
    
    static let shared = Data()
    
    var scores : [String: Float] = [:]
    var games = 0
    var selectedPlayer = Poo(name: .ApolloPoo)
    
    func reset() {
        games = 0
        scores = [:]
        selectedPlayer = Poo(name: .ApolloPoo)
    }
}


class Storage : NSObject {
//
    class func storeScore(res: Result, index: Int) {
        if let total = Storage.getScore(name: res.player.name.rawValue) {
            UserDefaults.standard.set(index + total, forKey: res.player.name.rawValue)
        } else {
            UserDefaults.standard.set(index, forKey: res.player.name.rawValue)
        }
    }
    
    class func getScore(name: String) -> Int? {
        return UserDefaults.standard.getPoints(key: name)
    }
    
    class func reset(name: String) {
        UserDefaults.standard.removeObject(forKey: name)
    }
}

extension UserDefaults {

    func getPoints(key : String) -> Int? {
        let value = self.value(forKey: key)
        return value as? Int
    }

}


func Logger(ms: String) {
//    print("💩⚠️ \(ms)")
}

// BEWARE OF THE ALMIGHTYYY POOOOPPPP
var shouldShowMighty = false
