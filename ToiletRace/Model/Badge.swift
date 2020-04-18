//
//  Badge.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 17/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

enum Badge: Int {
    case flushWinner, faster, noWipe , pipeDominator, foreverAlone, almightyPooper
    
    static let array = [flushWinner, faster, noWipe, pipeDominator, foreverAlone, almightyPooper]
    
    init(_ index: Int) {
        switch index {
        case 0: self = .flushWinner // win 10 races
        case 1: self = .faster // faster than 30:00
        case 2: self = .noWipe // no contacts
        case 3: self = .pipeDominator // win 10 races multiplayer
        case 4: self = .foreverAlone // play a multiplayer race by yourself
        case 5: self = .almightyPooper // win 50 races
        default: self = .noWipe
        }
    }
    
    var desc: String {
        switch self {
        case .noWipe: return "No Wipe"
        case .faster: return "Fast Fart"
        case .flushWinner: return "Flush Winner"
        case .pipeDominator: return "Pipe Dominator"
        case .almightyPooper: return "Almighty Pooper!"
        case .foreverAlone: return "Forever Alone"
        }
    }
    
    var image: UIImage {
        switch self {
        case .noWipe: return UIImage.clean
        case .faster: return UIImage.fart
        case .flushWinner: return UIImage.washroom
        case .pipeDominator: return UIImage.plunger
        case .almightyPooper: return UIImage.winner
        case .foreverAlone: return UIImage.heartbreak
        }
    }
    
    var explanation: String {
        switch self {
        case .noWipe: return "Run a race without colliding with anything."
        case .faster: return "Complete a race in less than 30 seconds."
        case .flushWinner: return "Win 10 races."
        case .pipeDominator: return "Win 10 multiplayer races."
        case .almightyPooper: return "Win 50 races."
        case .foreverAlone: return "Super secret badge..."
        }
    }
    
    var index: Int {
        return self.rawValue
    }
    
    var poo: PooName {
        switch self {
        case .flushWinner: return .IndianSurprise
        case .faster: return .BrownTornado
        case .noWipe: return .GarganTurd
        case .pipeDominator: return .FecalRaider
        case .foreverAlone: return .MightyPoop
        case .almightyPooper: return .ApolloPoo
        }
    }
}
