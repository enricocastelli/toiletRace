//
//  RoomsProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol RoomsProvider: DatabaseProvider {}

extension RoomsProvider {
    
    
    func addRoomsObserver() {
        rooms().observe(DataEventType.childAdded) { (snapshot) in
            guard let room = snapshot.toRoom() else { return }
            if room.isExpired() {
                self.deleteRoom(room.id)
            } else if room.status != .Active {
                self.didAddedRoom(room)
            }
        }
        rooms().observe(DataEventType.childRemoved) { (snapshot) in
            guard let room = snapshot.toRoom() else { return }
            self.didRemovedRoom(room)
        }
    }
    
    func removeRoomObservers() {
        rooms().removeAllObservers()
    }
    
    func createRoom(_ name: String, completion: @escaping(Room) ->()) {
        let random = String(Int(arc4random_uniform(99)))
        let uuid = UUID().uuidString.prefix(5).lowercased() + "-" + random
        let room = Room(name: name, id: "\(testName())\(uuid)", players: [createSelf(.Confirmed)], status: .Waiting, date: Date().toString())
        guard let data = room.toData() else { return }
        let childUpdates = [room.id: data]
        rooms().updateChildValues(childUpdates) { (_,_) in
            completion(room)
        }
    }
    
    func subscribeToRoom(_ roomID: String, completion: @escaping(Room) ->()) {
        rooms().child(roomID).observeSingleEvent(of: .value) { (snapshot) in
            guard var room = snapshot.toRoom() else { return }
            guard !room.players.contains(where: { $0.id == self.getID() }) else {
                completion(room)
                return
            }
            room.players.append(self.createSelf())
            let childUpdates = [room.id: room.toData()]
            self.rooms().updateChildValues(childUpdates as [AnyHashable : Any]) { (_, _) in
                completion(room)
            }
        }
    }
    
    private func createSelf(_ status: PlayerStatus = .Waiting) -> Player {
        return Player(name: getName(), poo: SessionData.shared.selectedPlayer.name, id: getID(), status: status, position: Position.empty())
    }
    
    // Unused database provider methods
    func roomIsReady() {}
    func didAddedPlayer(_ player: Player) {}
    func didRemovedPlayer(_ player: Player) {}
    func didChangePlayer(_ player: Player) {}
}
