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
    var penalty: Bool?
}

import Foundation
import SceneKit

class RaceResultManager {
    
    static var shared = RaceResultManager()
    /// startDate is saved when game start (calculate the timing off players when they finish the track -> totalTime = startDate - arrivalDate
    private var startDate : Date?
    ///final results created when players finish the track and passed to GameResultVC for showing time and positions
    var finalResults: [Result] = []
    ///property to detect if game is finished and asking for results
    private var isGameOver = false
    private var length: Float = 0
    
    func start(_ length: Float) {
        self.length = length
        isGameOver = false
        startDate = Date()
        finalResults = []
    }
    
    func didFinish(poo: Poo, penalty: Bool) {
        guard isGameOver == false, !finalResults.contains(where: { $0.player.id == poo.id}) else { return }
        let result = createResult(poo: poo, penalty: penalty)
        finalResults.append(result)
    }
    
    private func createResult(poo: Poo, penalty: Bool) -> Result {
        let totalTime = calculateTime(firstDate: startDate!) + (penalty ? 3 : 0)
        let toWinner = timeToWinner(totalTime)
        let result = Result(player: poo, time: totalTime, timeToWinner: toWinner, penalty: penalty)
        return result
    }
    
    func getResults(opponents: [Poo]) -> [Result] {
        // checking final result contains all the results
        isGameOver = true
        guard finalResults.count != opponents.count + 1 else { return finalResults } // user is last
        for opponent in opponents {
            // opponent's result is already in final results
            guard !finalResults.containsPoo(poo: opponent) else { continue }
            // opponent's result is not in final results, so didn't finish yet, i have to calculate a simulated time
            let distance = abs(length) + opponent.node.presentation.position.z
            let totalTime = calculateTime(firstDate: startDate!) + distance/10
            let toWinner = timeToWinner(totalTime)
            let res = Result(player: opponent, time: totalTime, timeToWinner: toWinner, penalty: false)
            finalResults.append(res)
        }
        return finalResults
    }
    
    private func timeToWinner(_ time: Float) -> Float {
        if let winner = finalResults.first?.time {
            return winner - time
        }
        return 0
    }
    
    private func calculateTime(firstDate: Date) -> Float {
        return Float(Date().timeIntervalSince(firstDate))
    }
}
