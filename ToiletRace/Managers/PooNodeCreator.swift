//
//  PooCreator.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 20/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import SceneKit

class PooNodeCreator {
    
    static func createPoo(postion: SCNVector3?) -> SCNNode {
        let selected = SessionData.shared.selectedPlayer
        let geo = SCNSphere(radius: selected.radius())
        geo.materials.insert(selected.createMaterial(), at: 0)
        geo.materials.removeLast()
        let pooNode = SCNNode(geometry: geo)
        pooNode.position = postion ?? SCNVector3(0.0, 0.0, 0.0)
        pooNode.physicsBody = SCNPhysicsBody.dynamic()
        pooNode.physicsBody?.restitution = SessionData.shared.selectedPlayer.restitution()
        pooNode.physicsBody?.contactTestBitMask = Collider.poo | Collider.obstacle | Collider.bounds
        pooNode.physicsBody?.categoryBitMask = Collider.poo
        pooNode.name = SessionData.shared.selectedPlayer.name.rawValue
        return pooNode
    }
    
    static func createOpponent(index: Int, postion: SCNVector3?) -> SCNNode {
        let selected = players[index]
        let geo = SCNSphere(radius: selected.radius())
        geo.materials.insert(selected.createMaterial(), at: 0)
        geo.materials.removeLast()
        let oppNode = SCNNode(geometry: geo)
        var pos = Double(-3 + index)
        if pos == 0 { pos = -3 }
        let actualPosition : SCNVector3 = {
            if postion == nil {
                return SCNVector3(pos, 2, 0)
            } else {
                return SCNVector3(Float(pos), postion!.y, postion!.z)
            }
        }()
        oppNode.position = actualPosition
        oppNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        oppNode.physicsBody?.restitution = players[index].restitution()
        oppNode.physicsBody?.contactTestBitMask = Collider.poo | Collider.bounds | Collider.obstacle
        oppNode.physicsBody?.categoryBitMask = Collider.poo
        return oppNode
    }
    
    static func createVSOpponent(name: PooName, position: SCNVector3) -> SCNNode {
        let selected = Poo(name: name)
        let geo = SCNSphere(radius: selected.radius())
        geo.materials.insert(selected.createMaterial(), at: 0)
        geo.materials.removeLast()
        let oppNode = SCNNode(geometry: geo)
        oppNode.position = position
        return oppNode
    }
    
    static func createCustomizedBall(postion: SCNVector3?, item: BolusItem) -> SCNNode {
        let geo = SCNSphere(radius: item.radius)
        geo.materials.insert(materialFromItem(item), at: 0)
        geo.materials.removeLast()
        let pooNode = SCNNode(geometry: geo)
        pooNode.position = postion ?? SCNVector3(0.0, 0.0, 0.0)
        pooNode.physicsBody = SCNPhysicsBody.dynamic()
        pooNode.physicsBody?.restitution = item.restitution
        pooNode.physicsBody?.contactTestBitMask = Collider.poo | Collider.obstacle | Collider.bounds
        pooNode.physicsBody?.categoryBitMask = Collider.poo
        pooNode.physicsBody?.mass = item.mass
        pooNode.name = SessionData.shared.selectedPlayer.name.rawValue
        return pooNode
    }
    
    private static func materialFromItem(_ item: BolusItem) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor.init(red: CGFloat(item.colorR), green: CGFloat(item.colorG), blue: CGFloat(item.colorB), alpha: 1)
        material.diffuse.intensity = 0.7
        material.normal.contents = UIImage(named: "puffNormal")
        material.specular.contents = UIImage(named: "puffSpec")
        material.roughness.contents = 0.8
        material.displacement.contents = UIImage(named: "raisHei")
        material.displacement.intensity = item.displacement
        return material
    }
}
