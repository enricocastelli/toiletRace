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
        addPlayersObserver(room.id)
    }
    
    func setupTable() {
        tableView.backgroundColor = .white
    }
    
    func goToRace() {
        DispatchQueue.main.async {
            let gameVC = GameViewController(players: self.players.toPoos())
            gameVC.room = self.room
            self.navigation.goTo(gameVC)
            self.navigation.startLoading()
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        if room.imOwner() {
            deleteRoom(room.id)
        } else {
            unsubscribeFromRoom(room) {
                self.removePlayerObservers(self.room.id)
            }
        }
        navigation.pop()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        removeObservers()
//        Navigation.main.pushViewController(BathroomVC(rooms[indexPath.row]), animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = players[indexPath.row].name
        cell.selectionStyle = .none
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
    }
    
    func didAddedRoom(_ room: Room) {}
    func didRemovedRoom(_ room: Room) {}
    
}
