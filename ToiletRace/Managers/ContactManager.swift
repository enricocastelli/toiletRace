//
//  ContactManager.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 17/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import SceneKit

class ContactManager: NSObject, SCNPhysicsContactDelegate {
    
    var gameVC: GameViewController
    
    init(gameVC: GameViewController) {
        self.gameVC = gameVC
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if gameVC.started == false {
            detectObstacleCollision(contact: contact)
        }
        if contact.nodeB.name == "finish" {
            gameVC.handleFinish(ball: contact.nodeA)
        } else if contact.nodeA.name == "finish" {
            gameVC.handleFinish(ball: contact.nodeB)
        }
        if contact.nodeB.name == "carpet" {
            guard contact.nodeB.name != "floor" else { return }
            gameVC.jump(node: contact.nodeA)
        } else if contact.nodeA.name == "carpet" {
            guard contact.nodeB.name != "floor" && contact.nodeB.name != "sponge" && contact.nodeB.name != "paper" else { return }
            gameVC.jump(node: contact.nodeB)
        }
    }
    
    func detectObstacleCollision(contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeA.name == "bath" {
            if nodeB.name == "paper" || nodeB.name == "sponge" || nodeB.name == "pill" {
                Logger(ms: "removing \(nodeB.name!)")
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "bath" {
            if nodeA.name == "paper" || nodeA.name == "sponge" || nodeA.name == "pill"  {
                Logger(ms: "removing \(nodeA.name!)")
                nodeA.removeFromParentNode()
            }
        }
        if nodeA.name == "pill" {
            if nodeB.name == "paper" || nodeB.name == "sponge" {
                Logger(ms: "removing \(nodeB.name!)")
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "pill" {
            if nodeA.name == "paper" || nodeA.name == "sponge" {
                Logger(ms: "removing \(nodeA.name!)")
                nodeA.removeFromParentNode()
            }
        }
        if nodeA.name == "sponge" {
            if nodeB.name == "paper" {
                Logger(ms: "removing \(nodeB.name!)")
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "sponge" {
            if nodeA.name == "paper" {
                Logger(ms: "removing \(nodeA.name!)")
                nodeA.removeFromParentNode()
            }
        }
        if nodeA.name == "rat" {
            if nodeB.name == "trash" || nodeB.name == "rock" {
                Logger(ms: "removing \(nodeB.name!)")
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "rat" {
            if nodeA.name == "trash" || nodeA.name == "rock" {
                Logger(ms: "removing \(nodeA.name!)")
                nodeA.removeFromParentNode()
            }
        }
        if nodeA.name == "rock" {
            if nodeB.name == "trash" {
                Logger(ms: "removing \(nodeB.name!)")
                nodeB.removeFromParentNode()
            }
        } else if nodeB.name == "rock" {
            if nodeA.name == "trash" {
                Logger(ms: "removing \(nodeA.name!)")
                nodeA.removeFromParentNode()
            }
        }
    }
}
