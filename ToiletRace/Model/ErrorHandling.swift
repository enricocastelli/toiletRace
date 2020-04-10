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
        default:
            return "Something went wrong. We are too lazy to find out what."
        }
    }
}

enum PooError: Error {
    
}
