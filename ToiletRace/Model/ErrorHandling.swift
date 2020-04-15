//
//  ErrorHandling.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation

extension Error {

    var message: String {
        switch self as? PooError {
        case .RoomDeleted: return "This room was deleted!"
        case .GeneralError: return "Some poo got stuck somewhere...sorry for that"
        default:
            return "Something went wrong. We are too lazy to find out what."
        }
    }
}

enum PooError: Error {
    case RoomDeleted
    case GeneralError
}
