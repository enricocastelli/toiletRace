//
//  MultiplayerVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 19/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultiplayerVC: UIViewController, StoreProvider, AlertProvider {

    @IBOutlet weak var tableView: UITableView!
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        addRoomsObserver()
    }
    
    func setupTable() {
        tableView.backgroundColor = .white
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action:
            #selector(handleRefreshControl),for: .valueChanged)
    }
    
    
    @IBAction func backTapped(_ sender: UIButton) {
        Navigation.main.popToRootViewController(animated: true)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        let room = createRoom("testami")
        Navigation.main.pushViewController(BathroomVC(room), animated: true)
    }
    
    @objc func handleRefreshControl() {
        rooms = []
        tableView.reloadData()
        removeRoomObservers()
        addRoomsObserver()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}


extension MultiplayerVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removeRoomObservers()
        subscribeToRoom(rooms[indexPath.row].id) { (room) in
            Navigation.main.pushViewController(BathroomVC(room), animated: true)
        }
    }
}

extension MultiplayerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = rooms[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
}


extension MultiplayerVC: RoomsProvider {
    
    func roomIsReady() {}
    func didAddedPlayer(_ player: Player) {}
    func didRemovedPlayer(_ player: Player) {}
    
    func didAddedRoom(_ room: Room) {
        self.rooms.append(room)
        self.tableView.reloadData()
    }
    
    func didRemovedRoom(_ room: Room) {
        self.rooms.removeAll {$0.id == room.id }
        self.tableView.reloadData()
    }
}
