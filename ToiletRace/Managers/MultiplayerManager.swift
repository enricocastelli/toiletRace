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


protocol MultiDelegate {
    func didReceivePosition(pos: PlayerPosition)
}

struct PlayerPosition: Codable {
    var xPos: Float
    var zPos: Float
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
    var delegate: MultiDelegate
    var connected = false
    
    init(delegate: MultiDelegate) {
        self.delegate = delegate
        super.init()
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
    
    //MARK:- TABLEVIEW STUFF
    
    func connect(_ peerID: MCPeerID) {
        serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func send(x: Float, z: Float) {
        if session.connectedPeers.count > 0 {
            let params = ["xPos": x, "zPos": z]
            do {
                let data = try JSONEncoder().encode(params)
                do {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
                catch let error {
                    Logger("\(error)💩 error Connecting 💩")
                }
            } catch {
                Logger("\(error)💩 error Connecting 💩")
            }
        }
    }
}

extension MultiplayerManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
}

extension MultiplayerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state.rawValue {
        case 0:
            Logger("💩NNNNNNNNNNN")
            connected = false
        case 1:
            Logger("💩CONNECTING")
            connected = false
        case 2:
            Logger("💩YYYYYYYYYYY")
            connected = true
        default:
            break
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let value = try JSONDecoder().decode(PlayerPosition.self, from: data)
            delegate.didReceivePosition(pos: value)
        } catch {
            Logger("💩 error decoding data")
        }
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
        connect(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }
}

