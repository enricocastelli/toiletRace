//
//  PlayerModel.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Player {
    
    let name: String
    let poo: PooName
    let id: String
    let status: PlayerStatus
    let position: Position
}

enum PlayerStatus: Equatable {
    case Waiting // none
    case Confirmed // accepted owner push, is in the room
    case Ready // game is prepared and ready for countdown
    case Active // user is currently playing
    case Finish(time: String) // user finish the race
    
    init(_ value: String) {
        switch value.split(separator: "/").first {
        case "Waiting": self = .Waiting
        case "Confirmed": self = .Confirmed
        case "Ready": self = .Ready
        case "Active": self = .Active
        case "Finish": self = .Finish(time: String(value.split(separator: "/").last!))
        default: self = .Waiting
        }
    }
    
    var desc: String {
        switch self {
        case .Waiting: return "Waiting"
        case .Confirmed: return "Confirmed"
        case .Ready: return "Ready"
        case .Active: return "Active"
        case .Finish(let time):return "Finish/\(time)"
        }
    }
}

struct Room: Equatable {
   
    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id
    }
    
    let name: String
    let id: String
    var players: [Player]
    var status: RoomStatus
    let date: String
}

enum RoomStatus: String {
    case Waiting // none
    case Pushing // owner pushed, room is about to start
    case Ready // room has players confirmed
    case Active // room is currently playing
    case Finished // room is over
}

struct Position: Codable {
    var x: Float
    var y: Float
    var z: Float
    
    static func empty() -> Position {
        return Position(x: -9, y: -9, z: -9)
    }
}

enum Badge: Int {
    case flushWinner, faster, noWipe , pipeDominator, almightyPooper
    
    static let array = [flushWinner, faster, noWipe, pipeDominator, almightyPooper]
    
    init(_ index: Int) {
        switch index {
        case 0: self = .flushWinner // win 10 races
        case 1: self = .faster // faster than 30:00
        case 2: self = .noWipe // no contacts
        case 3: self = .pipeDominator // win 10 races multiplayer
        case 4: self = .almightyPooper // win 50 races
        default: self = .noWipe
        }
    }
    
    var desc: String {
        switch self {
        case .noWipe: return "No Wipe"
        case .faster: return "Faster than Farts"
        case .flushWinner: return "Flush Winner"
        case .pipeDominator: return "Pipe Dominator"
        case .almightyPooper: return "Almighty Pooper!"
        }
    }
    
    var index: Int {
        return self.rawValue
    }
    
    var poo: PooName {
        switch self {
        case .flushWinner: return .IndianSurprise
        case .faster: return .BrownTornado
        case .noWipe: return .GarganTurd
        case .pipeDominator: return .FecalRaider
        case .almightyPooper: return .ApolloPoo
        }
    }
}
