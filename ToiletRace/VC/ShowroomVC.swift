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
    
    var isMultiplayer: Bool
    var nodes: [SCNNode] = []
    var cameraNode: SCNNode!
    
    var selectedItem = 0 {
        didSet {
            updateUI()
        }
    }
    
    init(_ isMultiplayer: Bool) {
        self.isMultiplayer = isMultiplayer
        super.init(nibName: String(describing: ShowroomVC.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = " "
        selectButton.isHidden = true
        setBarView()
        initialSetup()
        sceneView.alpha = 0
        DispatchQueue.global(qos: .background).async {
            self.setScene()
            self.addLight()
            self.addBalls()
            self.prepare {
                self.selectedItem = 0
                self.navigation.stopLoading()
                UIView.animate(withDuration: 0.3) {
                    self.sceneView.alpha = 1
                }
            }
        }
        addSwipe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigation.isSwipeBackEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigation.isSwipeBackEnabled = true
        backToDefault()
    }
    
    private func setScene() {
        let scene = SCNScene()
        scene.background.contents = UIImage.tiles
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
        barView.lineHidden = true
    }
    
    private func initialSetup() {
        speedLabel.text = "SPEED"
        strengthLabel.text = "STRENGTH"
        driveLabel.text = "DRIVEABILITY"
        bonusLabel.text = "NO BONUS"
        bonusView.layer.borderColor = UIColor.bonusBlue.cgColor
        bonusView.layer.borderWidth = 1.5
        bonusView.isHidden = true
    }
    
    func prepare(completion: @escaping () -> ()) {
        self.sceneView.prepare([self.sceneView.scene as Any]) { (done) in
            completion()
        }
    }
    
    func addBalls() {
        let mightyPoo = Poo(name: PooName.MightyPoop)
        if isPooUnlocked(mightyPoo) && !Poo.players.contains(mightyPoo) {
            Poo.players.append(Poo(name: PooName.MightyPoop))
        }
        for poo in Poo.players {
            let index = Poo.players.firstIndex {$0.name == poo.name}!
            let pooNode = createOpponent(poo: poo, index: index)
            pooNode.scale = SCNVector3(2.5, 2.5, 2.5)
            pooNode.position = SCNVector3(index*10, 0, -2)
            pooNode.physicsBody?.isAffectedByGravity = false
            sceneView.scene!.rootNode.addChildNode(pooNode)
            pooNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
            pooNode.name = poo.name.rawValue
            nodes.append(pooNode)
        }
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
        selectButton.isHidden = false
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
            selectButton.setImage(UIImage(systemName: "lock.fill"), for: .normal)
            selectButton.setNeedsDisplay()
            selectButton.backgroundColor = UIColor.lightGray
            nameLabel.textColor = UIColor.lightGray
            selectButton.isEnabled = false
        } else {
            selectButton.setImage(nil, for: .normal)
            selectButton.setNeedsDisplay()
            selectButton.backgroundColor = UIColor.aqua
            nameLabel.textColor = UIColor.labelBlack
            selectButton.isEnabled = true
        }
    }
    
    func advance() {
        DispatchQueue.main.async {
            if self.isMultiplayer {
                self.navigation.push(MultiplayerVC())
            } else {
                self.goToRace()
            }
        }
    }
    
    func goToRace() {
        let gameVC = GameViewController(players: getPlayers())
        navigation.startLoading()
        navigation.goTo(gameVC)
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
        UIImpactFeedbackGenerator.init(style: .rigid).impactOccurred()
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
        SessionData.shared.selectedPlayer.displayName = getName()
        let action = SCNAction.move(to: SCNVector3(Float(selectedItem*10), 0, -1), duration: 1)
        nodes[selectedItem].runAction(action) {
            self.advance()
        }
    }
    
    private func backToDefault() {
        view.isUserInteractionEnabled = true
        for object in fallingObjects.shuffled() {
            object.transform = CGAffineTransform.identity
        }
        self.nameLabel.transform = CGAffineTransform.identity
        nodes[selectedItem].removeAllParticleSystems()
        SessionData.shared.selectedPlayer = Poo(name: PooName(index: selectedItem), id: getID())
        SessionData.shared.selectedPlayer.displayName = getName()
        let action = SCNAction.move(to: SCNVector3(Float(selectedItem*10), 0, -2), duration: 0.1)
        nodes[selectedItem].runAction(action)
    }
    
    private func getPlayers() -> [Poo] {
        var players = Poo.players
        players[selectedItem] = SessionData.shared.selectedPlayer
        // remove mightyPoo if is not user
        if players[selectedItem].name != .MightyPoop && players.contains(Poo(name: .MightyPoop)) {
            players.removeAll { $0.name == .MightyPoop }
        }
        return players
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
