//
//  RoomsProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol RoomsProvider: StoreProvider {
    func didAddedPlayer(_ player: Player)
    func didRemovedPlayer(_ player: Player)
    func didAddedRoom(_ room: Room)
    func didRemovedRoom(_ room: Room)
    func roomIsReady()
}

extension RoomsProvider {
    
    private func rooms() -> DatabaseReference {
        return Database.database().reference().child("rooms")
    }
    
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
    
    func addPlayersObserver(_ roomID: String) {
        rooms().child(roomID).child("players").observe(DataEventType.childAdded) { (snapshot) in
            guard let pl = snapshot.toPlayer() else { return }
            self.didAddedPlayer(pl)
        }
        rooms().child(roomID).child("players").observe(DataEventType.childRemoved) { (snapshot) in
            guard let pl = snapshot.toPlayer() else { return }
            self.didRemovedPlayer(pl)
        }
        rooms().child(roomID).observe(DataEventType.childChanged) { (snapshot) in
            guard let status = snapshot.toRoomStatus() else { return }
            if status == .Pushing {
                self.roomIsReady()
                self.updateRoomStatus(roomID, .Active, nil)
                self.removePlayerObservers(roomID)
            }
        }
    }
   
    func removePlayerObservers(_ roomID: String) {
        rooms().child(roomID).child("players").removeAllObservers()
    }
    
    func removeRoomObservers() {
        rooms().removeAllObservers()
    }

    
    func createRoom(_ name: String) -> Room {
        let uuid = UUID().uuidString.prefix(5).lowercased()
        let room = Room(name: name, id: "\(testName())\(uuid)", players: [createSelf()], status: .Waiting, date: Date().toString())
        guard let data = room.toData() else { return room }
        let childUpdates = [room.id: data]
        rooms().updateChildValues(childUpdates)
        return room
    }
    
    func sendStartRoom(_ roomID: String, completion: @escaping() ->()) {
        updateRoomStatus(roomID, .Pushing, completion)
    }
    
    func updateRoomStatus(_ id: String, _ status: RoomStatus, _ completion: (()->())?) {
        let childUpdates = [id + "/status": status.rawValue]
        rooms().updateChildValues(childUpdates) { (error, ref) in
            if error == nil {
                completion?()
            }
        }
    }
    
    func deleteRoom(_ id: String) {
        rooms().child(id).removeValue()
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
    
    func unsubscribeFromRoom(_ room: Room, completion: @escaping() ->()) {
        var room = room
        guard room.players.contains(where: { $0.id == getID() }) else { return }
        room.players.removeAll(where: { $0.id == getID() })
        let childUpdates = [room.id: room.toData()]
        rooms().child(room.id).observe(.value) { (snapshot) in
            if snapshot.exists() {
                self.rooms().updateChildValues(childUpdates as [AnyHashable : Any]) { (_, _) in
                    completion()
                }
            }
        }
    }
    
    private func createSelf() -> Player {
        return Player(name: getName(), poo: PooName.GuanoStar, id: getID(), status: .Waiting, position: Position.empty())
    }
}
