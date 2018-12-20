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


    @IBOutlet weak var tableView: UITableView!
    var multiplayer: MultiplayerManager!
    var players : Array<MCPeerID> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setupMultiplayer()
    }
    
    func setupTable() {
        
    }
    
    func setupMultiplayer() {
        multiplayer = MultiplayerManager(delegate: nil, connectionDelegate: self)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        multiplayer.stop()
        Navigation.main.popToRootViewController(animated: true)
    }
    
}

extension MultiplayerVC: MultiplayerConnectionDelegate {
    
    func didFoundPeer(_ peer: MCPeerID) {
        if !players.contains(peer) {
            players.append(peer)
            tableView.reloadData()
        }
    }
    
    func didReceiveInvitation(peerID: MCPeerID, invitationHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Oh 💩", message: "You just received an invitation game from this poo: \(peerID.displayName).", preferredStyle: UIAlertController.Style.alert)
        let action1 = UIAlertAction(title: "Nope", style: UIAlertAction.Style.cancel) { (action) in
            invitationHandler(false)
        }
        let action2 = UIAlertAction(title: "Race", style: UIAlertAction.Style.default) { (action) in
            invitationHandler(true)
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true) {
            
        }
    }
    
    func didDisconnect() {
        
    }
    
    func didConnect() {
        DispatchQueue.main.async {
            let gameVC : GameViewController = {
                return ToiletViewController()
            }()
            gameVC.multiplayer = self.multiplayer
            Navigation.main.pushViewController(gameVC, animated: true)
            Navigation.startLoading()
        }
    }
}

extension MultiplayerVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SessionData.shared.selectedPlayer = Poo(name: PooName.ApolloPoo)
        let peerID = players[indexPath.row]
        multiplayer.connect(peerID)
    }
}

extension MultiplayerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = players[indexPath.row].displayName
        cell.selectionStyle = .none
        return cell
    }
    
}
