//
//  PipeViewController.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 07/11/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import SceneKit

class PipeViewController: GameViewController {

    var tubeNode: SCNNode!
    var finishNode: SCNNode!
    var ratNode: SCNNode!
    var rockTimer: Timer?
    
    override func viewDidLoad() {
        basicSetup()
        super.viewDidLoad()
    }
    
    func basicSetup() {
        world = .pipe
        Values.yTot = 2.0
        Values.zTot = 3.5
        length = -290
        controllerView.cellTextColor = UIColor.white
        controllerView.backgroundCellColor = UIColor.darkGray
    }
    
    override func setupScene() {
        super.setupScene()
        tubeNode = scene.rootNode.childNode(withName: "tube", recursively: true)!
        finishNode = scene.rootNode.childNode(withName: "finish", recursively: true)!
        tubeNode.physicsBody?.categoryBitMask = Collider.floor
        scene.physicsWorld.gravity = SCNVector3(0, -1, 0)
    }
    
    override func prepare() {
        super.prepare()
        sceneView.prepare([scene, SCNScene(named: "art.scnassets/Nodes/trash.scn")!, SCNScene(named: "art.scnassets/Nodes/rat.scn")!]) { (done) in
            self.newGame()
        }
        addObstacle()
        setFinish()
        addSmoke()
    }
    
    override func setupFloor() {
        super.setupFloor()
    }
    
    func addObstacle() {
        let safeLength = abs(length) - 20
        let safeStart = UInt32(abs(length) - 70)
        for _ in 0...Int(abs(length)/10) {
            let random = Float(arc4random_uniform(safeStart))
            let zedRand = safeLength - random
            scene.rootNode.addChildNode(NodeCreator.createTrash(zed: ((0 - zedRand))))
        }
        rockTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(addRock(_:)), userInfo: nil, repeats: true)
        ratNode = NodeCreator.createRat(zed: -40)
        scene.rootNode.addChildNode(ratNode)
    }
    
    override func start() {
        super.start()
        loadRat()
    }
    
    func loadRat() {
        let url = Bundle.main.url(forResource: "art.scnassets/animation", withExtension: "scnanim")
        let anim = SCNAnimation.init(contentsOf: url!)
        ratNode.addAnimation(anim, forKey: "move")
        let _ = Timer.scheduledTimer(timeInterval: 2.1, target: self, selector: #selector(self.moveRat), userInfo: nil, repeats: false)
    }
    
    @objc func moveRat() {
        let ratPos = ratNode.position
        let act = SCNAction.move(to: SCNVector3(ratPos.x, ratPos.y, ratPos.z + 20), duration: 2)
        ratNode.runAction(act) {
            let _ = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.moveRat), userInfo: nil, repeats: false)
        }
    }
    
    @objc func addRock(_ sender: Timer) {
        guard started == true else { return }
        let safeStart = UInt32(abs(length) - 40)
        let random = Float(arc4random_uniform(safeStart))
        for el in NodeCreator.createRock(zed: (0 - random)) {
            scene.rootNode.addChildNode(el)
        }
    }
    
    func setFinish() {
        finishNode.physicsBody = SCNPhysicsBody.kinematic()
        finishNode.physicsBody?.categoryBitMask = Collider.bounds
        finishNode.physicsBody?.collisionBitMask = Collider.obstacle
        finishNode.name = "finish"
    }
    
    func addSmoke() {
        let bonusTrail = SCNParticleSystem(named: "smoke", inDirectory: nil)
        tubeNode.addParticleSystem(bonusTrail!)
    }
    
    
    override func handleFinish(ball: SCNNode) {
        super.handleFinish(ball: ball)
        if ball == ballNode {
            rockTimer?.invalidate()
        }
    }
    
    
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        super.renderer(renderer, updateAtTime: time)
        if selfieStickNode.position.x > 4.1 {
            selfieStickNode.position.x = 4.1
        }
        if selfieStickNode.position.x < -4.1 {
            selfieStickNode.position.x = -4.1
        }
        guard started == true else { return }
        blockAvoider()
        slowSplash()
    }
    
    
    func slowSplash() {
        if ballNode.presentation.position.x > -0.01 && ballNode.presentation.position.x < 0.01 {
            ballNode.physicsBody?.applyForce(SCNVector3(0, 0, -0.02), asImpulse: true)
        }
    }
    
}
