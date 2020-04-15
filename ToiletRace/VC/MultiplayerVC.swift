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
    @IBOutlet weak var barView: BarView!
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setBarView()
        addRoomsObserver()
    }
    
    private func setupTable() {
        tableView.backgroundColor = .white
        tableView.refreshControl = UIRefreshControl()
        tableView.register(UINib(nibName: RoomCell.id, bundle: nil), forCellReuseIdentifier: RoomCell.id)
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl),for: .valueChanged)
    }
    
    private func setBarView(){
        barView.onLeftTap = backTapped
        barView.onRightTap = addTapped
        barView.rightImage = UIImage(systemName: "plus.app.fill")
        barView.rightButton.tintColor = UIColor.aqua
        barView.lineHidden = false
    }
        
    private func backTapped() {
        navigation.pop()
    }
    
    private func addTapped() {
        presentFieldAlert("Create a new Room", subtitle: "Type a name...", textPlaceholder: "The Bathroom", firstButtonTitle: "OK", secondButtonTitle: "Cancel", firstCompletion: { text in
            let room = self.createRoom(text)
            self.navigation.push(BathroomVC(room))
        }, secondCompletion: nil)
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
    
    private func subscribe(_ room: Room) {
        guard room.players.count < 8 else {
            presentAlert("Ops!", subtitle: "Too many poops in here!", firstButtonTitle: "Ok", secondButtonTitle: nil, firstCompletion: {}, secondCompletion: nil)
            return }
        removeRoomObservers()
        subscribeToRoom(room.id) { (room) in
            self.navigation.push(BathroomVC(room))
        }
    }
}


extension MultiplayerVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        roomExist(room.id) { (exist) in
            exist ? self.subscribe(room) : self.handleRefreshControl()
        }
    }
}

extension MultiplayerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.id, for: indexPath) as! RoomCell
        cell.room = rooms[indexPath.row]
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
