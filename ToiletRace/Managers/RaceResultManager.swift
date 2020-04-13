//
//  RaceResultManager.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 18/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

struct Result {
    var poo: Poo
    var time: TimeInterval?
    var timeToWinner: TimeInterval?
}

import Foundation
import SceneKit

class RaceResultManager {
    
    /// startDate is saved when game start (calculate the timing off players when they finish the track -> totalTime = startDate - arrivalDate
    private var startDate = Date()
    ///final results created when players finish the track and passed to GameResultVC for showing time and positions
    var finalResults: [Result] = []
    ///property to detect if game is finished and asking for results
    private var isGameOver = false
    private let length: Float
    
    init(_ length: Float) {
        self.length = length
    }
    
    func start() {
        isGameOver = false
        startDate = Date()
        finalResults = []
    }
    
    func didFinish(poo: Poo, timeString: String? = nil) {
        guard isGameOver == false, !finalResults.contains(where: { $0.poo == poo }) else { return }
        let result = createResult(poo: poo, timeString: timeString)
        finalResults.append(result)
    }
    
    private func createResult(poo: Poo, timeString: String? = nil) -> Result {
        let totalTime = timeString?.timeInterval() ?? calculateTime()
        let toWinner = timeToWinner(calculateTime())
        let result = Result(poo: poo, time: totalTime, timeToWinner: toWinner)
        return result
    }
    
    func getResults(opponents: [Poo]) -> [Result] {
        // checking final result contains all the results
        isGameOver = true
        guard finalResults.count != opponents.count + 1 else { return finalResults } // user is last
        for opponent in opponents {
            // opponent's result is already in final results
            guard !finalResults.containsPoo(poo: opponent) && !opponent.isMultiplayer else { continue }
            // opponent's result is not in final results, so didn't finish yet, i have to calculate a simulated time
            let distance = abs(length) + opponent.node.presentation.position.z
            let totalTime = calculateTime() + TimeInterval(distance/10)
            let toWinner = timeToWinner(totalTime)
            let res = Result(poo: opponent, time: totalTime, timeToWinner: toWinner)
            finalResults.append(res)
        }
        return finalResults
    }
    
    func userTime() -> TimeInterval? {
        return finalResults.filter { $0.poo == SessionData.shared.selectedPlayer }.first?.time
    }
    
    private func timeToWinner(_ time: TimeInterval) -> TimeInterval {
        if let winner = finalResults.first?.time {
            return winner - time
        }
        return 0
    }
    
    private func calculateTime() -> TimeInterval {
        return Date().timeIntervalSince(startDate)
    }
}
