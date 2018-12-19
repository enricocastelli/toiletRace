//
//  MultiplayerVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 19/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultiplayerVC: UIViewController {

    var tableView: UITableView!
    var multiplayer: MultiplayerManager!
    var players : Array<MCPeerID> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setupMultiplayer()
    }
    
    func setupTable() {
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupMultiplayer() {
        multiplayer = MultiplayerManager(delegate: nil, connectionDelegate: self)
    }

}

extension MultiplayerVC: MultiplayerConnectionDelegate {
    
    func didFoundPeer(_ peer: MCPeerID) {
        
    }
    
    func didReceiveInvitation(peerID: MCPeerID, invitationHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Hoi!", message: "You just received an invitation game from: \(peerID.displayName).", preferredStyle: UIAlertController.Style.alert)
        let action1 = UIAlertAction(title: "Not now", style: UIAlertAction.Style.cancel) { (action) in
            invitationHandler(false)
        }
        let action2 = UIAlertAction(title: "Accept", style: UIAlertAction.Style.default) { (action) in
            invitationHandler(true)
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true) {
            
        }
    }
    
}

extension MultiplayerVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension MultiplayerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
