//
//  ToiletViewController.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 07/11/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import SceneKit

class ToiletViewController: GameViewController {

    var toiletNode: SCNNode!
    /// Euler angles are activated
    var eulerYes = false

    // MARK:- PREPARATION AND INITIAL COMMON METHODS
    
    override func viewDidLoad() {
        basicSetup()
        super.viewDidLoad()
    }
    
    func basicSetup() {
        world = .toilet
        Values.yTot = 2.5
        Values.zTot = 4.0
        length = -400
    }
    
    override func setupScene() {
        super.setupScene()
        toiletNode = scene.rootNode.childNode(withName: "toilet", recursively: true)!
        toiletNode.position.z = length
        scene.physicsWorld.gravity = SCNVector3(0, -2, 0)
    }
    
    override func prepare() {
        super.prepare()
        let carpetNode = NodeCreator.createCarpet(zed: length)
        self.scene.rootNode.addChildNode(carpetNode)
        for node in NodeCreator.createBound(zed: abs(length)) {
            self.scene.rootNode.addChildNode(node)
        }
        self.addObstacle()
        self.scene.rootNode.addChildNode(NodeCreator.createFinish(zed: self.length))
        self.sceneView.prepare([scene, SCNScene(named: "art.scnassets/Nodes/ToiletPaper.scn")!, SCNScene(named: "art.scnassets/Nodes/pill.scn")!, scene.rootNode]) { (done) in
            self.newGame()
        }
    }
    
    override func newGame() {
        super.newGame()
        eulerYes = false
    }
    
    func addObstacle() {
        let safeEnd = abs(length) - 20
        let supersafeEnd = abs(length) - 40
        let safeStart = UInt32(abs(length) - 40)
        let supersafeStart = UInt32(abs(length) - 70)
        for index in 0...Int(abs(length)/3) {
            let random = Float(index) * 2.7
            let zedRand = safeEnd - random
            scene.rootNode.addChildNode(NodeCreator.createPaper(zed: ((0 - zedRand))))
        }
        for _ in 0...5 {
            let random = Float(arc4random_uniform(safeStart))
            let zedRand = safeEnd - random
            scene.rootNode.addChildNode(NodeCreator.createSponge(zed: (0 - zedRand)))
        }
        
        let randomPill = Float(arc4random_uniform(supersafeStart))
        let zedRandPill = supersafeEnd - randomPill
        scene.rootNode.addChildNode(NodeCreator.createPill(zed: 0 - zedRandPill))
        let random = Float(arc4random_uniform(supersafeStart))
        let zedRand = supersafeEnd - random
        scene.rootNode.addChildNode(NodeCreator.createTunnel(zed: 0 - zedRand))
    }
    
    // MARK:- BONUS ACTIVATION AND MOVING

    override func showBonus(bonus: Bonus, node: SCNNode) {
        super.showBonus(bonus: bonus, node: node)
        if bonus == .Sprint && node == ballNode {
            Values.zTot = 2.5
        }
    }
    
    override func stopShowBonus(bonus: Bonus, node: SCNNode) {
        super.stopShowBonus(bonus: bonus, node: node)
        Values.zTot = 4.0
    }
    
    
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard gameOver == false else { return }
        if eulerYes == true {
            if Values.zTot > 1 { Values.zTot -= 0.03 }
            if Values.yTot < 5 { Values.yTot += 0.01 }
            if selfieStickNode.eulerAngles.x > -Float.pi/3 { selfieStickNode.eulerAngles.x -= 0.01 }
        }
        super.renderer(renderer, updateAtTime: time)

        guard started == true else { return }
    }
    
    // MARK:- FINISH METHOD
    
    override func jump(node: SCNNode) {
        node.physicsBody?.clearAllForces()
        if node == ballNode {
            eulerYes = true
            node.physicsBody?.clearAllForces()
            scene.physicsWorld.gravity = SCNVector3(0, -0.5, 0)
            node.physicsBody?.applyForce(SCNVector3(0, 3.7, -0.12), asImpulse: true)
            node.physicsBody?.applyTorque(SCNVector4(0.5, 0.5, 0.5, 0.5), asImpulse: true)
            perform(#selector(checkFinish), with: nil, afterDelay: 4)
        } else {
            let byFinish = SCNVector3(0, 14, length + 8)
            let finish = SCNVector3(0, 4, length)
            node.runAction(SCNAction.move(to: byFinish, duration: 1)) {
                node.runAction(SCNAction.move(to: finish, duration: 1)) {
                    self.didFinish(node: node)
                }
            }
        }
    }
    
    override func handleFinish(ball: SCNNode) {
        guard ball.name != nil && ball.name != "" && ball.name != "C_Low" && ball.name != "carpet" else { return }
        super.handleFinish(ball: ball)
    }
    
    override func didFinish(node: SCNNode) {
        node.removeFromParentNode()
        super.didFinish(node: node)
    }
    
    override func addFinalAnimation() {
        guard let trail = SCNParticleSystem(named: "spluff", inDirectory: nil) else { return  }
        toiletNode.addParticleSystem(trail)
    }

}
