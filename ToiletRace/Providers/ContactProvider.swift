//
//  ContactManager.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 17/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import SceneKit


class Collider {
    static let poo: Int = 4
    static let bounds : Int = 8
    static let obstacle: Int = 16
    static let floor: Int = 32
}

protocol ContactProvider: StoreProvider {}

extension ContactProvider where Self: GameViewController {
    
    func contactStarted(_ world: SCNPhysicsWorld, _ contact: SCNPhysicsContact) {
        if started == false {
            detectObstacleCollision(contact: contact)
        }
        if contact.nodeA == pooNode || contact.nodeB == pooNode {
            let otherNode = contact.nodeA == pooNode ? contact.nodeB : contact.nodeA
            UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
            if otherNode.name != "finish" &&  otherNode.name != "carpet" && otherNode.name != "floor" {
                noWipe = false
            }
        }
        if contact.nodeB.name == "finish" {
            guard isValidFinish(contact.nodeA) else { return }
            handleFinish(contact.nodeA)
        } else if contact.nodeA.name == "finish" {
            guard isValidFinish(contact.nodeB) else { return }
            handleFinish(contact.nodeB)
        }
        if contact.nodeB.name == "carpet" {
            guard contact.nodeB.name != "floor" else { return }
            jump(node: contact.nodeA)
        } else if contact.nodeA.name == "carpet" {
            guard contact.nodeB.name != "floor" && contact.nodeB.name != "sponge" && contact.nodeB.name != "paper" else { return }
            jump(node: contact.nodeB)
        }
    }
    
    private func isValidFinish(_ node: SCNNode) -> Bool {
        let name = node.name
        return name != nil && name != "" && name != "C_Low" && name != "carpet"
    }
    
    // This method prevents that obstacles are placed onto each other on track creation
    private func detectObstacleCollision(contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeA.name == "bath" {
            if nodeB.name == "paper" || nodeB.name == "sponge" || nodeB.name == "pill" {
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "bath" {
            if nodeA.name == "paper" || nodeA.name == "sponge" || nodeA.name == "pill"  {
                nodeA.removeFromParentNode()
            }
        }
        if nodeA.name == "pill" {
            if nodeB.name == "paper" || nodeB.name == "sponge" {
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "pill" {
            if nodeA.name == "paper" || nodeA.name == "sponge" {
                nodeA.removeFromParentNode()
            }
        }
        if nodeA.name == "sponge" {
            if nodeB.name == "paper" {
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "sponge" {
            if nodeA.name == "paper" {
                nodeA.removeFromParentNode()
            }
        }
        if nodeA.name == "rat" {
            if nodeB.name == "trash" || nodeB.name == "rock" {
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "rat" {
            if nodeA.name == "trash" || nodeA.name == "rock" {
                nodeA.removeFromParentNode()
            }
        }
        if nodeA.name == "rock" {
            if nodeB.name == "trash" {
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "rock" {
            if nodeA.name == "trash" {
                nodeA.removeFromParentNode()
            }
        }
    }
    
    /// AI to detect if a collision is coming and to avoid it
    func blockAvoider() {
        for opponent in currentPlayers.filter({$0.id != getID()}) {
            guard !opponent.isMultiplayer else { return }
            let pos = opponent.node.presentation.position
            opponent.turn(direction: getBestDirection(pos: pos))
        }
    }
    
    /// Returns best direction possible for a node, based on it's position and colliders positions. Pretty complex logic to dive in but tested 🤷🏻‍♂️.
    private func getBestDirection(pos: SCNVector3) -> Direction {
        var rightList = [SCNHitTestResult]()
        var leftList = [SCNHitTestResult]()
        let straightList =
            scene.physicsWorld.rayTestWithSegment(from: pos, to: SCNVector3(pos.x, 0.5, pos.z - 5), options: nil) +
                scene.physicsWorld.rayTestWithSegment(from: pos, to: SCNVector3(pos.x + 0.3, 0.5, pos.z - 5), options: nil) +
                scene.physicsWorld.rayTestWithSegment(from: pos, to: SCNVector3(pos.x - 0.3, 0.5, pos.z - 5), options: nil)
        let isLimit = (pos.x > 6.5 || pos.x < -6.5)
        if straightList.count == 0 {
            return .straight
        }
        if isLimit {
            return pos.x > 6.5 ? .left : .right
        }
        let level: Int = {
            switch retrieveLevel() {
            case 0: return 5
            case 2: return 10
            default: return 7
            }
        }()
        for ind in 1...level {
            let x = 12/2 - Float(ind)/2
            let z = -Float(ind)/3
            let pointR = SCNVector3(pos.x + x, 0.5, pos.z + z)
            let pointL = SCNVector3(pos.x - x, 0.5, pos.z + z)
            rightList = rightList + scene.physicsWorld.rayTestWithSegment(from: pos, to: pointR, options: nil)
            leftList = leftList + scene.physicsWorld.rayTestWithSegment(from: pos, to: pointL, options: nil)
        }
        
        if leftList.count == rightList.count {
            if pos.x == 0 { return arc4random_uniform(2) == 1 ? .left : .right }
        }
        return leftList.count > rightList.count ? .right : .left
    }
}
