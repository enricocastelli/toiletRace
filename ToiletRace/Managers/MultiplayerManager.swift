//
//  Multi.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 19/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation

import UIKit
import MultipeerConnectivity


protocol MultiplayerDelegate {
    func didReceivePosition(pos: PlayerPosition)
    func didReceivePooName(_ name: PooName)
}

protocol MultiplayerConnectionDelegate {
    func didFoundPeer(_ peer: MCPeerID)
    func didReceiveInvitation(peerID: MCPeerID, invitationHandler: @escaping (Bool) -> Void)
    func didDisconnect()
    func didConnect()
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
    var name: String
}

class MultiplayerManager: NSObject {
    
    private let SessionName = "poo"
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser : MCNearbyServiceAdvertiser!
    private var serviceBrowser : MCNearbyServiceBrowser!
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    var players : Array<MCPeerID> = []
    var delegate: MultiplayerDelegate?
    var connectionDelegate: MultiplayerConnectionDelegate?
    var connected = false
    
    init(delegate: MultiplayerDelegate?, connectionDelegate: MultiplayerConnectionDelegate?) {
        self.delegate = delegate
        self.connectionDelegate = connectionDelegate
        super.init()
        start()
    }
    
    func updateDelegate(delegate: MultiplayerDelegate?, connectionDelegate: MultiplayerConnectionDelegate?) {
        self.delegate = delegate
        self.connectionDelegate = connectionDelegate
    }
    
    func start() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: SessionName)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: SessionName)
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        self.players = []
    }
    
    func stop() {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        self.session.disconnect()
        self.players = []
    }
    
    //MARK:- TABLEVIEW STUFF
    
    func connect(_ peerID: MCPeerID) {
        serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    public func sendPosition(x: Float, y: Float, z: Float) {
        let params = ["xPosition": x.string(), "yPosition": y.string(), "zPosition": z.string()]
        sendData(params)
    }
    
    public func sendName(_ pooName: PooName) {
        let params = ["name": pooName.rawValue]
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
            let value = try JSONDecoder().decode(PlayerPosition.self, from: data)
            delegate?.didReceivePosition(pos: value)
            completion(true)
            return
        } catch {
        }
        do {
            let value = try JSONDecoder().decode(PlayerName.self, from: data)
            guard let pooName = PooName(rawValue: value.name) else { return }
            delegate?.didReceivePooName(pooName)
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

