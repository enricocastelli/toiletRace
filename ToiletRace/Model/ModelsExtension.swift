//
//  ModelsExtension.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension Player {
    func toData() -> [String: Any]? {
        return ["id": id, "name": name, "poo": poo.rawValue,
                "position": ["xPos": position.x,
                                       "yPos": position.y,
                                       "zPos": position.z],
        "status" : status.desc]
    }
    
    func toPoo() -> Poo {
        let poo = Poo(name: self.poo, id: self.id)
        poo.displayName = self.name
        return poo
    }
}

extension Room: StoreProvider {
    
    func toData() -> [String: Any]? {
        return ["id": id, "name": name, "players": players.toData(), "date": date, "status" : status.rawValue]
    }
    
    func imOwner() -> Bool {
        return players.first?.id == getID()
    }
    
    func isPrivate() -> Bool {
        return self.id.contains("&P")
    }
    
    func isExpired() -> Bool {
        guard let date = date.toDate() else { return true }
        return Date() > date.addingTimeInterval(600)
    }
    
    func idNum() -> Int? {
        guard let intID = self.id.split(separator: "-").last else { return nil }
        return Int(intID)
    }
    
    func owner() -> Player? {
        return players.filter{ self.id.starts(with: $0.name) }.first
    }
}


extension Dictionary where Key == String, Value == Any {
    
    func toPlayer() -> Player? {
        guard let id = self["id"] as? String,
            let name = self["name"] as? String,
            let pooName = self["poo"] as? String,
            let status = self["status"] as? String,
            let position = self["position"] as? [String: Float],
            let xPos = position["xPos"], let yPos = position["yPos"], let zPos = position["zPos"] else { return nil }
        return Player(name: name, poo: PooName(rawValue: pooName) ?? PooName.GuanoStar, id: id, status: PlayerStatus(status), position: Position(x: xPos, y: yPos, z: zPos))
    }
    
    func toRoom() -> Room? {
        guard let id = self["id"] as? String,
            let name = self["name"] as? String,
            let status = self["status"] as? String,
            let date = self["date"] as? String,
            let players = self["players"] as? [[String: Any]] else { return nil }
        let pl = players.map { return $0.toPlayer()}.compactMap{ $0 }
        return Room(name: name, id: id, players: pl, status: RoomStatus(rawValue: status) ?? .Waiting, date: date)
    }
    
}


extension DataSnapshot {
    
    func toPlayer() -> Player? {
       return (value as? Dictionary<String, Any>)?.toPlayer()
    }
    
    func toRoom() -> Room? {
        return (value as? Dictionary<String, Any>)?.toRoom()
    }
    
    func toRoomStatus() -> RoomStatus? {
        return RoomStatus(rawValue: value as? String ?? "")
    }
    
    func toPlayers() -> [Player] {
        var arr = [Player]()
        guard let values = value as? [[String: Any]] else { return [] }
        for element in values {
            if let player = element.toPlayer() {
                arr.append(player)
            }
        }
        return arr
    }
}

extension Array where Element == Player {
    
    func toData() -> [[String: Any]] {
        return self.map{$0.toData()}.compactMap{$0}
    }
    
    func toPoos() -> [Poo] {
        return self.map { (pl) -> Poo in
            return pl.toPoo()
        }
    }
    
    func areReady() -> Bool {
        return self.filter{ $0.status == PlayerStatus.Ready }.count == self.count
    }
    
    func areFinish() -> Bool {
        return self.filter { (pl) -> Bool in
            if case .Finish(_) = pl.status {
                return true
            }
            return false
        }.count == self.count
    }
    
    mutating func replace(_ player: Player) {
        guard let index = self.firstIndex(where: { (pl) -> Bool in
            return pl.id == player.id
        }) else { return }
        self[index] = player
    }
}

extension Array where Element == Poo {
    
    func pooWithPl(_ pl: Player) -> Poo {
        return self[firstIndex(where: { $0.id == pl.id})!]
    }
    
    func selfIndex(_ id: String) -> Int? {
        return self.firstIndex(where: {($0.id == id)})
    }
    
    mutating func replace(_ poo: Poo) {
        guard let index = self.firstIndex(where: { (p) -> Bool in
            return p == poo
        }) else { return }
        self[index] = poo
    }
}


extension Array where Element == Result {
    
    func containsPoo(poo: Poo) -> Bool {
        return self.contains { $0.poo == poo }
    }
}

