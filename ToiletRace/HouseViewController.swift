//
//  HouseViewController.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 08/11/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import SceneKit

class HouseViewController: GameViewController {
}

//    var shouldTurn = false
//    var angle: Direction = .Straight
//    var oldAngle: Direction = .Straight
//    var suggestedAngle: Direction = .Straight
//    var didTurn = false
//
//    override func viewDidLoad() {
//        basicSetup()
//        super.viewDidLoad()
//    }
//
//    func basicSetup() {
//        world = .house
//        length = -290
//        cellTextColor = UIColor.white
//        backgroundCellColor = UIColor.darkGray
//    }
//
//    override func setupScene() {
//        super.setupScene()
//        scene.physicsWorld.gravity = SCNVector3(0, -1, 0)
//    }
//
//    override func prepare() {
//        super.prepare()
//        sceneView.prepare([scene]) { (done) in
//            self.newGame()
//        }
//    }
//
//    override func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        super.physicsWorld(world, didBegin: contact)
//        detectTurn(contact: contact)
//    }
//
//    func detectTurn(contact: SCNPhysicsContact) {
//        if contact.nodeA.name == "turn" {
//            guard let dir = Direction(rawValue: Int(contact.nodeA.geometry?.name ?? "") ?? -1) else { return }
//            if contact.nodeB == ballNode {
//                suggestedAngle = dir
//                shouldTurn = true
//            } else {
//                turnOpponent(ball: contact.nodeB, direction: dir)
//            }
//        } else if contact.nodeB.name == "turn" {
//            guard let dir = Direction(rawValue: Int(contact.nodeB.geometry?.name ?? "") ?? -1) else { return }
//            if contact.nodeA == ballNode {
//                suggestedAngle = dir
//                shouldTurn = true
//            } else {
//                turnOpponent(ball: contact.nodeA, direction: dir)
//            }
//        }
//        if contact.nodeA.name == "normal" {
//            if contact.nodeB == ballNode {
//                didTurn = false
//                shouldTurn = false
//            } else {
//                normalOpponentBall(ball: contact.nodeB)
//            }
//        } else if contact.nodeB.name == "normal" {
//            if contact.nodeA == ballNode {
//                didTurn = false
//                shouldTurn = false
//            } else {
//                normalOpponentBall(ball: contact.nodeA)
//            }
//        }
//    }
//
//    func turnOpponent(ball: SCNNode, direction: Direction) {
//        guard ball.opacity == 1 else { return }
//        ball.opacity = 0.99
//        guard let index : Int = {
//            for ind in 0...currentPlayers.count - 1 {
//                let pl = currentPlayers[ind]
//                if pl.name.rawValue == ball.name {
//                    return ind
//                }
//            }
//            return nil
//            }() else { return }
//        currentPlayers[index].currentAngle = direction
//        switch direction {
//        case .Straight:
//            ball.physicsBody?.applyForce(SCNVector3(0, 0, -0.003), asImpulse: true)
//        case .Left:
//            ball.physicsBody?.applyForce(SCNVector3(-0.003, 0, 0), asImpulse: true)
//        case .Right:
//            ball.physicsBody?.applyForce(SCNVector3(0.003, 0, 0), asImpulse: true)
//        case .Back:
//            ball.physicsBody?.applyForce(SCNVector3(0, 0, 0.003), asImpulse: true)
//        }
//    }
//
//    func normalOpponentBall(ball: SCNNode) {
//        guard ball.opacity != 1 else { return }
//        ball.opacity = 1
//    }
//
//    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        guard gameOver == false else { return }
//        super.renderer(renderer, updateAtTime: time)
//        switch angle {
//        case .Right:
//            // z: 0 / x: -4 / euY: -90
//            if xTot > -4 { xTot -= 0.5 }
//            if oldAngle == .Straight {
//                if zTot > 0 { zTot -= 0.5}
//            } else {
//                if zTot > 0 { zTot += 0.5 }
//            }
//        case .Left:
//            // z: 0 / x: 4 / euY: 90
//            if xTot < 4 { xTot += 0.5 }
//            if oldAngle == .Back {
//                if zTot < 0 { zTot += 0.5 }
//            } else {
//                if zTot > 0 { zTot -= 0.5 }
//            }
//        case .Straight:
//            // z: 4 / x: 0 / euY: 0
//            if zTot < 4 { zTot += 0.5 }
//            if oldAngle == .Left {
//                if xTot > 0 { xTot -= 0.5 }
//            } else {
//                if xTot < 0 { xTot += 0.5 }
//            }
//        case .Back:
//            // z: -4 / x: 0 / euY: -+180
//            if zTot > -4 { zTot -= 0.5 }
//            if oldAngle == .Left {
//                if xTot > 0 { xTot -= 0.5 }
//            } else {
//                if xTot < 0 { xTot += 0.5 }
//            }
//        }
//    }
//
//    override func movePoops() {
//        guard started == true else { return }
//        for n in 0...currentPlayers.count - 1 {
//            let ball = currentPlayers[n]
//            let bonusOffset = calculateBonusOffset(ball: ball)
//            if ball.node!.presentation.position.z < length + 50 && ball.canUseBonus == true {
//                if ball.node == ballNode {
//                    ball.canUseBonus = false
//                    DispatchQueue.main.async {
//                        self.bonusButton?.removeFromSuperview()
//                    }
//                } else {
//                    ball.canUseBonus = false
//                }
//                currentPlayers[n] = ball
//            }
//            let angleTurn : Direction = {
//                if ball.name == Data.shared.selectedPlayer.name {
//                    return angle
//                } else {
//                    return ball.currentAngle
//                }
//            }()
//            switch angleTurn {
//            case .Straight:
//                ball.node?.physicsBody?.applyForce(SCNVector3(0, 0, ball.velocity() + bonusOffset), asImpulse: true)
//            case .Left:
//                ball.node?.physicsBody?.applyForce(SCNVector3(ball.velocity() + bonusOffset, 0, 0), asImpulse: true)
//            case .Right:
//                ball.node?.physicsBody?.applyForce(SCNVector3(-(ball.velocity() + bonusOffset), 0, 0), asImpulse: true)
//            case .Back:
//                ball.node?.physicsBody?.applyForce(SCNVector3(0, 0, -(ball.velocity() + bonusOffset)), asImpulse: true)
//            }
//        }
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let loc = touch.location(in: self.view)
//        location = loc
//        guard gameOver == false && started == true else { return }
//        if loc.x > UIScreen.main.bounds.width/2 {
//            //right
//            getNewDirection(right: true)
//            switch angle {
//            case .Straight:
//                let force = SCNVector3(Data.shared.selectedPlayer.turningForce(), 0, 0)
//                ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            case .Left:
//                let force = SCNVector3(0, 0,  -Data.shared.selectedPlayer.turningForce())
//                ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            case .Right:
//
//                let force = SCNVector3(0, 0, Data.shared.selectedPlayer.turningForce())
//                ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            case .Back:
//                let force = SCNVector3(0, 0, Data.shared.selectedPlayer.turningForce())
//                ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            }
//        } else {
//            //left
//            getNewDirection(right: false)
//            switch angle {
//            case .Straight:
//                let force = SCNVector3(-Data.shared.selectedPlayer.turningForce(), 0, 0)
//                ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            case .Left:
//                let force = SCNVector3(0, 0, Data.shared.selectedPlayer.turningForce())
//                ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            case .Right:
//                let force = SCNVector3(0, 0, -Data.shared.selectedPlayer.turningForce())
//                ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            case .Back:
//                let force = SCNVector3(-Data.shared.selectedPlayer.turningForce(), 0, 0)
//                ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            }
//        }
//    }
//
//    func getNewDirection(right: Bool) {
//        guard !didTurn && shouldTurn else { return }
//        if right {
//            switch angle {
//            case .Back:
//                self.angle = .Left
//                oldAngle = .Back
//            case .Left:
//                self.angle = .Straight
//                oldAngle = .Left
//            case .Straight:
//                self.angle = .Right
//                oldAngle = .Straight
//            case .Right:
//                self.angle = .Back
//                oldAngle = .Right
//            }
//        } else {
//            switch angle {
//            case .Back:
//                self.angle = .Right
//                oldAngle = .Back
//            case .Left:
//                self.angle = .Back
//                oldAngle = .Left
//            case .Straight:
//                self.angle = .Left
//                oldAngle = .Straight
//            case .Right:
//                self.angle = .Straight
//                oldAngle = .Right
//            }
//        }
//        guard angle == suggestedAngle else {
//            angle = oldAngle
//            return
//        }
//        animateCamera()
//        didTurn = true
//    }
//
//    func animateCamera() {
//        switch angle {
//        case .Right:
//                let spin = CABasicAnimation(keyPath: "eulerAngles.y")
//                spin.fromValue = selfieStickNode.eulerAngles.y
//                spin.toValue = -Float.pi/2
//                spin.duration = 0.3
//                selfieStickNode.addAnimation(spin, forKey: "spin around")
//                selfieStickNode.eulerAngles.y = -Float.pi/2
//        case .Left:
//            let spin = CABasicAnimation(keyPath: "eulerAngles.y")
//            spin.fromValue = selfieStickNode.eulerAngles.y
//            spin.toValue = Float.pi/2
//            spin.duration = 0.3
//            selfieStickNode.addAnimation(spin, forKey: "spin around")
//            selfieStickNode.eulerAngles.y = Float.pi/2
//        case .Straight:
//            let spin = CABasicAnimation(keyPath: "eulerAngles.y")
//            spin.fromValue = selfieStickNode.eulerAngles.y
//            spin.toValue = 0
//            spin.duration = 0.3
//            selfieStickNode.addAnimation(spin, forKey: "spin around")
//            selfieStickNode.eulerAngles.y = 0
//        case .Back:
//            let toValue : Float = {
//                if oldAngle == .Left {
//                    return Float.pi
//                } else {
//                    return -Float.pi
//                }
//            }()
//            let spin = CABasicAnimation(keyPath: "eulerAngles.y")
//            spin.fromValue = selfieStickNode.eulerAngles.y
//            spin.toValue = toValue
//            spin.duration = 0.3
//            selfieStickNode.addAnimation(spin, forKey: "spin around")
//            selfieStickNode.eulerAngles.y = Float.pi
//        }
//    }
//}
