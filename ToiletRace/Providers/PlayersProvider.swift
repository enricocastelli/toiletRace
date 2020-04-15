//
//  PlayersProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 15/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol PlayersProvider: DatabaseProvider {}

extension PlayersProvider {
    
    
     func addPlayersObserver(_ roomID: String) {
         rooms().child(roomID).child("players").observe(DataEventType.childAdded) { (snapshot) in
             guard let pl = snapshot.toPlayer() else { return }
             self.didAddedPlayer(pl)
         }
         rooms().child(roomID).child("players").observe(DataEventType.childRemoved) { (snapshot) in
             guard let pl = snapshot.toPlayer() else { return }
             self.didRemovedPlayer(pl)
         }
         rooms().child(roomID).child("players").observe(DataEventType.childChanged) { (snapshot) in
             guard let pl = snapshot.toPlayer() else { return }
             self.didChangePlayer(pl)
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
    
    func updatePlayerStatus(_ roomID: String, status: PlayerStatus, completion: @escaping() ->()) {
        updateSelf(roomID, player: Player(name: getName(), poo: SessionData.shared.selectedPlayer.name, id: getID(), status: status, position: Position.empty()), completion: completion)
    }
    
    func unsubscribeFromRoom(_ room: Room, completion: @escaping() ->()) {
        var room = room
        guard room.players.contains(where: { $0.id == getID() }) else { return }
        room.players.removeAll(where: { $0.id == getID() })
        let childUpdates = [room.id: room.toData()]
        roomExist(room.id) { (exist) in
            if exist {
                self.rooms().updateChildValues(childUpdates as [AnyHashable : Any]) { (_, _) in
                    completion()
                }
            }
        }
    }
    
    func sendStartRoom(_ roomID: String, completion: @escaping() ->()) {
        updateRoomStatus(roomID, .Pushing, completion)
    }
    
    // game result
    func updateRoomStatus(_ id: String, _ status: RoomStatus, _ completion: (()->())?) {
        let childUpdates = [id + "/status": status.rawValue,
                            id + "/date": Date().toString()]
        rooms().updateChildValues(childUpdates) { (error, ref) in
            if error == nil {
                completion?()
            }
        }
    }
    
    // Unused database provider methods
    func didAddedRoom(_ room: Room) {}
    func didRemovedRoom(_ room: Room) {}
    
}
