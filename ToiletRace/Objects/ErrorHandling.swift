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
        switch self as? LazyError {
        case .wrongDate: return "There's something wrong with dates and time! God forgive us!"
        case .notEnoughData: return "You don't have enough data apparently...wait a little bit and come back!"
        case .userNotFound: return "We could not find this lazy player"
        case .errorUpdating: return "We couldn't update data. Check your lazy internet connection.."
        case .alreadyFriend: return "This lazy player is already in your list!"
        case .parsingError: return "Something went wrong. We were expecting bananas and got coconuts."
        case .noFriends: return "Seems like you don't have any lazy friend...add someone!"

        default:
            return "Something went wrong. We are too lazy to find out what."
        }
    }
}

enum LazyError: Error {
    case wrongDate
    case notEnoughData
    case userNotFound
    case errorUpdating
    case alreadyFriend
    case parsingError
    case noFriends

}
