//
//  BathroomVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class BathroomVC: UIViewController, AlertProvider {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var barView: BarView!

    var room: Room
    var players: [Player] = []
    
    init(_ room: Room) {
        self.room = room
        players = room.players
        super.init(nibName: String(describing: BathroomVC.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isHidden = !room.imOwner()
        setupTable()
        setBarView()
        addPlayersObserver(room.id)
    }
    
    private func setupTable() {
        tableView.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: RoomCell.id, bundle: nil), forCellReuseIdentifier: RoomCell.id)
    }
    
    private func setBarView(){
        barView.onLeftTap = backTapped
        barView.rightImage = nil
        barView.lineHidden = false
    }
    
    private func roomWasDeleted() {
        if room == self.room && !self.room.imOwner() {
            presentAlert("OPS!", subtitle: "This room was closed!", firstButtonTitle: "OK", secondButtonTitle: nil, firstCompletion: {
                self.navigation.pop()
            }, secondCompletion: nil)
        }
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
        if room.imOwner() {
            presentAlert("Wait...", subtitle: "You are the owner of this room...if you leave the room will be deleted!", firstButtonTitle: "Delete it", secondButtonTitle: "Keep it", firstCompletion: {
                self.deleteRoom(self.room.id)
                self.navigation.pop()
            }, secondCompletion: nil)
        } else {
            unsubscribeFromRoom(room) {
                self.removePlayerObservers(self.room.id)
                self.navigation.pop()
            }
        }
    }
    
    @IBAction func startTapped(_ sender: UIButton) {
        guard room.imOwner() else { return }
        sendStartRoom(room.id) {
            self.goToRace()
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
        cell.player = players[indexPath.row]
        return cell
    }
}

extension BathroomVC: RoomsProvider {
   
    func roomIsReady() {
        removePlayerObservers(room.id)
        guard !room.imOwner() else { return }
        goToRace()
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
    
    func didAddedRoom(_ room: Room) {}
    func didRemovedRoom(_ room: Room) {}
    
}
