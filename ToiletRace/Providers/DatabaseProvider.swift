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
        rooms().child(roomID).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    func getRoom(_ roomID: String, completion: @escaping(Room) ->(), failure: @escaping(Error) ->()) {
        rooms().child(roomID).observeSingleEvent(of: .value) { (snapshot) in
            guard let room = snapshot.toRoom() else {
                failure(PooError.GeneralError)
                return }
            completion(room)
        }
    }
    
    func updateSelf(_ roomID: String, player: Player, completion: @escaping() ->(), failure: @escaping(Error) ->()) {
        guard let data = player.toData() else {
            failure(PooError.GeneralError)
            return }
        rooms().child(roomID).observeSingleEvent(of: .value) { (snapshot) in
        guard let room = snapshot.toRoom(), let indexSelf = room.players.firstIndex(where: { $0.id == self.getID() }) else {
            failure(PooError.GeneralError)
            return  }
            let childUpdates = ["\(room.id)/players/\(indexSelf)": data]
            self.rooms().updateChildValues(childUpdates) { (error, _) in
                error == nil ? completion() : failure(error!)
            }
        }
    }
    
    func deleteRoom(_ id: String, completion: @escaping() ->(), failure: @escaping(Error) ->()) {
        rooms().child(id).removeValue { (error, _) in
            error == nil ? completion() : failure(error!)
        }
    }
}
