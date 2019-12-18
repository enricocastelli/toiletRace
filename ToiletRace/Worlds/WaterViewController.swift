//
//  PipeViewController.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 07/11/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import SceneKit
import AudioToolbox

class WaterViewController: GameViewController {
    
    var fishNode: SCNNode!
    var finishNode: SCNNode!
    var fishTimer: Timer?
    
    override func viewDidLoad() {
        basicSetup()
        super.viewDidLoad()
        controllerView.cellTextColor = UIColor.white
        controllerView.backgroundCellColor = UIColor.darkGray
    }
    
    func basicSetup() {
        world = .water
        Values.yTot = 2
        Values.zTot = 4
        length = 200
        position = SCNVector3(0, 0, 0)
        shouldRotateCamera = false
    }
    
    override func setupScene() {
        super.setupScene()
        scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
//        finishNode = scene.rootNode.childNode(withName: "finish", recursively: true)!
    }
    
    override func setupFloor() {
        
    }
    
    override func prepare() {
        super.prepare()
        sceneView.prepare([scene, SCNScene(named: "art.scnassets/Nodes/fish.scn")!]) { (done) in
            self.newGame()
            self.addBubble()
            let _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.addBubble), userInfo: nil, repeats: true)
            let _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.moveY), userInfo: nil, repeats: true)
            self.addObstacles()
        }
    }
    
    @objc func addBubble() {
        let trail = SCNParticleSystem(named: "bubble", inDirectory: nil)
        self.pooNode.addParticleSystem(trail!)
    }
    
    
    @objc func moveY() {
        let randomY = -0.2 - Float(arc4random_uniform(10))/90
        self.pooNode.physicsBody?.applyForce(SCNVector3(0, randomY, 0), asImpulse: false)
        let randomTorque = 0.02 - Float(arc4random_uniform(10))/100
        let torque = SCNVector4(0, 0, randomTorque, randomTorque)
        pooNode.physicsBody?.applyTorque(torque, asImpulse: true)
    }
    
    func addObstacles() {
        fishTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(addFish), userInfo: nil, repeats: true)
    }
    
    @objc func addFish() {
        guard started == true && gameOver == false else { return }
        let random = Int(arc4random_uniform(UInt32(currentPlayers.count - 1)))
        let randPlayer = currentPlayers[random]
        for _ in 0...4 {
            let pos = randPlayer.node.presentation.position.z
            let random = 20.0 + Float(arc4random_uniform(40))
            let safeStart = pos - random
            let fishNode = NodeCreator.createFish(zed: safeStart)
            moveFish(fishNode: fishNode, node: randPlayer.node)
            scene.rootNode.addChildNode(fishNode)
        }
    }
    
    func moveFish(fishNode: SCNNode, node: SCNNode) {
        let fishPos = fishNode.presentation.position
        let randomX = 4 - Float(arc4random_uniform(8))
        let duration = 2
        let act = SCNAction.move(to: SCNVector3(fishPos.x + randomX, fishPos.y, node.presentation.position.z + 20), duration: TimeInterval(duration))
        fishNode.runAction(act) {
            let randomOut = randomX*2
            let actionOut = SCNAction.move(to: SCNVector3(fishPos.x, randomOut, node.presentation.position.z + 50), duration: 1)
            fishNode.runAction(actionOut) {
                fishNode.removeFromParentNode()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let loc = touch.location(in: self.view)
//        location = loc
//        guard gameOver == false && started == true else { return }
//        if loc.x > UIScreen.main.bounds.width/2 {
//            //right
//            let force = SCNVector3(Data.shared.selectedPlayer.turningForce()/4, 0, 0.01)
//            ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            let torque = SCNVector4(0, 0, -0.05, 0.05)
//            ballNode.physicsBody?.applyTorque(torque, asImpulse: true)
//            if shouldRotateCamera {
//                let rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: 0.05, duration: 0.4)
//                selfieStickNode.runAction(rotateAction) {
//                    self.selfieStickNode.runAction(rotateAction.reversed())
//                }
//            }
//        } else {
//            //left
//            let torque = SCNVector4(0, 0, 0.05, 0.05)
//            let force = SCNVector3(-Data.shared.selectedPlayer.turningForce()/4, 0, 0.01)
//            ballNode.physicsBody?.applyTorque(torque, asImpulse: true)
//            ballNode.physicsBody?.applyForce(force, asImpulse: true)
//            if shouldRotateCamera {
//                let rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: -0.05, duration: 0.3)
//                selfieStickNode.runAction(rotateAction) {
//                    self.selfieStickNode.runAction(rotateAction.reversed())
//                }
//            }
//        }
    }
    
    override func movePoops() {
        guard started == true else { return }
        for n in 0...currentPlayers.count - 1 {
            let ball = currentPlayers[n]
            ball.node.physicsBody?.applyForce(SCNVector3(0, 0, ball.velocity()/4), asImpulse: true)
        }
    }
    

}
