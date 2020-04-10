//
//  PooCreator.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 20/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import SceneKit

protocol PooNodeCreator: NodeCreator {}
    
extension PooNodeCreator {

    func createPoo() -> SCNNode {
        let selected = SessionData.shared.selectedPlayer
        let geo = SCNSphere(radius: selected.radius())
        geo.materials.insert(selected.createMaterial(), at: 0)
        geo.materials.removeLast()
        let pooNode = SCNNode(geometry: geo)
        pooNode.position = SCNVector3(0.0, 0.0, 0.0)
        pooNode.physicsBody = SCNPhysicsBody.dynamic()
        pooNode.physicsBody?.restitution = SessionData.shared.selectedPlayer.restitution()
        pooNode.physicsBody?.contactTestBitMask = Collider.poo | Collider.obstacle | Collider.bounds
        pooNode.physicsBody?.categoryBitMask = Collider.poo
        pooNode.name = SessionData.shared.selectedPlayer.name.rawValue
        return pooNode
    }
    
    func createOpponent(poo: Poo, index: Int) -> SCNNode {
        let geo = SCNSphere(radius: poo.radius())
        geo.materials.insert(poo.createMaterial(), at: 0)
        geo.materials.removeLast()
        let oppNode = SCNNode(geometry: geo)
        var pos = Double(-3 + index)
        if pos == 0 { pos = -3 }
        let actualPosition = SCNVector3(pos, 2, 0)
        oppNode.position = actualPosition
        oppNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        oppNode.physicsBody?.restitution = poo.restitution()
        oppNode.physicsBody?.contactTestBitMask = Collider.poo | Collider.bounds | Collider.obstacle
        oppNode.physicsBody?.categoryBitMask = Collider.poo
        return oppNode
    }
}
