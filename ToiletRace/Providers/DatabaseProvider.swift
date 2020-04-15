//
//  DatabaseProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 15/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol DatabaseProvider: StoreProvider {
    func didAddedPlayer(_ player: Player)
    func didRemovedPlayer(_ player: Player)
    func didAddedRoom(_ room: Room)
    func didRemovedRoom(_ room: Room)
    func roomIsReady()
    func didChangePlayer(_ player: Player)
}

extension DatabaseProvider {
    
    func rooms() -> DatabaseReference {
        return Database.database().reference().child("rooms")
    }
    
    func roomExist(_ roomID: String, completion: @escaping(Bool) ->()) {
        getRoom(roomID) { (_) in
            completion(true)
        }
    }
    
    func getRoom(_ roomID: String, completion: @escaping(Room) ->()) {
        rooms().child(roomID).observeSingleEvent(of: .value) { (snapshot) in
            guard let room = snapshot.toRoom() else { return }
            completion(room)
        }
    }
    
    func updateSelf(_ roomID: String, player: Player, completion: @escaping() ->()) {
        guard let data = player.toData() else { return }
        rooms().child(roomID).observeSingleEvent(of: .value) { (snapshot) in
        guard let room = snapshot.toRoom(), let indexSelf = room.players.firstIndex(where: { $0.id == self.getID() }) else { return  }
        let childUpdates = ["\(room.id)/players/\(indexSelf)": data]
            self.rooms().updateChildValues(childUpdates) { (_, _) in
                completion()
            }
        }
    }
    
    func deleteRoom(_ id: String) {
        rooms().child(id).removeValue()
    }
}
