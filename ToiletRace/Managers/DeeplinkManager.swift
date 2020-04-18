//
//  DeeplinkManager.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 17/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class DeeplinkManager: RoomsProvider {
    
    var link: String?
    static let shared = DeeplinkManager()
    
    func open(_ link: String) {
        guard let nav = UIApplication.shared.delegate?.window??.rootViewController as? Navigation else { return }
        getRoom(link, completion: { (room) in
            self.subscribeToRoom(room.id, completion: { (room) in
                SessionData.shared.preopenedRoom = room
                nav.push(ShowroomVC(true))
            }) { (_) in} }) { (_ ) in }
    }
    
    func urlWithRoom(_ roomID: String) -> URL? {
        return URL(string: "https://thetoiletrace.page.link/race:\(roomID)")
    }
    
    func didAddedRoom(_ room: Room) {}
    func didRemovedRoom(_ room: Room) { }
    
}
