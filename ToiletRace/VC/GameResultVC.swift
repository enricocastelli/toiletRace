//
//  GameResultVC.swift
//  TheRace
//
//  Created by Enrico Castelli on 03/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class GameResultVC: UIViewController, StoreProvider, RematchProvider {

    @IBOutlet weak var barView: BarView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barHeight: NSLayoutConstraint!
    @IBOutlet weak var barRatio: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    
    var multiplayer: MultiplayerManager?
    var room: Room?
    var finalResults: [Result]
    var animationEnabled = true
    var resultTimer = Timer()
    
    init(results: [Result], room: Room? = nil) {
        finalResults = results
        self.room = room
        super.init(nibName: String(describing: GameResultVC.self), bundle: nil)
        guard let room = room else { return }
        self.multiplayer = MultiplayerManager(room: room, indexSelf: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        titleLabel.text = "RACE RESULTS"
        finalResults = finalResults.sorted { (obj1, obj2) -> Bool in
            guard let time1 = obj1.time , let time2 = obj2.time else { return false }
            return time1 < time2
        }
        setBarView()
        if let _ = multiplayer {
            resultTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (_) in
                self.updatePlayers()
            })
        }
    }
    
    private func setTableView() {
        tableView.backgroundColor = .white
        tableView.register(UINib(nibName: String(describing: ResultCell.self), bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 80, right: 0)
    }
    
    private func setBarView() {
        barView.rightImage = UIImage(systemName: "camera.fill")
        barView.onRightTap = share
        barView.lineHidden = false
        barView.leftImage = UIImage(systemName: "goforward")
        barView.onLeftTap = rematch
    }
    
    private func updatePlayers() {
        multiplayer?.updatePlayers({ (players) in
            for pl in players {
                let poo = pl.toPoo()
                guard pl.id != self.getID(), !self.finalResults.containsPoo(poo: poo), case .Finish(let time) = pl.status else { continue }
                let timeInterval = time.timeInterval()
                self.finalResults.append(Result(poo: poo, time: timeInterval, timeToWinner: self.timeToWinner(timeInterval ?? 0)))
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(item: self.finalResults.count - 1, section: 0)], with: .right)
                    self.tableView.endUpdates()
                }
            }
        })
    }
    
    private func timeToWinner(_ time: TimeInterval) -> TimeInterval {
        if let winner = finalResults.first?.time {
            return winner - time
        }
        return 0
    }
    
    private func share() {
        guard let img = takeScreenshot() else { return }
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        navigation.present(activityViewController, animated: true, completion: nil)
    }
    
    private func rematch() {
        if let room = room {
            multiplayerRematch(room)
        } else {
            goToRace()
        }
    }
    
    private func multiplayerRematch(_ room: Room) {
        barView.leftButton.isEnabled = false
        // first update room to get latest updates
        getRoom(room.id, completion: { (updatedRoom) in
            guard updatedRoom.players.count == self.finalResults.count else {
                self.presentAlert("Wait", subtitle: "Not every player finished the race yet!", firstButtonTitle: "Ok", secondButtonTitle: nil, firstCompletion: {}, secondCompletion: nil)
                self.barView.leftButton.isEnabled = true
                return
            }
            self.resultTimer.invalidate()
            let bathroom = BathroomVC(updatedRoom)
            bathroom.isRematch = true
            if updatedRoom.imOwner() {
                self.multiplayer?.sendStatus(PlayerStatus.Confirmed)
                self.updateRoomStatus(updatedRoom.id, .Waiting, {
                    self.navigation.push(bathroom, shouldRemove: true)
                }) { (error) in
                    self.barView.leftButton.isEnabled = true
                    self.presentGeneralError(error)
                }
            } else {
                self.multiplayer?.sendStatus(PlayerStatus.Confirmed)
                self.navigation.push(bathroom, shouldRemove: true)
            }
        }) { (error) in
            self.barView.leftButton.isEnabled = true
            self.presentGeneralError(error)
        }
    }
    
    private func getPlayers() -> [Poo] {
        var players = finalResults.map { $0.poo }
        guard let selfIndex = players.selfIndex(getID()) else { return [] }
         let selfPoo = players[selfIndex]
        players[selfIndex] = SessionData.shared.selectedPlayer
        // remove mightyPoo if is not user
        if selfPoo.name != .MightyPoop && players.contains(Poo(name: .MightyPoop)) {
            players.removeAll { $0.name == .MightyPoop }
        }
        return players
    }
    
    private func goToRace() {
        DispatchQueue.main.async {
            let gameVC = GameViewController(players: self.getPlayers())
            gameVC.room = self.room
            self.navigation.startLoading()
            self.navigation.goTo(gameVC)
        }
    }
    
    @IBAction func homeTapped(_ sender: UIButton) {
        navigation.push(WelcomeVC(), shouldRemove: true)
        resultTimer.invalidate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameResultVC: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultCell
        cell.index = indexPath.row
        cell.result = finalResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= 2 {
            return 104
        } else {
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        bounceCell(indexPath.row, cell as! ResultCell)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        animationEnabled = false
    }
    
    private func bounceCell(_ row: Int, _ cell: ResultCell){
        guard animationEnabled else { return }
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: view.frame.height)
        transform = transform.scaledBy(x: 0.4, y: 1)
        cell.transform = transform
        let duration = row <= 2 ? 0.4 : 0.3
        let delay = row <= 2 ? (0.3*Double(row)) : 1.0
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: [.curveEaseInOut], animations: {
            cell.transform = CGAffineTransform.identity
        }) { (_) in }
    }
}

    
extension GameResultVC: ScreenshotProvider {
   
    func willTakeScreenshot() {
        tableView.setContentOffset(.zero, animated: false)
        homeButton.isHidden = true
        barRatio.priority = .low
        barHeight.priority = .high
        topConstraint.constant = 40
        view.layoutIfNeeded()
    }
    
    func didTakeScreenShot() {
        homeButton.isHidden = false
        barHeight.priority = .low
        barRatio.priority = .high
        topConstraint.constant = 16
        view.layoutIfNeeded()
    }
    
}
