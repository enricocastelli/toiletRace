//
//  BathroomVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class BathroomVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var barView: BarView!

    var room: Room
    var players: [Player] = []
    var isRematch = false
    var confirmed = false
    
    init(_ room: Room) {
        self.room = room
        players = room.players
        super.init(nibName: String(describing: BathroomVC.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setBarView()
        addPlayersObserver(room.id)
        navigation.isSwipeBackEnabled = false
    }
    
    private func setupTable() {
        tableView.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: RoomCell.id, bundle: nil), forCellReuseIdentifier: RoomCell.id)
        tableView.separatorStyle = .none
    }
    
    private func setBarView(){
        barView.leftImage = isRematch ? UIImage(systemName: "house.fill") : UIImage(systemName: "arrow.left.circle.fill")
        barView.onLeftTap = backTapped
        barView.rightImage = UIImage(systemName: "link.circle.fill")
        barView.rightButton.tintColor = UIColor.aqua
        barView.onRightTap = shareLink
        barView.lineHidden = false
    }
    
    private func roomWasDeleted() {
        if room == self.room && !self.room.imOwner() {
            presentAlert("OPS!", subtitle: "This room was closed!", firstButtonTitle: "OK", secondButtonTitle: nil, firstCompletion: {
                self.isRematch ? self.navigation.goTo(WelcomeVC()) : self.navigation.pop()
            }, secondCompletion: nil)
        }
    }
    
    private func setConfirmed() {
        confirmed = true
        startButton.setTitle("Waiting...", for: .normal)
        startButton.setImage(UIImage(systemName: "slowmo"), for: .normal)
        startButton.backgroundColor = UIColor.lightGray
        startButton.isEnabled = false
    }
            
    private func goToRace() {
        DispatchQueue.main.async {
            self.room.players = self.players
            let gameVC = GameViewController(players: self.players.toPoos())
            gameVC.room = self.room
            self.navigation.startLoading()
            self.navigation.goTo(gameVC)
        }
    }
    
    func backTapped() {
        barView.leftButton.isEnabled = false
        if room.imOwner() {
            presentAlert("Wait...", subtitle: "You are the owner of this room...if you leave the room will be deleted!", firstButtonTitle: "Delete it", secondButtonTitle: "Keep it", firstCompletion: {
                self.deleteRoom(self.room.id, completion: {
                    self.barView.leftButton.isEnabled = true
                    self.isRematch ? self.navigation.goTo(WelcomeVC()) : self.navigation.pop()
                }) { (error) in
                    self.barView.leftButton.isEnabled = true
                    self.presentGeneralError(error)
                }
            }, secondCompletion: nil)
        } else {
            unsubscribeFromRoom(room, completion: {
                self.barView.leftButton.isEnabled = true
                self.removePlayerObservers(self.room.id)
                self.isRematch ? self.navigation.goTo(WelcomeVC()) : self.navigation.pop()
            }) { (error) in
                self.barView.leftButton.isEnabled = true
                self.presentGeneralError(error)
            }
        }
    }
    
    func shareLink() {
        guard let link = DeeplinkManager.shared.urlWithRoom(room.id) else { return }
        let activityViewController = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        navigation.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func startTapped(_ sender: UIButton) {
        sender.isEnabled = false
        if room.imOwner() {
            badgeCheck()
            sendStartRoom(room.id, completion: {
                self.goToRace()
            }) { (error) in
                sender.isEnabled = true
                self.presentGeneralError(error)
            }
        } else {
            sender.isEnabled = false
            updatePlayerStatus(room.id, status: .Confirmed, completion: {
                self.setConfirmed()
            }) { (error) in
                sender.isEnabled = true
                self.presentGeneralError(error)
            }
        }
    }
    
    private func badgeCheck() {
        if room.players.count == 1 {
            self.saveBadge(.foreverAlone)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension BathroomVC: UITableViewDelegate, UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.id, for: indexPath) as! RoomCell
        let pl = players[indexPath.row]
        cell.player = pl
        if let owner = room.owner() {
            cell.isOwner = owner.id == pl.id
        }
        return cell
    }
}

extension BathroomVC: PlayersProvider {
    
    func roomIsReady() {
        guard !room.imOwner() else { return }
        if confirmed {
            // user is ready to play
            removePlayerObservers(room.id)
            goToRace()
        } else {
            presentAlert("OPS!", subtitle: "This room started without you!", firstButtonTitle: "OK", secondButtonTitle: nil, firstCompletion: {
                self.isRematch ? self.navigation.goTo(WelcomeVC()) : self.navigation.pop()
            }, secondCompletion: nil)
        }
    }
    
    func didAddedPlayer(_ player: Player) {
        guard !players.contains(where: {$0.id == player.id}) else { return }
        self.players.append(player)
        tableView.reloadData()
    }
    
    func didRemovedPlayer(_ player: Player) {
        self.players.removeAll {$0.id == player.id }
        self.tableView.reloadData()
        roomExist(room.id) { (exist) in
            if !exist && !self.room.imOwner() {
                self.roomWasDeleted()
            }
        }
    }
    
    func didChangePlayer(_ player: Player) {
        self.players.replace(player)
        self.tableView.reloadData()
    }
}
