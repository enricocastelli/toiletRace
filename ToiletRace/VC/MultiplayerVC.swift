//
//  MultiplayerVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 19/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultiplayerVC: UIViewController, StoreProvider {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barView: BarView!
    @IBOutlet weak var roomsLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    
    var rooms: [Room] = [] {
        didSet {
            roomsLabel.text = "\(rooms.count) ROOMS OPEN"
        }
    }
    var createRoomVC: CreateRoomVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setBarView()
        addRoomsObserver()
        roomsLabel.text = "\(rooms.count) ROOMS OPEN"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleRefreshControl()
    }
        
    private func setupTable() {
        tableView.backgroundColor = .white
        tableView.refreshControl = UIRefreshControl()
        tableView.register(UINib(nibName: RoomCell.id, bundle: nil), forCellReuseIdentifier: RoomCell.id)
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl),for: .valueChanged)
        tableView.separatorStyle = .none
    }
    
    private func setBarView(){
        barView.onLeftTap = backTapped
        barView.onRightTap = addTapped
        barView.rightImage = UIImage(systemName: "plus.app.fill")
        barView.rightButton.tintColor = UIColor.aqua
        barView.lineHidden = false
    }
    
    @IBAction func createTapped(_ sender: UIButton) {
        addTapped()
    }
    
    private func backTapped() {
        navigation.pop()
    }
    
    private func addTapped() {
        createRoomVC = CreateRoomVC()
        createRoomVC?.delegate = self
        createRoomVC?.modalPresentationStyle = .overCurrentContext
        self.present(createRoomVC!, animated: false, completion: nil)
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
        subscribeToRoom(room.id, completion: { (room) in
            self.navigation.push(BathroomVC(room))
        }) { (error) in
            self.presentGeneralError(error)
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

    
    func didAddedRoom(_ room: Room) {
        self.rooms.append(room)
        self.tableView.reloadData()
    }
    
    func didRemovedRoom(_ room: Room) {
        self.rooms.removeAll {$0.id == room.id }
        self.tableView.reloadData()
    }
}

extension MultiplayerVC: CreateRoomDelegate { 
    
    func shouldCreateRoom(name: String, isPrivate: Bool) {
        self.createRoom(name, isPrivate: isPrivate, completion: { (room) in
            self.removeRoomObservers()
            self.createRoomVC?.closeAnimation()
            self.navigation.push(BathroomVC(room))
        }) { (error) in
            self.presentGeneralError(error)
        }
    }
}
