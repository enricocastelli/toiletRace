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

class FallingViewController: GameViewController {
    
    let maxForce : Float = 6.66666666666666

    var finishNode: SCNNode!
    var waterNode: SCNNode!
    var birdArray = [SCNNode]()
    var fadeLayer: CAGradientLayer!
    var isFalling = false
    var speed : Float = 0.0
    var tiltValue : Float = 2
    
    override func viewDidLoad() {
        basicSetup()
        super.viewDidLoad()
    }
    
    func basicSetup() {
        world = .falling
        yTot = 4
        zTot = 0
        length = 500
        cellTextColor = UIColor.white
        backgroundCellColor = UIColor.darkGray
        position = SCNVector3(0, 500, 0)
        shouldRotateCamera = false
    }
    
    override func setupScene() {
        super.setupScene()
        scene.physicsWorld.gravity = SCNVector3(0, -0.8, 0)
        finishNode = scene.rootNode.childNode(withName: "finish", recursively: true)!
        waterNode = scene.rootNode.childNode(withName: "secondFloor", recursively: true)!
        addClouds()
        addImpediments()
        fadeLayer = CAGradientLayer(layer: view.layer)
        fadeLayer.opacity = 0.4
        fadeLayer.frame = view.bounds
        fadeLayer.type = CAGradientLayerType.radial
        fadeLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.black.cgColor]
        fadeLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        fadeLayer.endPoint = CGPoint(x: 1, y: 1)
        fadeLayer.locations = [0.0, 1]
        view.layer.addSublayer(fadeLayer)
    }
    
    func addImpediments() {
        for _ in 0...10 {
            let high = 40 + arc4random_uniform(UInt32(length - 40))
            let rand = arc4random_uniform(30)
            let bird = (NodeCreator.createBird(y: Float(high), zed: Float(rand)))
            moveBird(bird: bird, high: Float(high))
            birdArray.append(bird)
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
    
    override func startOppTimer() {
        
    }
    
    func moveBird(bird: SCNNode, high: Float) {
        let act = SCNAction.move(to: SCNVector3(0, bird.position.y, -20), duration: TimeInterval(10*(high/100)))
        bird.runAction(act)
    }
    
    override func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        super.physicsWorld(world, didBegin: contact)
    }
            
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        super.renderer(renderer, updateAtTime: time)
        selfieStickNode.eulerAngles.y += 0.005
        for bird in birdArray {
            bird.eulerAngles.y += 0.01
        }
        tiltCamera()
    }
    
    override func movePoops() {
        guard started == true else { return }
        for n in 0...currentPlayers.count - 1 {
            let ball = currentPlayers[n]
            if ball.node == ballNode {
                let actualSpeed = ((speed*0.05)/100)/2
                ballNode.physicsBody?.applyForce(SCNVector3(0, -actualSpeed, 0), asImpulse: true)
            } else {
                ball.node.physicsBody?.applyForce(SCNVector3(0, ball.velocity()/4, 0), asImpulse: true)
            }
        }
    }
    
    func tiltCamera() {
        let randX = Float(arc4random_uniform(UInt32(tiltValue*10)))/100
        let randY = Float(arc4random_uniform(UInt32(tiltValue*10)))/100
        let act = SCNAction.move(by: SCNVector3(randX, 0, randY), duration: 0.2)
        selfieStickNode.runAction(act)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touch: touches.first)
        }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touch: touches.first)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touch: touches.first)
    }
    
    func handleTouch(touch: UITouch?) {
        guard let touch = touch else { return }
        speed = Float(touch.force*100)/maxForce
        let color = createColorBasedOnSpeed()
        if speed > 99 {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            speed = 0
            ballNode.removeAllParticleSystems()
            view.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.view.isUserInteractionEnabled = true
            })
        } else if speed > 80 {
            if ballNode.particleSystems?.count == 0 {
                let bonusTrail = SCNParticleSystem(named: "smoke", inDirectory: nil)
                bonusTrail?.particleColor = UIColor.white
                ballNode.addParticleSystem(bonusTrail!)
            }
            ballNode.physicsBody?.collisionBitMask = Collider.ball
        } else {
            ballNode.removeAllParticleSystems()
            ballNode.physicsBody?.collisionBitMask = 0xFFFFFFFF
        }
        visualAdjustments()
        fadeLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, color.cgColor]
    }
    
    private func createColorBasedOnSpeed() -> UIColor {
        let correctSpeed = speed/100
        let hue = ((1 - correctSpeed)/3) + 0.05
        let satur = correctSpeed/1.2
        return UIColor(hue: CGFloat(hue), saturation: CGFloat(satur), brightness: 1, alpha: 1)
    }
    
    private func visualAdjustments() {
        tiltValue = speed/30
        yTot = 3 + (speed/20)
    }
}
