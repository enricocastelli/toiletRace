//
//  Multi.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 19/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol MultiplayerDelegate {
    func shouldStart()
}

class MultiplayerManager: StoreProvider {
    
    var room: Room
    var indexSelf: Int
    var delegate: MultiplayerDelegate?
    
    init(room: Room, indexSelf: Int) {
        self.room = room
        self.indexSelf = indexSelf
    }
    
    deinit {
        removeObservers()
    }
    
    private func rooms() -> DatabaseReference {
        return Database.database().reference().child("rooms")
    }
    
    func sendStatus(_ status: PlayerStatus) {
         updateSelf(Player(name: getName(), poo: SessionData.shared.selectedPlayer.name, id: getID(), status: status, position: Position.empty()))
        addStartObserver()
    }

    func sendPosition(x: Float, y: Float, z: Float) {
        updateSelf(Player(name: getName(), poo: SessionData.shared.selectedPlayer.name, id: getID(), status: PlayerStatus.Active, position: Position(x: x, y: y, z: z)))
    }
    
    func updatePlayers(_ completion: @escaping([Player]) ->()) {
        rooms().child(room.id).child("players").observeSingleEvent(of: .value, with: { (snapshot) in
            let players = snapshot.toPlayers()
             completion(players)
        }) { (error) in
            Logger(error.localizedDescription)
        }
    }
    
    private func addStartObserver() {
        rooms().child(room.id).child("players").observe(.value) { (snapshot) in
            let players = snapshot.toPlayers()
            if players.areReady() {
                self.delegate?.shouldStart()
            }
        }
    }
    
    func removeObservers() {
        rooms().removeAllObservers()
    }
    
    private func updateSelf(_ player: Player) {
        guard let data = player.toData() else { return }
        let childUpdates = ["\(room.id)/players/\(indexSelf)": data]
        rooms().updateChildValues(childUpdates)
    }
}

