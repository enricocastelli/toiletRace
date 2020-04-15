//
//  RematchProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 15/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//


import Foundation
import FirebaseDatabase

protocol RematchProvider: PlayersProvider {}

extension RematchProvider {

    
    
    
    // Unused database methods
    func roomIsReady() {}
    func didAddedPlayer(_ player: Player) {}
    func didRemovedPlayer(_ player: Player) {}
    func didChangePlayer(_ player: Player) {}
}
