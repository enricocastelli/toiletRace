//
//  Multi.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 19/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import FirebaseDatabase

import UIKit
import MultipeerConnectivity


protocol MultiplayerDelegate {
    func didReceivePosition(pos: PlayerPosition)
    func didReceivePooName(_ name: PooName, displayName: String)
    func didReceiveStart()
    func didReceiveEnd()
    func didReceivePlayers(_ players: [Player])
}

protocol MultiplayerConnectionDelegate {
    func didFoundPeer(_ peer: MCPeerID)
    func didReceiveInvitation(peerID: MCPeerID, invitationHandler: @escaping (Bool) -> Void)
    func didDisconnect()
    func didConnect()
}


class MultiplayerManager: NSObject {
    
    private let SessionName = "poo"
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser : MCNearbyServiceAdvertiser!
    private var serviceBrowser : MCNearbyServiceBrowser!
    
    var session : MCSession
    
    var delegate: MultiplayerDelegate?
    var connectionDelegate: MultiplayerConnectionDelegate?
    var connected = false
    // exact date when connection got established
    var connectionDate: Date?
    var firestore = true
    
    init(delegate: MultiplayerDelegate?, connectionDelegate: MultiplayerConnectionDelegate?) {
        self.delegate = delegate
        self.connectionDelegate = connectionDelegate
        session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        super.init()
        session.delegate = self
        start()
    }
    
    func updateDelegate(delegate: MultiplayerDelegate?, connectionDelegate: MultiplayerConnectionDelegate?) {
        self.delegate = delegate
        self.connectionDelegate = connectionDelegate
    }
    
    func start() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: SessionName)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: SessionName)
        stop()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func stop() {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        self.session.disconnect()
    }
    
    //MARK:- TABLEVIEW STUFF
    
    func connect(_ peerID: MCPeerID) {
        serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    public func sendPosition(x: Float, y: Float, z: Float) {
        if firestore {
            updateSelf(Player(id: "poo1", position: Position(x: x, y: y, z: z)))
        } else {
            let params = ["xPosition": x.string(), "yPosition": y.string(), "zPosition": z.string()]
            sendData(params)
        }
    }
    
    public func sendName(_ pooName: PooName) {
        let playerName = nameForDevice() ?? pooName.rawValue
        let params = ["pooName": pooName.rawValue, "displayName": playerName]
        SessionData.shared.selectedPlayer.displayName = playerName
        self.sendData(params)
    }
    
    public func sendReady() {
        let params = ["ready": "true"]
        self.sendData(params)
        if firestore {
            createGame()
            updateSelf(Player(id: testName(), position: Position(x: 0, y: 0, z: 50)))
            connectionDate = Date()
            delegate?.didReceivePooName(PooName.ApolloPoo, displayName: "ios")
            delegate?.didReceiveStart()
            addChallengeObserver("test") { (players) in
                self.delegate?.didReceivePlayers(players)
            }
        }
    }
    
    public func sendFinish() {
        let params = ["finish": "true"]
        self.sendData(params)
    }
    
    private func sendData(_ params: [String: String]) {
        if session.connectedPeers.count > 0 {
            do {
                let data = try JSONEncoder().encode(params)
                do {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
                catch let error {
                    Logger("\(error) error sending Data")
                }
            } catch {
                Logger("\(error) error sending Data")
            }
        }
    }
    
    /// transform device name into poo name
    func nameForDevice() -> String? {
        let device = UIDevice.current.name.lowercased()
        var name = ""
        if device.contains("iphone") {
            name = device.replacingOccurrences(of: "iphone", with: "poo")
            return name
        }
        return nil
    }
}

extension MultiplayerManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        connectionDelegate?.didReceiveInvitation(peerID: peerID, invitationHandler: { (accepted) in
            invitationHandler(accepted, self.session)
        })
    }
}

extension MultiplayerManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state.rawValue {
        case 0:
            Logger("Players Disconnected 🛑")
            connected = false
            connectionDelegate?.didDisconnect()
        case 1:
            Logger("Connecting...🔶")
            connected = false
        case 2:
            Logger("Players Connected ✅")
            connected = true
            connectionDelegate?.didConnect()
            self.connectionDate = Date()
        default:
            break
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        processData(data: data) { (success) in
            if !success {
               Logger("Error decoding data received.")
            }
        }
    }
    
    func processData(data: Data, completion: @escaping(Bool) -> ()) {
        do {
            let value = try JSONDecoder().decode(PlayerName.self, from: data)
            guard let pooName = PooName(rawValue: value.pooName) else { return }
            delegate?.didReceivePooName(pooName, displayName: value.displayName)
            completion(true)
            return
        } catch {
        }
        do {
            let _ = try JSONDecoder().decode(PlayerReady.self, from: data)
            delegate?.didReceiveStart()
            completion(true)
            return
        } catch {
        }
        do {
            let _ = try JSONDecoder().decode(PlayerFinish.self, from: data)
            delegate?.didReceiveEnd()
            completion(true)
            return
        } catch {
        }
        do {
            let value = try JSONDecoder().decode(PlayerPosition.self, from: data)
            delegate?.didReceivePosition(pos: value)
            completion(true)
            return
        } catch {
        }
        completion(false)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension MultiplayerManager: MCNearbyServiceBrowserDelegate {
  
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        Logger("Found peer \(peerID)")
        connectionDelegate?.didFoundPeer(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }
}

extension MultiplayerManager {
    
    private func game() -> DatabaseReference {
        return Database.database().reference().child("games")
    }
    
    func createGame() {
    }
    
    
    func updateSelf(_ player: Player) {
        guard let data = player.toData() else { return }
        let childUpdates = ["test/\(testName())": data]
        game().updateChildValues(childUpdates)
    }
    
    func addChallengeObserver(_ id: String, callback: @escaping([Player]) -> ()) {
        game().observe(DataEventType.childChanged) { (snapshot) in
            callback(snapshot.toPlayers())
        }
    }
}

struct Player {
    
    let id: String
    let position: Position
    
    func toData() -> [String: Any]? {
        return ["id": id, "position": ["xPos": position.x,
                                       "yPos": position.y,
                                       "zPos": position.z]]
        
    }
}

struct Position: Codable {
    var x: Float
    var y: Float
    var z: Float
}

struct PlayerPosition: Codable {
    var xPos: Float { get { return Float(xPosition) ?? 0 }}
    var yPos: Float { get { return Float(yPosition) ?? 0 }}
    var zPos: Float { get { return Float(zPosition) ?? 0 }}
    private var xPosition: String
    private var zPosition: String
    private var yPosition: String
}

struct PlayerName: Codable {
    var pooName: String
    var displayName: String
}

struct PlayerReady: Codable {
    private var ready: String
    var isReady: Bool { get { return ready == "true" }}
}

struct PlayerFinish: Codable {
    private var finish: String
    var didFinish: Bool { get { return finish == "true" }}
}

extension Dictionary where Key == String, Value == Any {
    
    func toPlayer() -> Player? {
        guard let id = self["id"] as? String, let position = self["position"] as? [String: Float], let xPos = position["xPos"], let yPos = position["yPos"], let zPos = position["zPos"] else { return nil }
        return Player(id: id, position: Position(x: xPos, y: yPos, z: zPos))
    }
    
}

extension DataSnapshot {
    
    func toPlayers() -> [Player] {
        var arr = [Player]()
        guard let values = value as? Dictionary<String, Any> else { return [] }
        for case let element as [String: Any] in values.values {
            if let player = element.toPlayer() {
                arr.append(player)
            }
        }
        return arr
    }
}
