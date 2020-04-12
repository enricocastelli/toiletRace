//
//  ShowRoomVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 11/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit
import SceneKit

class ShowroomVC: UIViewController, StoreProvider, PooNodeCreator {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var barView: BarView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var speedProgress: UIProgressView!
    @IBOutlet weak var strengthLabel: UILabel!
    @IBOutlet weak var strengthProgress: UIProgressView!
    @IBOutlet weak var driveLabel: UILabel!
    @IBOutlet weak var driveProgress: UIProgressView!
    @IBOutlet weak var bonusView: RoundedView!
    @IBOutlet weak var bonusImageView: UIImageView!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet var fallingObjects: [UIView]!
    
    var nodes: [SCNNode] = []
    var cameraNode: SCNNode!
    
    var selectedItem = 0 {
        didSet {
            updateUI()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setScene()
        setBarView()
        initialSetup()
        addLight()
        addBalls()
        addSwipe()
        prepare {
            self.selectedItem = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigation.isSwipeBackEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigation.isSwipeBackEnabled = true
    }
    
    private func setScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 2)
        sceneView.scene!.rootNode.addChildNode(cameraNode)
    }
    
    private func addSwipe() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    private func setBarView(){
        barView.onLeftTap = backTapped
        barView.rightImage = nil
        barView.lineHidden = false
    }
    
    private func initialSetup() {
        speedLabel.text = "SPEED"
        strengthLabel.text = "STRENGTH"
        driveLabel.text = "DRIVEABILITY"
        bonusLabel.text = "NO BONUS"
        bonusView.layer.borderColor = UIColor(hex: "005CFF").cgColor
        bonusView.layer.borderWidth = 1.5
        bonusView.isHidden = true
    }
    
    func prepare(completion: @escaping () -> ()) {
        sceneView.prepare([sceneView.scene as Any]) { (done) in
           completion()
        }
    }
    
    func addBalls() {
        for poo in Poo.players {
            let index = Poo.players.firstIndex {$0.name == poo.name}!
            let pooNode = createOpponent(poo: poo, index: index)
            pooNode.scale = SCNVector3(3, 3, 3)
            pooNode.position = SCNVector3(index*10, 0, -2)
            pooNode.physicsBody?.isAffectedByGravity = false
            sceneView.scene!.rootNode.addChildNode(pooNode)
            pooNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
            pooNode.name = poo.name.rawValue
            nodes.append(pooNode)
        }
//        if shouldShowMighty {
//            shouldShowMighty = false
//            Poo.players.append(Poo(name: PooName.MightyPoop))
//            let index = Poo.players.count - 1
//            let pooNode = PooNodeCreator.createOpponent(index: index, postion: nil)
//            pooNode.position = SCNVector3(index*10, 0, -2)
//            pooNode.physicsBody?.isAffectedByGravity = false
//            sceneView.scene!.rootNode.addChildNode(pooNode)
//            pooNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
//            pooNode.name = Poo.players[index].name.rawValue
//            nodes.append(pooNode)
//        }
    }
    
    func addLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light?.intensity = 100
        lightNode.position = SCNVector3(x: 0, y: 4, z: 4)
        cameraNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        ambientLightNode.light?.intensity = 1000
        ambientLightNode.position = SCNVector3(x: 0, y: 4, z: 4)
        cameraNode.addChildNode(ambientLightNode)
    }
    
    func updateUI() {
        let poo = Poo.players[selectedItem]
        nameLabel.text = poo.name.rawValue
        UIView.animate(withDuration: 0.5) {
            self.speedProgress.setProgress(poo.speed(), animated: true)
            self.strengthProgress.setProgress(poo.strength(), animated: true)
            self.driveProgress.setProgress(poo.driveability(), animated: true)
        }
        if let bonus = poo.bonus() {
            bonusView.isHidden = bonus == .NoBonus
            bonusImageView.changeImage(bonus.image())
            bonusLabel.text = bonus.description
        }
        if !isPooUnlocked(poo) {
            selectButton.imageView?.isHidden = false
            selectButton.backgroundColor = UIColor.lightGray
            nameLabel.textColor = UIColor.lightGray
            selectButton.isEnabled = false
        } else {
            selectButton.imageView?.isHidden = true
            selectButton.backgroundColor = UIColor(hex: "6F9C7A")
            nameLabel.textColor = UIColor(hex: "303030")
            selectButton.isEnabled = true
        }
    }
    
    func goToRace(players: [Poo]) {
        DispatchQueue.main.async {
            let gameVC = GameViewController(players: players)
            self.navigation.goTo(gameVC)
            self.navigation.startLoading()
        }
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            rightTap(selectButton)
        } else if sender.direction == .right {
            leftTap(selectButton)
        }
    }

    @IBAction func rightTap(_ sender: UIButton) {
        guard selectedItem < Poo.players.count - 1 else { return }
        cameraNode.runAction(SCNAction.move(by: SCNVector3(10, 0, 0), duration: 0.5))
        selectedItem += 1
    }
    
    @IBAction func leftTap(_ sender: UIButton) {
        guard selectedItem > 0 else { return }
        cameraNode.runAction(SCNAction.move(by: SCNVector3(-10, 0, 0), duration: 0.5))
        selectedItem -= 1
    }
    
    func backTapped() {
        navigation.pop()
    }
    
    @IBAction func selectTapped(_ sender: UIButton) {
        view.isUserInteractionEnabled = false
        var delay = 0.0
        for object in fallingObjects.shuffled() {
            UIView.animate(withDuration: 0.3, delay: delay, options: [.curveEaseInOut], animations: {
                object.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            }) { (_) in }
            delay += 0.08
        }
        UIView.animate(withDuration: 1) {
            self.nameLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
        guard let trail = SCNParticleSystem(named: "smoke", inDirectory: nil) else {
            view.isUserInteractionEnabled = true
            return }
        nodes[selectedItem].addParticleSystem(trail)
        SessionData.shared.selectedPlayer = Poo(name: PooName(index: selectedItem), id: getID())
        var players = Poo.players
        players[selectedItem] = SessionData.shared.selectedPlayer
        let action = SCNAction.move(to: SCNVector3(Float(selectedItem*10), 0, -1), duration: 1.5)
        nodes[selectedItem].runAction(action) {
            self.goToRace(players: players)
        }
    }
    

    
}
