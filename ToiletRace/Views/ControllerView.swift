//
//  ControllerView.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 17/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//
protocol ControllerViewDelegate {
    
}

import Foundation
import UIKit

class ControllerView: UIView {
    
    var gameVC: GameViewController
    /// tableView showing the results in real time (updated every 0.3 sec)
    var resultTable: UITableView!
    /// color of text in table result
    var cellTextColor = UIColor.black
    /// color of layer background of cell text if poop has bonus enabled
    var backgroundCellColor = UIColor.white
    /// timer that triggers update of the table result
    var tableTimer = Timer()
    // UI: Label ready/Go, bonus button
    var startLabel = UILabel()
    var bonusButton : BonusButton?
    var touchLocation = CGPoint()
    var isPlaying = false

    
    init(frame: CGRect, gameVC: GameViewController) {
        self.gameVC = gameVC
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupTable()
        setupLabel()
        setupBonusButton()
        setupStopButton()
        alpha = 0
    }
    
    func setupTable() {
        resultTable = UITableView(frame: CGRect(x: 10, y: 10, width: 250, height: 400), style: .plain)
        resultTable.dataSource = self
        resultTable.backgroundColor = UIColor.clear
        resultTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        resultTable.separatorStyle = .none
        resultTable.rowHeight = 34
        resultTable.isUserInteractionEnabled = false
        self.addSubview(resultTable)
    }
    
    func setupLabel() {
        startLabel = UILabel(frame: CGRect(x: 300, y: 200, width: 400, height: 100))
        startLabel.font = UIFont.boldSystemFont(ofSize: 50)
        startLabel.text = "READY"
        startLabel.textColor = UIColor.red
        self.insertSubview(startLabel, at: 2)
    }
    
    func setupBonusButton() {
        guard let bonus = Data.shared.selectedPlayer.bonus() else { return }
        bonusButton = BonusButton(frame: CGRect(x: frame.width - 100, y: frame.height - 100, width: 64, height: 64), bonus: bonus, delegate: gameVC)
        addSubview(bonusButton!)
    }
    
    func setupStopButton() {
        let stopButton = UIButton(frame: CGRect(x: frame.width - 44, y: 8, width: 36, height: 36))
        stopButton.setTitle("⏹", for: .normal)
        stopButton.addTarget(self, action: #selector(stopped), for: .touchUpInside)
        stopButton.alpha = 0.3
        addSubview(stopButton)
    }
    
    func start() {
        isPlaying = true
        startUpdateTimer()
        updateLabel()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchLocation  = touch.location(in: self)
        guard isPlaying == true else { return }
        gameVC.shouldTurn(right: touchLocation.x > UIScreen.main.bounds.width/2)
    }
    
    func startUpdateTimer() {
        tableTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updateTable), userInfo: nil, repeats: true)
    }
    
    func updateLabel() {
        DispatchQueue.main.async {
            self.startLabel.text = "GO!!!"
            self.startLabel.textColor = UIColor.green
            self.perform(#selector(self.removeLabel), with: nil, afterDelay: 1)
        }
    }
    
    @objc func updateTable() {
        gameVC.ranking = gameVC.currentPlayers.sorted { (obj1, obj2) -> Bool in
            return obj1.distance < obj2.distance
        }
        DispatchQueue.main.async {
            self.resultTable.reloadData()
        }
    }
    
    @objc func removeLabel() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, animations: {
                self.startLabel.alpha = 0
            }) { (done) in
                self.startLabel.removeFromSuperview()
            }
        }
    }
    
    func removeBonus() {
        bonusButton?.removeFromSuperview()
    }
    
    func stop() {
        isPlaying = false
        tableTimer.invalidate()
    }
    
    @objc func stopped() {
        gameVC.stopped()
    }
    
    func addFinishView() {
        DispatchQueue.main.async {
            let finishView = UIView(frame: self.frame)
            finishView.backgroundColor = UIColor.white
            finishView.alpha = 0
            self.addSubview(finishView)
            UIView.animate(withDuration: 0.5, animations: {
                finishView.alpha = 1
            }, completion: { (done) in
            })
        }
    }
}

extension ControllerView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameVC.ranking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.layer.cornerRadius = 10
        if RaceResultManager.shared.finalResults.count > indexPath.row {
            cell.textLabel?.text = "\(indexPath.row + 1)) \(RaceResultManager.shared.finalResults[indexPath.row].player.name.rawValue)"
            cell.imageView?.image = UIImage(color: RaceResultManager.shared.finalResults[indexPath.row].player.color())
            let ball = RaceResultManager.shared.finalResults[indexPath.row]
            if indexPath.row != 0 {
                cell.detailTextLabel?.text = "\((ball.timeToWinner ?? 0).string())"
                cell.detailTextLabel?.textColor = UIColor.red
            } else {
                cell.detailTextLabel?.text = "\(ball.time.string())"
                cell.detailTextLabel?.textColor = cellTextColor
            }
        } else {
            cell.textLabel?.text = " \(indexPath.row + 1)) \(gameVC.ranking[indexPath.row].name.rawValue) "
            cell.imageView?.image = UIImage(color: gameVC.ranking[indexPath.row].color())
            if gameVC.ranking[indexPath.row].bonusEnabled == true {
                cell.textLabel?.layer.backgroundColor = backgroundCellColor.cgColor
            } else {
                cell.textLabel?.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        
        // common config
        cell.textLabel?.textColor = cellTextColor
        cell.backgroundColor = UIColor.clear
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 10
        if cell.textLabel?.text?.contains(Data.shared.selectedPlayer.name.rawValue) ?? false {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.contentView.alpha = 0.8
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.contentView.alpha = 0.4
        }
        return cell
    }
}



