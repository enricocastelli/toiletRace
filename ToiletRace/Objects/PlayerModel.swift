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

enum PlayerStatus: String {
    case Waiting // none
    case Confirmed // accepted owner push, is in the room
    case Refused // Didn't accept, can leave room
    case Loading // is loading game
    case Ready // game is prepared and ready for countdown
    case Active // user is currently playing
    case Finish // user finish the race
}

struct Room {
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
}

struct Position: Codable {
    var x: Float
    var y: Float
    var z: Float
    
    static func empty() -> Position {
        return Position(x: -9, y: -9, z: -9)
    }
}
