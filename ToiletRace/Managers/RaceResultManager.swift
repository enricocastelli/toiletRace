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
    ///property to detect if game is finished and asking for results
    var isGameOver = false
    
    func start() {
        isGameOver = false
        startDate = Date()
        finalResults = []
    }
    
    func didFinish(poo: PooName, penalty: Bool) {
        guard isGameOver == false else { return }
        let result = createResult(poo: poo, penalty: penalty)
        finalResults.append(result)
    }
    
    func  createResult(poo: PooName, penalty: Bool) -> Result {
        let time : Float = {
            let totalTime = calculateTime(firstDate: startDate!)
            return totalTime + (penalty ? 3 : 0)
        }()
        //            let total = Data.shared.scores[node.name!] ?? 0
        let timeToWinner : Float = {
            if let winner = finalResults.first?.time {
                return winner - time
            }
            return 0
        }()
        let result = Result(player: Poo(name: poo), time: time, timeToWinner: timeToWinner, points: 0, penalty: penalty)
        return result
    }
    
    func getResults(opponents: [Poo], length: Float) {
        // checking final result contains all the results
        isGameOver = true
        if finalResults.count != opponents.count + 1 {
            for opponent in opponents {
                if finalResults.contains(where: { $0.player.name.rawValue == opponent.name.rawValue}) {
                    // opponent's result is already in final results
                } else {
                    // opponent's result is not in final results, so didn't finish yet, i have to calculate a simulated time
                    let distance = abs(length) + opponent.node!.presentation.position.z
                    var time = calculateTime(firstDate: startDate!)
                    time += distance/10
                    let timeToWinner : Float = {
                        if let winner = finalResults.first?.time {
                            return winner - time
                        }
                        return 0
                    }()
                    let res = Result(player: Poo(name: PooName(rawValue: opponent.name.rawValue)!), time: time, timeToWinner: timeToWinner, points: 0, penalty: false)
                    finalResults.append(res)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.showResults()
        })
    }
    
    func didFinishMultiplayer(poo: Poo, gameOver: Bool) {
        let time : Float = {
            let totalTime = calculateTime(firstDate: startDate!)
            return totalTime
        }()
        let timeToWinner : Float = {
            if let winner = finalResults.first?.time {
                return winner - time
            }
            return 0
        }()
        let result = Result(player: poo, time: time, timeToWinner: timeToWinner, points: 0, penalty: nil)
        finalResults.append(result)
        if gameOver {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.showResults()
            })
        }
    }
    
    func calculateTime(firstDate: Date) -> Float {
        return Float(Date().timeIntervalSince(firstDate))
    }
    
    func showResults() {
        DispatchQueue.main.async {
            let result = GameResultVC(results: self.finalResults)
            Navigation.main.viewControllers = [result]
        }
    }
    
    
}
