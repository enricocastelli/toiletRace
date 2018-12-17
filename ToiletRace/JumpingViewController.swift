//
//  JumpingViewController.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 12/11/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import SceneKit

class JumpingViewController: GameViewController {
    
    var finishNode: SCNNode!
    var waterNode: SCNNode!
    var isFalling = false
    
    override func viewDidLoad() {
        basicSetup()
        super.viewDidLoad()
    }
    
    func basicSetup() {
        world = .falling
        yTot = 6
        zTot = 4
        length = 120
        cellTextColor = UIColor.white
        backgroundCellColor = UIColor.darkGray
        position = SCNVector3(0, 120, 0)
        shouldRotateCamera = false
    }
    
    override func setupScene() {
        super.setupScene()
        scene.physicsWorld.gravity = SCNVector3(0, -0.3, 0)
        finishNode = scene.rootNode.childNode(withName: "finish", recursively: true)!
        waterNode = scene.rootNode.childNode(withName: "secondFloor", recursively: true)!
        addClouds()
        addImpediments()
    }
    
    func addImpediments() {
        let high = length - 70
        var start : Float = 30
        for index in 0...20 {
            let bird = (NodeCreator.createBird(y: high, zed: Float(-index)*start))
            start += 5
            //            moveBird(bird: bird)
            scene.rootNode.addChildNode(bird)
        }
    }
    
    override func prepare() {
        super.prepare()
        sceneView.prepare([scene]) { (done) in
            self.newGame()
        }
        setFinish()
        moveWater()
    }
    
    func setFinish() {
        finishNode.physicsBody = SCNPhysicsBody.kinematic()
        finishNode.physicsBody?.categoryBitMask = Collider.bounds
        finishNode.physicsBody?.collisionBitMask = Collider.impediment
        finishNode.name = "finish"
    }
    
    func moveWater() {
        let act = SCNAction.move(by: SCNVector3(100, 0, 100), duration: 15)
        waterNode.runAction(act)
    }
    
    func addClouds() {
        for _ in 0...14 {
            let rand = 40 + arc4random_uniform(UInt32(length))
            scene.rootNode.addChildNode(NodeCreator.createCloud(zed: Float(rand)))
        }
    }
    
    override func start() {
        super.start()
    }
    
    func moveBird(bird: SCNNode) {
        let act = SCNAction.move(to: SCNVector3(0, 0, 0), duration: 20)
        bird.runAction(act)
    }
    
    override func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        super.physicsWorld(world, didBegin: contact)
    }
    
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        super.renderer(renderer, updateAtTime: time)
        if isFalling {
            tiltCamera()
        }
    }
    
    func tiltCamera() {
        let randX = Float(arc4random_uniform(1))/10
        let randY = Float(arc4random_uniform(2))/10
        let act = SCNAction.move(by: SCNVector3(randX, 0, randY), duration: 0.2)
        selfieStickNode.runAction(act)
    }
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        super.touchesBegan(touches, with: event)
    //
    //    }
}
