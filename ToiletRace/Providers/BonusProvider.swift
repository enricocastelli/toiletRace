//
//  BonusProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation
import SceneKit

protocol BonusProvider {}

extension BonusProvider where Self: GameViewController {
    
    func showBonus(bonus: Bonus, node: SCNNode) {
        if let bonusTrail = SCNParticleSystem(named: "smoke", inDirectory: nil) {
            bonusTrail.loops = true
            node.addParticleSystem(bonusTrail)
        }
        switch bonus {
        case .NoBonus:
            break
        case .Sprint:
            SessionData.shared.selectedPlayer.bonusEnabled = true
            break
        case .Slower:
            slowerActivated = true
            break
        case .Ghost:
            node.geometry?.materials.first?.transparent.contents = UIColor.white.withAlphaComponent(0.2)
            node.physicsBody?.collisionBitMask = Collider.floor | Collider.bounds
            break
        case .Teleport:
            node.runAction(SCNAction.move(to: SCNVector3(pooNode.presentation.position.x, pooNode.presentation.position.y, pooNode.presentation.position.z - 15), duration: 0.05))
            break
        case .MiniPoo:
            let geo = SCNSphere(radius: 0.2)
            geo.materials.first?.diffuse.contents = UIColor.brown
            let lserN = SCNNode(geometry: geo)
            lserN.position = node.presentation.position
            lserN.position.z = node.presentation.position.z + 1
            lserN.physicsBody = SCNPhysicsBody.static()
            scene.rootNode.addChildNode(lserN)
            break
        case .Almighty:
            node.geometry?.materials.first?.transparent.contents = UIColor.white.withAlphaComponent(0.2)
            node.physicsBody?.collisionBitMask = Collider.floor | Collider.bounds
            slowerActivated = true
            break
        }
        if bonus == .Sprint && node == pooNode {
            Values.zTot = 2.5
        }
    }
    
    /// stop the displaying of a bonus behaviour for a specific node
    func stopShowBonus(bonus: Bonus, node: SCNNode) {
        node.removeAllParticleSystems()
        node.opacity = 1
        switch bonus {
        case .NoBonus:
            break
        case .Sprint:
            SessionData.shared.selectedPlayer.bonusEnabled = false
            break
        case .Slower:
            slowerActivated = false
            break
        case .Ghost:
            node.geometry?.materials.first?.transparent.contents = UIColor.white.withAlphaComponent(1)
            node.physicsBody?.collisionBitMask = 0xFFFFFFFF
            break
        case .Teleport:
            break
        case .MiniPoo:
            break
        case .Almighty:
            slowerActivated = false
            node.geometry?.materials.first?.transparent.contents = UIColor.white.withAlphaComponent(1)
            node.physicsBody?.collisionBitMask = 0xFFFFFFFF
            break
        }
        Values.zTot = 4.0
    }
    
    /// if getting too close to finish line, bonus should be disabled for opponents and removed for user
    func checkIfBonusShouldDisabled(_ poo: Poo, _ node: SCNNode, _ index: Int) {
        if node.presentation.position.z < length + 50 && poo.canUseBonus == true {
            if node == pooNode {
                poo.canUseBonus = false
                DispatchQueue.main.async {
                    self.controllerView.removeBonus()
                }
            } else {
                poo.canUseBonus = false
            }
            // resave the poo so that cannot use bonus
            currentPlayers[index] = poo
        }
    }
    
    /// calculate if bonus are on for a poo and how much offset should be applied to it's speed
    func calculateBonusOffset(_ poo: Poo) -> Float {
        let offset : Float  = {
            if slowerActivated && poo.bonus() != .Slower && poo.bonus() != .Almighty {
                return 0.015
            } else { return 0 }
        }()
        guard poo.bonusEnabled else { return offset }
        if let bonus = poo.bonus() {
            if bonus == .Sprint {
                if poo.bonusEnabled {
                    return -0.2 + offset
                }
            }
        }
        return offset
    }
    
    /// activate bonus opponent (if there's any)
    func activateOpponentBonus(poo: Poo) {
        guard let bonus = poo.bonus() else { return }
        // check if it's really opponent and if can use bonus at the moment
        guard poo.node != pooNode, poo.canUseBonus == true && poo.bonusEnabled == false else { return }
        poo.bonusEnabled = true
        let _ = Timer.scheduledTimer(withTimeInterval: bonus.duration(), repeats: false) { _ in
            self.stopOpponentBonus(poo)
        }
        showBonus(bonus: bonus, node: poo.node)
    }
    
    /// stop opponent's bonus when expired, receives the index of bonus player in the timer user info
    func stopOpponentBonus(_ poo: Poo) {
        guard let bonus = poo.bonus() else { return }
        poo.bonusEnabled = false
        poo.canUseBonus = false
        currentPlayers.replace(poo)
        stopShowBonus(bonus: bonus, node: poo.node)
        let _ = Timer.scheduledTimer(withTimeInterval: bonus.rechargeDuration()/2, repeats: false) { (_) in
            self.rechargeOpponentBonus(poo)
        }
    }
    
    /// recharge the bonus so cannot use consecutively
    func rechargeOpponentBonus(_ poo: Poo)  {
        poo.canUseBonus = true
        currentPlayers.replace(poo)
    }
}
