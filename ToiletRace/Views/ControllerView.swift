//
//  ControllerView.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 17/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class ControllerView: NibView {
    
    var gameVC: GameViewController
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var bonusButton: BonusButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var tableViewWidth: NSLayoutConstraint!

    /// timer that triggers update of the table result
    var tableTimer = Timer()
    var touchLocation = CGPoint()
    var isPlaying = false
    
    var location: CGFloat = 0
    var isTouching = false
    
    init(frame: CGRect, gameVC: GameViewController) {
        self.gameVC = gameVC
        super.init(frame: frame)
        setup()
    }

    func setup() {
        setupTable()
        setupBonusButton()
        preAnimation()
        bonusButton.alpha = 0
    }
    
    func setupTable() {
        resultTableView.backgroundColor = UIColor.clear
        resultTableView.register(UINib(nibName: RankCell.id, bundle: nil), forCellReuseIdentifier: RankCell.id)
        tableViewWidth.constant = UIScreen.main.bounds.width/1.8
    }
    
    func setupBonusButton() {
        guard let bonus = SessionData.shared.selectedPlayer.bonus() else { return }
        bonusButton.updateBonus(bonus: bonus)
        bonusButton.delegate = gameVC
    }
    
    private func preAnimation() {
        resultTableView.alpha = 0
        blurView.transform = CGAffineTransform(translationX: 0, y: -frame.height)
    }
    
    func prepare(){
        DispatchQueue.main.async {
            self.label.text = self.gameVC.multiplayer == nil ? "READY?" : "WAITING FOR OTHER POOPS..."
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
                self.blurView.transform = CGAffineTransform.identity
            }) { (_) in
            }
        }
    }
    
    func start() {
        DispatchQueue.main.async {
            self.isPlaying = true
            self.startUpdateTimer()
            self.label.text = "GO!"
            self.label.textColor = UIColor.goGreen
            UIView.animate(withDuration: 1) {
                self.resultTableView.alpha = 1
                self.label.transform = CGAffineTransform(scaleX: 3, y: 3)
                self.blurView.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
                self.bonusButton.alpha = 1
            }
        }
    }
    
    func hideTable() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4) {
                self.resultTableView.alpha = 0
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchLocation  = touch.location(in: self)
        guard isPlaying == true else { return }
        if !isTouching {
            isTouching = true
            location = touchLocation.x
        } else {
            gameVC.shouldTurn(force: (touchLocation.x - location)/20)
            location = touchLocation.x
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }
        
    func startUpdateTimer() {
        tableTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (timer) in
            self.updateTable()
        })
    }
    
   func updateTable() {
        gameVC.ranking = gameVC.currentPlayers.sorted { (obj1, obj2) -> Bool in
            return obj1.distance < obj2.distance
        }
        DispatchQueue.main.async {
            self.resultTableView.reloadData()
        }
    }

    func stop() {
        isPlaying = false
        tableTimer.invalidate()
    }
    
    @IBAction func stopTapped() {
        gameVC.stopped()
        stop()
    }
    
    func removeBonus() {
        bonusButton.isHidden = true
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ControllerView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameVC.ranking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RankCell.id, for: indexPath) as! RankCell
        cell.index = indexPath.row
        if gameVC.raceResultManager.finalResults.count > indexPath.row {
            // this poo finished the race
            let result = gameVC.raceResultManager.finalResults[indexPath.row]
            cell.result = result
        } else {
            // this poo is in the race.
            let poo = gameVC.ranking[indexPath.row]
            cell.poo = poo
        }
        return cell
    }
}



