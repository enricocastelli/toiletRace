//
//  RaceResultManager.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 18/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

struct Result {
    var player: Poo
    var time: Float
    var timeToWinner: Float?
    var points: Float
    var totalPoints: Float
    var penalty: Bool?
}

import Foundation
import SceneKit

class RaceResultManager: NSObject {
    
    static var shared = RaceResultManager()
    /// startDate is saved when game start (calculate the timing off players when they finish the track -> totalTime = startDate - arrivalDate
    var startDate : Date?
    ///final results created when players finish the track and passed to GameResultVC for showing time and positions
    var finalResults: [Result] = []
    
    func start() {
        startDate = Date()
    }
    
    func didFinish(poo: PooName, penalty: Bool) {
        let time : Float =  calculateTime(firstDate: startDate!)
        //            let total = Data.shared.scores[node.name!] ?? 0
        let total : Float = 0
        let timeToWinner : Float = {
            if let winner = finalResults.first?.time {
                return winner - time
            }
            return 0
        }()
        let result = Result(player: Poo(name: poo), time: time, timeToWinner: timeToWinner, points: 0, totalPoints: total, penalty: penalty)
        finalResults.append(result)
    }
    
    func getResults(opponents: [Poo], length: Float) {
        if finalResults.count != players.count {
            for opponent in opponents {
                if finalResults.contains(where: { $0.player.name.rawValue == opponent.name.rawValue}) {
                } else {
                    let distance = abs(length) + opponent.node!.presentation.position.z
                    var time = calculateTime(firstDate: startDate!)
                    time += distance/10
                    let timeToWinner : Float = {
                        if let winner = finalResults.first?.time {
                            return winner - time
                        }
                        return 0
                    }()
                    let total = (Data.shared.scores[opponent.name.rawValue] ?? 0)
                    let res = Result(player: Poo(name: PooName(rawValue: opponent.name.rawValue)!), time: time, timeToWinner: timeToWinner, points: 0, totalPoints: total, penalty: false)
                    finalResults.append(res)
                }
            }
        }
        perform(#selector(showResults), with: nil, afterDelay: 2)
    }
    
    func calculateTime(firstDate: Date) -> Float {
        return Float(Date().timeIntervalSince(firstDate))
    }
    
    @objc func showResults() {
        let result = GameResultVC(results: finalResults)
        Navigation.main.viewControllers = [result]
    }
    
    
}
