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
    static let poo: Int = 4
    static let bounds : Int = 8
    static let obstacle: Int = 16
    static let floor: Int = 32
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

enum Direction: Int {
    
    case left
    case right
    case straight
    //    case back
}

class SessionData {
    
    static let shared = SessionData()
    
    var scores : [String: Float] = [:]
    var games = 0
    var selectedPlayer = Poo(name: .GuanoStar)
    
    func reset() {
        games = 0
        scores = [:]
        selectedPlayer = Poo(name: .GuanoStar)
    }
}

// BEWARE OF THE ALMIGHTYYY POOOOPPPP
var shouldShowMighty = false
