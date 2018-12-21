//
//  PooMakerResultVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 20/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import SceneKit

class PooMakerShowroomVC: ShowroomVC {
    
    var items : [FoodItem]
    var pooNode: SCNNode!
    var bolusItem : BolusItem?
    
    init(items: [FoodItem]) {
        self.items = items
        super.init(nibName: String(describing: ShowroomVC.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func addBalls() {
        bolusItem = PooMaker.createBolus(items)
        pooNode = PooNodeCreator.createCustomizedBall(postion: SCNVector3(0, 3, 0), item: bolusItem!)
        sceneView.scene?.rootNode.addChildNode(pooNode)
        addFloor()
    }
    
    func addFloor() {
        let geo = SCNPlane(width: 5, height: 5)
        geo.materials.first?.diffuse.contents = UIColor.clear
        let node = SCNNode(geometry: geo)
        node.position = SCNVector3(0, -0.5, 0)
        node.eulerAngles = SCNVector3(CGFloat.pi/2, 0, 0)
        sceneView.scene?.rootNode.addChildNode(node)
        node.physicsBody = SCNPhysicsBody.static()
    }
    
   override func addButtons() {
        nameLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.height - 100, width: 0, height: 0))
        nameLabel.textColor = UIColor.black
        // set label background
        nameLabel.layer.backgroundColor = UIColor.white.cgColor
        nameLabel.layer.cornerRadius = 10
        // Calculate the actual frame of label with text
        nameLabel.frame.size.width = nameLabel.intrinsicContentSize.width
        nameLabel.frame.size.height = nameLabel.intrinsicContentSize.height + 2
        nameLabel.center.x = view.center.x
        self.view.addSubview(nameLabel)
        backButton = UIButton(frame: CGRect(x: 16, y: 16, width: 64, height: 64))
        backButton.setTitle("◀️", for: .normal)
        backButton.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        self.view.addSubview(backButton)
        selectButton = UIButton(frame: CGRect(x: 16, y: view.frame.height - 80, width: 200, height: 64))
        selectButton.setTitle("SAVE", for: .normal)
        selectButton.titleLabel?.textAlignment = .center
        selectButton.addTarget(self, action: #selector(selectTap), for: .touchUpInside)
        selectButton.center.x = UIScreen.main.bounds.width/2
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        self.view.addSubview(selectButton)
    }
    
    
    @objc override func selectTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.8) {
            self.backButton.alpha = 0
            self.selectButton.alpha = 0
            self.nameLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
        savePoo()
        view.isUserInteractionEnabled = false
        selectButton.isEnabled = false
        guard let trail = SCNParticleSystem(named: "smoke", inDirectory: nil) else { return }
        pooNode.addParticleSystem(trail)
        let action = SCNAction.move(to: SCNVector3(0, 0, -1), duration: 3)
        pooNode.runAction(action)
        perform(#selector(goBack), with: nil, afterDelay: 1)
    }
    
    func savePoo() {
        guard let bolusItem = bolusItem else { return }
        StorageManager.saveBolus(bolusItem)
    }
    
}
