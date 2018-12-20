//
//  GameViewController.swift
//  TheRace
//
//  Created by Enrico Castelli on 02/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//


import UIKit
import SceneKit
import AudioToolbox

class GameViewController: UIViewController {
    
    ///Selected world or circuit where poops are playing
    var world = World.toilet
    
    var sceneView:SCNView!
    var scene:SCNScene!
    
    // nodes in the game
    var pooNode: SCNNode!
    // optional vsOpponent
    var vsOpponent: SCNNode?
    var selfieStickNode: SCNNode!
    var floor: SCNNode!
    
    var contactManager: ContactManager!
    var controllerView: ControllerView!
    var raceResultManager = RaceResultManager.shared
    var multiplayer: MultiplayerManager? {
        didSet {
            multiplayer?.delegate = self
        }
    }
    /// length of track
    var length: Float = -250
    
    /// timer that triggers specific opponents actions (bonus usage)
    var oppTimer = Timer()

    /// started is true when game is playing, so poos are moved
    var started = false
    
    /// game is over when pooNode has completed the track
    var gameOver = false
    
    /// bool triggered at the right time at beginning so that camera moves nicely from the end to the beginning of the track
    var shouldMoveCamera = false
    
    /// array of nodes that finished the track
    var winners : [SCNNode] = []
    
    /// Array of currentPlayers, generally copied from global var players. Order SHOULD NOT change
    var currentPlayers = players
    //test
//    var currentPlayers = [Poo(name: PooName.GuanoStar)]
    
    /// Array of current opponents
    var opponents:[Poo] = []
    
    /// Array of players, generally copied from global var players. It SHOULD CHANGE depending on players position
    var ranking = players
    //test
//    var ranking = [Poo(name: PooName.GuanoStar)]

    /// if is bonus from slower activated
    var slowerActivated = false
    /// specifies a special position at beginning for poos
    var position: SCNVector3?
    /// bool if it should rotate camera
    var shouldRotateCamera: Bool = true
    
    // MARK:- PREPARATION AND INITIAL COMMON METHODS
    
    override func viewDidLoad() {
        sceneView = SCNView(frame: view.frame)
        view.addSubview(sceneView)
        contactManager = ContactManager(gameVC: self)
        controllerView = ControllerView(frame: view.frame, gameVC: self)
        prepare()
        view.addSubview(controllerView)
    }
    
    func prepare() {
        self.setupScene()
        self.pooNode = (PooNodeCreator.createPoo(postion: position))
        self.scene.rootNode.addChildNode(self.pooNode)
        self.addOpponents()
        self.setupFloor()
        multiplayer?.sendName(SessionData.shared.selectedPlayer.name)
    }
    
    func setupScene(){
        sceneView.delegate = self
        sceneView.allowsCameraControl = false
        scene = sceneForWorld()
        sceneView.scene = scene
        scene.physicsWorld.contactDelegate = contactManager
        sceneView.isPlaying = false
        selfieStickNode = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
    }
    
    func setupFloor() {
        floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
        floor.physicsBody?.categoryBitMask = Collider.floor
        floor.physicsBody?.collisionBitMask = Collider.obstacle | Collider.poo
    }
    
    func sceneForWorld() -> SCNScene {
        switch world {
        case .toilet:
            return SCNScene(named: "art.scnassets/worldScene/MainScene.scn")!
        case .pipe:
            return SCNScene(named: "art.scnassets/worldScene/testScene.scn")!
        case .house:
            return SCNScene(named: "art.scnassets/worldScene/doubleScene.scn")!
        case .falling:
            return SCNScene(named: "art.scnassets/worldScene/fallingScene.scn")!
        case .water:
            return SCNScene(named: "art.scnassets/worldScene/waterScene.scn")!
        }
    }
    
    func addOpponents() {
        for index in 0...currentPlayers.count - 1 {
            if currentPlayers[index].name != SessionData.shared.selectedPlayer.name {
                let oppNode = PooNodeCreator.createOpponent(index: index, postion: position)
                currentPlayers[index].reset()
                scene.rootNode.addChildNode(oppNode)
                opponents.append( currentPlayers[index])
                currentPlayers[index].node = oppNode
                oppNode.name = currentPlayers[index].name.rawValue
            } else {
                SessionData.shared.selectedPlayer.node = pooNode
                self.currentPlayers[index] = SessionData.shared.selectedPlayer
                self.currentPlayers[index].reset()
            }
        }
    }
    
    func newGame() {
        //time to stop waiting
        moveCamera()
    }
    
    /// initial animation of camera moving from end off track to beginning. Scope of this action is also to load the nodes so that the rendering is less bumpy during the race.
    @objc func moveCamera() {
        Navigation.stopLoading()
        let cameraPosition = SCNVector3(Values.xTot, Values.yTot, Values.zTot)
        let action = SCNAction.move(to: cameraPosition, duration: 3)
        selfieStickNode.runAction(action) {
            self.start()
        }
    }
        
    @objc func start() {
        shouldMoveCamera = true
        started = true
        scene.isPaused = false
        sceneView.isPlaying = true
        controllerView.start()
        raceResultManager.start()
        perform(#selector(startOppTimer), with: nil, afterDelay: 1)
    }
    
    // MARK:- BONUS RELATED STUFF
        
    @objc func startOppTimer() {
        oppTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(createRandomBonusOpponent), userInfo: nil, repeats: true)
    }
    
    @objc func createRandomBonusOpponent() {
        let random = Int(arc4random_uniform(UInt32(currentPlayers.count)))
        activateOpponentBonus(index: random)
    }
    
    func activateOpponentBonus(index: Int) {
        if let bonus = currentPlayers[index].bonus() {
            let bonusNode = currentPlayers[index].node
            guard bonusNode != pooNode else { return }
            let bonusPoo = currentPlayers[index]
            guard bonusPoo.canUseBonus == true && bonusPoo.bonusEnabled == false else { return }
            currentPlayers[index].bonusEnabled = true
            let _ = Timer.scheduledTimer(timeInterval: TimeInterval(bonus.duration()), target: self, selector: #selector(stopOpponentBonus(sender:)), userInfo: ["index": index], repeats: false)
            showBonus(bonus: bonus, node: bonusNode!)
        }
    }
    
    @objc func stopOpponentBonus(sender: Timer) {
        guard let info = sender.userInfo as? [String: Int], let index = info["index"] else { return }
        let bonusPoo = currentPlayers[index]
        if let bonus = bonusPoo.bonus() {
            bonusPoo.bonusEnabled = false
            bonusPoo.canUseBonus = false
            currentPlayers[index] = bonusPoo
            stopShowBonus(bonus: bonus, node: bonusPoo.node!)
            let _ = Timer.scheduledTimer(timeInterval: TimeInterval(bonus.rechargeDuration()/2), target: self, selector: #selector(rechargeOpponentBonus(sender:)), userInfo: info, repeats: false)
        }
    }
    
    @objc func rechargeOpponentBonus(sender: Timer) {
        guard let info = sender.userInfo as? [String: Int], let index = info["index"] else { return }
        currentPlayers[index].canUseBonus = true
    }
    
    
    // MARK:- MOVING POOPS, CAMERA AND TURNING
    
    func shouldTurn(right: Bool) {
        let turningForce = SessionData.shared.selectedPlayer.turningForce()
        let rightLeftForce = right ? turningForce : -turningForce
        let force = SCNVector3(rightLeftForce, 0, 0)
        pooNode.physicsBody?.applyForce(force, asImpulse: true)
        if shouldRotateCamera {
            let rotation: CGFloat = right ? 0.05 : -0.05
            let rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: rotation, duration: 0.4)
            selfieStickNode.runAction(rotateAction) {
                self.selfieStickNode.runAction(rotateAction.reversed())
            }
        }
    }
    
    func showBonus(bonus: Bonus, node: SCNNode) {
        if let bonusTrail = SCNParticleSystem(named: "smoke", inDirectory: nil) {
            bonusTrail.loops = true
            node.addParticleSystem(bonusTrail)
        }
        switch bonus {
        case .NoBonus:
            break
        case .Sprint:
            break
        case .Slower:
            slowerActivated = true
            break
        case .Ghost:
            node.geometry?.materials.first?.transparent.contents = UIColor.white.withAlphaComponent(0.2)
            node.physicsBody?.collisionBitMask = Collider.floor | Collider.bounds
            break
        case .Teleport:
            node.runAction(SCNAction.move(to: SCNVector3(pooNode.presentation.position.x, pooNode.presentation.position.y, pooNode.presentation.position.z - 15), duration: 0.05))
            break
        case .MiniPoo:
            let geo = SCNSphere(radius: 0.2)
            geo.materials.first?.diffuse.contents = UIColor.brown
            let lserN = SCNNode(geometry: geo)
            lserN.position = node.presentation.position
            lserN.position.z = node.presentation.position.z + 1
            lserN.physicsBody = SCNPhysicsBody.static()
            scene.rootNode.addChildNode(lserN)
            break
        case .Almighty:
            node.geometry?.materials.first?.transparent.contents = UIColor.white.withAlphaComponent(0.2)
            node.physicsBody?.collisionBitMask = Collider.floor | Collider.bounds
            slowerActivated = true
            break
        }
    }
    
    func stopShowBonus(bonus: Bonus, node: SCNNode) {
        node.removeAllParticleSystems()
        node.opacity = 1
        switch bonus {
        case .NoBonus:
            break
        case .Sprint:
            break
        case .Slower:
            slowerActivated = false
            break
        case .Ghost:
            node.geometry?.materials.first?.transparent.contents = UIColor.white.withAlphaComponent(1)
            node.physicsBody?.collisionBitMask = 0xFFFFFFFF
            break
        case .Teleport:
            break
        case .MiniPoo:
            break
        case .Almighty:
            slowerActivated = false
            node.geometry?.materials.first?.transparent.contents = UIColor.white.withAlphaComponent(1)
            node.physicsBody?.collisionBitMask = 0xFFFFFFFF
            break
        }
    }
    
    func movePoops() {
        for n in 0...currentPlayers.count - 1 {
            let poo = currentPlayers[n]
            let bonusOffset = calculateBonusOffset(poo)
            if poo.node!.presentation.position.z < length + 50 && poo.canUseBonus == true {
                if poo.node == pooNode {
                    poo.canUseBonus = false
                    DispatchQueue.main.async {
                        self.controllerView.removeBonus()
                    }
                } else {
                    poo.canUseBonus = false
                }
                currentPlayers[n] = poo
            }
            poo.node?.physicsBody?.applyForce(SCNVector3(0, 0, poo.velocity() + bonusOffset), asImpulse: true)
        }
    }
    
    func calculateBonusOffset(_ poo: Poo) -> Float {
        let offset : Float  = {
            if slowerActivated && poo.bonus() != .Slower && poo.bonus() != .Almighty {
                return 0.015
            } else { return 0 }
        }()
        guard poo.bonusEnabled else { return offset }
        if let bonus = poo.bonus() {
            if bonus == .Sprint {
                if poo.bonusEnabled {
                    return -0.07 + offset
                }
            }
        }
        return offset
    }
    
    func getCameraPosition() -> SCNVector3 {
        let pooPosition = pooNode.presentation.position
        let targetPosition = SCNVector3(x: pooPosition.x + Values.xTot, y: pooPosition.y + Values.yTot, z:pooPosition.z + Values.zTot)
        var cameraPosition = selfieStickNode.position
        let camDamping:Float = 0.3
        let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
        let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
        let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping
        cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
        return cameraPosition
    }
    
    @objc func blockAvoider() {
        for opponent in opponents {
            let pos = opponent.node.presentation.position
            opponent.turn(direction: getBestDirection(pos: pos))
        }
    }
    
    func getBestDirection(pos: SCNVector3) -> Direction {
        var rightList = [SCNHitTestResult]()
        var leftList = [SCNHitTestResult]()
        let straightList =
            scene.physicsWorld.rayTestWithSegment(from: pos, to: SCNVector3(pos.x, 0.5, pos.z - 5), options: nil) +
            scene.physicsWorld.rayTestWithSegment(from: pos, to: SCNVector3(pos.x + 0.3, 0.5, pos.z - 5), options: nil) +
            scene.physicsWorld.rayTestWithSegment(from: pos, to: SCNVector3(pos.x - 0.3, 0.5, pos.z - 5), options: nil)
        let isLimit = (pos.x > 6.5 || pos.x < -6.5)
        if straightList.count == 0 {
            return .straight
        }
        if isLimit {
            return pos.x > 6.5 ? .left : .right
        }
        for ind in 1...10 {
            let x = 12/2 - Float(ind)/2
            let z = -Float(ind)/3
            let pointR = SCNVector3(pos.x + x, 0.5, pos.z + z)
            let pointL = SCNVector3(pos.x - x, 0.5, pos.z + z)
            rightList = rightList + scene.physicsWorld.rayTestWithSegment(from: pos, to: pointR, options: nil)
            leftList = leftList + scene.physicsWorld.rayTestWithSegment(from: pos, to: pointL, options: nil)
        }

        if leftList.count == rightList.count {
            if pos.x == 0 { return arc4random_uniform(2) == 1 ? .left : .right }
        }
        return leftList.count > rightList.count ? .right : .left
    }
    
    func jump(node: SCNNode) {
        // TO BE OVERRIDDEN
    }
    
    // MARK:- END OF RACE
    
    func handleFinish(_ poo: SCNNode) {
        if poo == pooNode {
            gameOver = true
            gameIsOver()
            addFinalAnimation()
            let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addFinishView), userInfo: nil, repeats: false)
        }
        didFinish(node: poo)
    }
    
    func didFinish(node: SCNNode) {
        if !winners.contains(node) {
            winners.append(node)
            raceResultManager.didFinish(poo: PooName(rawValue: node.name!)!, penalty: false)
        }
    }
    
    @objc func checkFinish() {
        if !winners.contains(pooNode) {
            winners.append(pooNode)
            raceResultManager.didFinish(poo: PooName(rawValue: pooNode.name!)!, penalty: true)
            gameOver = true
            gameIsOver()
        }
    }
    
    func gameIsOver() {
        oppTimer.invalidate()
        controllerView.stop()
        raceResultManager.getResults(opponents: opponents, length: length)
    }
    
    func stopped() {
        oppTimer.invalidate()
        Navigation.main.popToRootViewController(animated: true)
    }
    
    func addFinalAnimation() {
        // TO BE OVERRIDDEN
    }
    
    @objc func addFinishView(_ sender: Timer) {
        controllerView.addFinishView()
    }
}

extension GameViewController : BonusButtonDelegate {
    
    func didTapButton(bonus: Bonus) {
        showBonus(bonus: bonus, node: pooNode)
    }
    
    func didFinishBonus(bonus: Bonus) {
        stopShowBonus(bonus: bonus, node: pooNode)
    }
}

extension GameViewController : SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if shouldMoveCamera {
            let cameraPosition = getCameraPosition()
            selfieStickNode.position = cameraPosition
        }
        guard started == true else { return }
        movePoops()
        blockAvoider()
        sendMultiplayerData()
    }
}

extension GameViewController : MultiplayerDelegate {
    
    func createVSOpponentNode(name: PooName) {
        vsOpponent = PooNodeCreator.createVSOpponent(name: name, position: SCNVector3(1, 0.5, 0))
    }
    
    func sendMultiplayerData() {
        let pooPosition = pooNode.presentation.position
        multiplayer?.sendPosition(x: pooPosition.x, y: pooPosition.y, z: pooPosition.z)
    }
    
    func didReceivePosition(pos: PlayerPosition) {
        vsOpponent?.position = SCNVector3(pos.xPos, pos.yPos, pos.xPos)
    }
    
    func didReceivePooName(_ name: PooName) {
        createVSOpponentNode(name: name)
    }
    
    

}
