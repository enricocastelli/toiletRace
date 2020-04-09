//
//  ShowroomVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 24/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import SceneKit

class ShowroomVC: UIViewController {

    var sceneView: SCNView!
    var nodes: [SCNNode] = []
    var cameraNode: SCNNode!
    
    var rightButton: UIButton!
    var leftButton: UIButton!
    var backButton: UIButton!
    var selectButton: UIButton!
    var nameLabel: UILabel!
    var bonusView: BonusButton!
    
    var selectedItem = 0 {
        didSet {
            nameLabel.text = "  \(nodes[selectedItem].name!)  "
            nameLabel.frame.size.width = nameLabel.intrinsicContentSize.width
            nameLabel.frame.size.height = nameLabel.intrinsicContentSize.height + 2
            nameLabel.center.x = view.center.x
            if let bonus = players[selectedItem].bonus() {
                bonusView.updateBonus(bonus: bonus)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0
        sceneView = self.view as? SCNView
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.scene!.background.contents = UIImage(named: "bath")
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 2)
        sceneView.scene!.rootNode.addChildNode(cameraNode)
        addLight()
        addBalls()
        // Do any additional setup after loading the view.
        addBonus()
        prepare {
            self.view.alpha = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addButtons()
    }
    
    func prepare(completion: @escaping () -> ()) {
        sceneView.prepare([sceneView.scene as Any]) { (done) in
           completion()
        }
    }
    
    func addBalls() {
        for index in 0...players.count - 1 {
            let pooNode = PooNodeCreator.createOpponent(index: index, postion: nil)
            pooNode.position = SCNVector3(index*10, 0, -2)
            pooNode.physicsBody?.isAffectedByGravity = false
            sceneView.scene!.rootNode.addChildNode(pooNode)
            pooNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
            pooNode.name = players[index].name.rawValue
            nodes.append(pooNode)
        }
        if shouldShowMighty {
            shouldShowMighty = false
            players.append(Poo(name: PooName.MightyPoop))
            let index = players.count - 1
            let pooNode = PooNodeCreator.createOpponent(index: index, postion: nil)
            pooNode.position = SCNVector3(index*10, 0, -2)
            pooNode.physicsBody?.isAffectedByGravity = false
            sceneView.scene!.rootNode.addChildNode(pooNode)
            pooNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
            pooNode.name = players[index].name.rawValue
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
    
    func addButtons() {
        self.view.layoutIfNeeded()
        rightButton = UIButton(frame: CGRect(x: view.frame.width - 80, y: 0, width: 80, height: 64))
        rightButton.center.y = view.center.y
        rightButton.setTitle("▶️", for: .normal)
        rightButton.addTarget(self, action: #selector(rightTap), for: .touchUpInside)
        leftButton = UIButton(frame: CGRect(x: 32, y: 0, width: 64, height: 64))
        leftButton.center.y = view.center.y
        leftButton.setTitle("◀️", for: .normal)
        leftButton.addTarget(self, action: #selector(leftTap), for: .touchUpInside)
        self.view.addSubview(leftButton)
        self.view.addSubview(rightButton)
        nameLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.height - 100, width: 0, height: 0))
        nameLabel.textColor = UIColor.black
        // set label background
        nameLabel.layer.backgroundColor = UIColor.white.cgColor
        nameLabel.layer.cornerRadius = 10
        // applying text with extra space
        nameLabel.text = "  \(nodes[selectedItem].name!)  "
        // Calculate the actual frame of label with text
        nameLabel.frame.size.width = nameLabel.intrinsicContentSize.width
        nameLabel.frame.size.height = nameLabel.intrinsicContentSize.height + 2
        nameLabel.center.x = view.center.x
        self.view.addSubview(nameLabel)
        backButton = UIButton(frame: CGRect(x: 16, y: 16, width: 64, height: 64))
        backButton.setTitle("✖️", for: .normal)
        backButton.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        self.view.addSubview(backButton)
        selectButton = UIButton(frame: CGRect(x: 16, y: view.frame.height - 80, width: 256, height: 64))
        selectButton.setTitle("SELECT", for: .normal)
        selectButton.addTarget(self, action: #selector(selectTap), for: .touchUpInside)
        selectButton.center.x = view.center.x
        self.view.addSubview(selectButton)
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    }
    
    func addBonus() {
        if let bonus = players[selectedItem].bonus() {
        bonusView = BonusButton(frame: CGRect(x: view.frame.width - 100, y: view.frame.height - 100, width: 64, height: 64), bonus: bonus, delegate: nil)
            if bonus == .NoBonus {
                bonusView.alpha = 0 } else
            { bonusView.alpha = 1 }
        }
        view.addSubview(bonusView)
        bonusView.isEnabled = false
    }

    @objc func goToRace() {
        let gameVC = GameViewController()
        Navigation.main.pushViewController(gameVC, animated: true)
        Navigation.startLoading()
    }

    @objc func rightTap(_ sender: UIButton) {
        guard selectedItem < players.count - 1 else { return }
        cameraNode.runAction(SCNAction.move(by: SCNVector3(10, 0, 0), duration: 0.5))
        selectedItem += 1
    }
    
    @objc func leftTap(_ sender: UIButton) {
        guard selectedItem > 0 else { return }
        cameraNode.runAction(SCNAction.move(by: SCNVector3(-10, 0, 0), duration: 0.5))
        selectedItem -= 1
    }
    
    @objc func backTap(_ sender: UIButton) {
        goBack()
    }
    
    @objc func goBack() {
        Navigation.main.popViewController(animated: true)
    }
    
    @objc func selectTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.8) {
            self.rightButton.alpha = 0
            self.leftButton.alpha = 0
            self.backButton.alpha = 0
            self.selectButton.alpha = 0
            self.nameLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
        view.isUserInteractionEnabled = false
        selectButton.isEnabled = false
        guard let trail = SCNParticleSystem(named: "smoke", inDirectory: nil) else { return }
        nodes[selectedItem].addParticleSystem(trail)
        let action = SCNAction.move(to: SCNVector3(selectedItem*10, 0, -1), duration: 2)
        nodes[selectedItem].runAction(action)
        SessionData.shared.selectedPlayer = Poo.init(name: PooName(rawValue: nodes[selectedItem].name!)!)
        perform(#selector(goToRace), with: nil, afterDelay: 1.5)
    }
    
}
