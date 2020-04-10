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

class GameViewController: UIViewController, BonusProvider, StoreProvider, PooNodeCreator {
    
        
    var sceneView:SCNView!
    var scene:SCNScene!
    
    // nodes in the game
    var pooNode: SCNNode!
    var selfieStickNode: SCNNode!
    var floor: SCNNode!
    var toiletNode: SCNNode!
    
    // managers
    var contactManager: ContactManager!
    var controllerView: ControllerView!
    var raceResultManager = RaceResultManager.shared
    var multiplayer: MultiplayerManager?
    
    /// length of track
    var length: Float = -250
    /// timer that triggers specific opponents actions (bonus usage)
    var oppTimer = Timer()
    var multiplayerTimer = Timer()
    /// started is true when game is playing, so poos are moved
    var started = false
    /// game is over when pooNode has completed the track
    var gameOver = false
    /// Array of currentPlayers, AI or multiplayer
    var currentPlayers: [Poo]
    
    /// array of nodes that finished the track
    var winners : [SCNNode] = []
    //test
    //    var currentPlayers = [Poo(name: PooName.IndianSurprise)]
    /// Array of players, generally copied from global var players. It SHOULD CHANGE depending on players position
    var ranking = Poo.players
    
    
    
    /// if is bonus from slower activated
    var slowerActivated = false
    /// bool if it should rotate camera at the end
    var shouldRotateCamera: Bool = false
    var room: Room?
    
    // MARK:- PREPARATION AND INITIAL COMMON METHODS
    
    init(players: [Poo]) {
        self.currentPlayers = players
        super.init(nibName: nil, bundle: nil)
    }
    
    func basicSetup() {
        Values.yTot = 2.5
        Values.zTot = 4.0
        length = -400
    }
    
    override func viewDidLoad() {
        basicSetup()
        sceneView = SCNView(frame: view.frame)
        view.addSubview(sceneView)
        contactManager = ContactManager(gameVC: self)
        controllerView = ControllerView(frame: view.frame, gameVC: self)
        prepare()
        view.addSubview(controllerView)
        if let room = room, let index = currentPlayers.selfIndex(getID()) {
            multiplayer = MultiplayerManager(room: room, indexSelf: index)
            multiplayer?.delegate = self
        }
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

    /// create scene, user's node, floor and add opponents
    func prepare() {
        self.setupScene()
        self.pooNode = createPoo()
        self.scene.rootNode.addChildNode(self.pooNode)
        self.addOpponents()
        self.setupFloor()
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
    
    /// general preparation of the scene, not playing yet
    func setupScene(){
        sceneView.delegate = self
        sceneView.allowsCameraControl = false
        scene = sceneForWorld()
        sceneView.scene = scene
        scene.physicsWorld.contactDelegate = contactManager
        sceneView.isPlaying = false
        selfieStickNode = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
        toiletNode = scene.rootNode.childNode(withName: "toilet", recursively: true)!
        toiletNode.position.z = length
        scene.physicsWorld.gravity = SCNVector3(0, -2, 0)
    }
    
    func setupFloor() {
        floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
        floor.physicsBody?.categoryBitMask = Collider.floor
        floor.physicsBody?.collisionBitMask = Collider.obstacle | Collider.poo
    }
    
    
    /// returns a specific scene based on world passed
    func sceneForWorld() -> SCNScene {
        return SCNScene(named: "art.scnassets/worldScene/MainScene.scn")!
    }
    
    /// For every currentPlayers, create poo and nodes
    func addOpponents() {
        for index in 0...currentPlayers.count - 1 {
            if currentPlayers[index].id != getID() {
                // opponent
                let oppNode = createOpponent(poo: currentPlayers[index], index: index)
                currentPlayers[index].reset()
                scene.rootNode.addChildNode(oppNode)
                currentPlayers[index].node = oppNode
                oppNode.name = currentPlayers[index].name.rawValue
            } else {
                initUsersPoo(currentPlayers[index], index: index)
            }
        }
    }
    
    
    // init user's poo. Connects the node to the poo and saves it in local session data. Also resets it (for some reason 🧐)
    func initUsersPoo(_ poo: Poo, index: Int) {
        SessionData.shared.selectedPlayer = poo
        SessionData.shared.selectedPlayer.node = pooNode
        SessionData.shared.selectedPlayer.reset()
        self.currentPlayers[index] = SessionData.shared.selectedPlayer
    }
    
    func newGame() {
        //time to stop waiting
        moveCamera()
        shouldRotateCamera = false
    }
    
    /// initial animation of camera moving from end off track to beginning. Scope of this action is also to load the nodes so that the rendering is less bumpy during the race.
    @objc func moveCamera() {
        Navigation.stopLoading()
        let cameraPosition = SCNVector3(Values.xTot, Values.yTot, Values.zTot)
        let action = SCNAction.move(to: cameraPosition, duration: 3)
        selfieStickNode.runAction(action) {
            self.selfieStickNode.childNodes.first?.camera?.motionBlurIntensity = 0.0
            self.isReadyToStart()
        }
    }
    
    func isReadyToStart() {
        if let multiplayer = multiplayer {
            multiplayer.sendStatus(.Ready)
        } else {
            start()
        }
    }
    
    /// actual moment when game starts (physics, camera ecc...)
    func start() {
        started = true
        scene.isPaused = false
        sceneView.isPlaying = true
        controllerView.start()
        raceResultManager.start()
        perform(#selector(startOppTimer), with: nil, afterDelay: 1)
    }
    
    /// Adapt timing to the other player (can have different start time otherwise)
    func prepareMultiplayer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.startMultiplayer()
        })
    }
    
    /// actual moment when game starts for Multiplayer (physics, camera ecc...)
    @objc func startMultiplayer() {
        ranking = currentPlayers
        started = true
        scene.isPaused = false
        sceneView.isPlaying = true
        controllerView.start()
        raceResultManager.start()
    }
    
    // MARK:- BONUS RELATED STUFF
    
    /// Timer to activate bonus for a random opponent, for simulation
    @objc func startOppTimer() {
//        oppTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
//            let random = Int(arc4random_uniform(UInt32(self.currentPlayers.count)))
//            self.activateOpponentBonus(poo: self.currentPlayers[random])
//        })
    }
    
    /// activate bonus opponent (if there's any)
    func activateOpponentBonus(poo: Poo) {
        guard let bonus = poo.bonus() else { return }
        // check if it's really opponent and if can use bonus at the moment
        guard poo.node != pooNode, poo.canUseBonus == true && poo.bonusEnabled == false else { return }
        poo.bonusEnabled = true
        let _ = Timer.scheduledTimer(timeInterval: TimeInterval(bonus.duration()), target: self, selector: #selector(stopOpponentBonus(sender:)), userInfo: ["index": index], repeats: false)
        showBonus(bonus: bonus, node: poo.node)
    }
    
    /// stop opponent's bonus when expired, receives the index of bonus player in the timer user info
    @objc func stopOpponentBonus(sender: Timer) {
        guard let info = sender.userInfo as? [String: Int], let index = info["index"] else { return }
        let bonusPoo = currentPlayers[index]
        guard let bonus = bonusPoo.bonus() else { return }
        bonusPoo.bonusEnabled = false
        bonusPoo.canUseBonus = false
        currentPlayers[index] = bonusPoo
        stopShowBonus(bonus: bonus, node: bonusPoo.node!)
        let _ = Timer.scheduledTimer(timeInterval: TimeInterval(bonus.rechargeDuration()/2), target: self, selector: #selector(rechargeOpponentBonus(sender:)), userInfo: info, repeats: false)
    }
    
    /// recharge the bonus so cannot use consecutively
    @objc func rechargeOpponentBonus(sender: Timer) {
        guard let info = sender.userInfo as? [String: Int], let index = info["index"] else { return }
        currentPlayers[index].canUseBonus = true
    }
    
    // MARK:- MOVING POOPS, CAMERA AND TURNING
    
    /// called from controllerView, user tapped the screen
    func shouldTurn(force: CGFloat) {
        let turningForce = SessionData.shared.selectedPlayer.turningForce()*force
        let right = force > 0
        let force = SCNVector3(turningForce, 0, 0)
        pooNode.physicsBody?.applyForce(force, asImpulse: true)
        let rotation: CGFloat = right ? 0.005 : -0.005
        let rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: rotation, duration: 0.4)
        selfieStickNode.runAction(rotateAction) {
            self.selfieStickNode.runAction(rotateAction.reversed())
        }
    }
    
    /// in a for loop, a force is applied on every poo based on it's speed (also with bonus)
    func movePoops() {
        for n in 0...currentPlayers.count - 1 {
            let poo = currentPlayers[n]
            let bonusOffset = calculateBonusOffset(poo)
            if let node = poo.node, !poo.isMultiplayer {
                checkIfBonusShouldDisabled(poo, node, n)
                node.physicsBody?.applyForce(SCNVector3(0, 0, poo.velocity() + bonusOffset), asImpulse: true)
            }
        }
    }
    
    /// if getting too close to finish line, bonus should be disabled for opponents and removed for user
    func checkIfBonusShouldDisabled(_ poo: Poo, _ node: SCNNode, _ index: Int) {
        if node.presentation.position.z < length + 50 && poo.canUseBonus == true {
            if node == pooNode {
                poo.canUseBonus = false
                DispatchQueue.main.async {
                    self.controllerView.removeBonus()
                }
            } else {
                poo.canUseBonus = false
            }
            // resave the poo so that cannot use bonus
            currentPlayers[index] = poo
        }
    }
    
    /// calculate if bonus are on for a poo and how much offset should be applied to it's speed
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
                    return -0.2 + offset
                }
            }
        }
        return offset
    }
    
    /// returns first camera position
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
    
    /// AI to detect if a collision is coming and to avoid it
    @objc func blockAvoider() {
        for opponent in currentPlayers.filter({$0.id != getID()}) {
            guard !opponent.isMultiplayer else { return }
            let pos = opponent.node.presentation.position
            opponent.turn(direction: getBestDirection(pos: pos))
        }
    }
    
    /// Returns best direction possible for a node, based on it's position and colliders positions. Pretty complex logic to dive in but tested 🤷🏻‍♂️.
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
        let level: Int = {
            switch retrieveLevel() {
            case 0: return 5
            case 2: return 10
            default: return 7
            }
        }()
        for ind in 1...level {
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
    
    /// action when poo collides with carpet
    func jump(node: SCNNode) {
        node.physicsBody?.clearAllForces()
        if node == pooNode {
            shouldRotateCamera = true
            node.physicsBody?.clearAllForces()
            scene.physicsWorld.gravity = SCNVector3(0, -0.5, 0)
            node.physicsBody?.applyForce(SCNVector3(0, 3.7, -0.12), asImpulse: true)
            node.physicsBody?.applyTorque(SCNVector4(0.5, 0.5, 0.5, 0.5), asImpulse: true)
            perform(#selector(forceFinish), with: nil, afterDelay: 4)
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
    
    // MARK:- END OF RACE
    
    /// game is finished for a specific poo: if poo is user, tells multiplayer and prepares finale
    func handleFinish(_ poo: SCNNode) {
        guard poo.name != nil && poo.name != "" && poo.name != "C_Low" && poo.name != "carpet" else { return }
        didFinish(node: poo)
        if poo == pooNode {
            gameOver = true
            multiplayer?.sendStatus(.Finish)
            gameIsOver()
            addFinalAnimation()
            let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addFinishView), userInfo: nil, repeats: false)
        }
    }
    
    /// called by every poo when finish race. update winners array, raceResultManager (BUGGY) and multiplayer
    func didFinish(node: SCNNode) {
        node.removeFromParentNode()
        if !winners.contains(node) {
            winners.append(node)
//            if !isMultiplayer {
                raceResultManager.didFinish(poo: PooName(rawValue: node.name!)!, penalty: false)
//            } else {
//                guard node != pooNode else {return }
//                raceResultManager.didFinishMultiplayer(poo: vsPoo!, gameOver: false)
//            }
        }
    }
    
    func addFinalAnimation() {
        guard let trail = SCNParticleSystem(named: "spluff", inDirectory: nil) else { return  }
        toiletNode.addParticleSystem(trail)
    }
    
    /// if user didn't finish (ex: entered the toilet..) this force the game to end with a penalty. Basically same thing as handleFinish method but with small changes.
    @objc func forceFinish() {
        if !winners.contains(pooNode) {
            winners.append(pooNode)
            raceResultManager.didFinish(poo: PooName(rawValue: pooNode.name!)!, penalty: true)
            gameOver = true
            gameIsOver()
        }
    }
    
    /// Stops controller view, multiplayer, invalidate timer,
    func gameIsOver() {
        oppTimer.invalidate()
        controllerView.stop()
//        if !isMultiplayer {
//            raceResultManager.getResults(opponents: opponents, length: length)
//        } else {
            raceResultManager.didFinishMultiplayer(poo: SessionData.shared.selectedPlayer, gameOver: true)
//        }
    }
    
    /// user stopped the game. Go back to main screen.
    func stopped() {
        oppTimer.invalidate()
        multiplayerTimer.invalidate()
        controllerView.stop()
        sceneView.stop(nil)
        multiplayer?.removeObservers()
        Navigation.main.popToRootViewController(animated: true)
    }
    
    /// tells the controller to add the finish view on top (white screen with opacity animation)
    @objc func addFinishView(_ sender: Timer) {
        controllerView.addFinishView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameViewController : BonusButtonDelegate {
    
    // pretty clear right? 🤓
    func didTapButton(bonus: Bonus) {
        showBonus(bonus: bonus, node: pooNode)
    }
    
    func didFinishBonus(bonus: Bonus) {
        stopShowBonus(bonus: bonus, node: pooNode)
    }
}

extension GameViewController : SCNSceneRendererDelegate {
    
    /// renderer gets called continously! moves the camera, moves the poos, avoid blocks for opponent and send multiplayer position
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard gameOver == false else { return }
        if shouldRotateCamera == true {
            if Values.zTot > 10 { Values.zTot -= 0.03 }
            if Values.yTot < 20 { Values.yTot += 0.01 }
            if selfieStickNode.eulerAngles.x > -Float.pi/2 { selfieStickNode.eulerAngles.x -= 0.01 }
        }
        let cameraPosition = getCameraPosition()
        selfieStickNode.position = cameraPosition
        guard started == true else { return }
        movePoops()
        blockAvoider()
    }
}

extension GameViewController : MultiplayerDelegate {
    
    func shouldStart() {
        multiplayer?.removeObservers()
        guard !started else { return }
        start()
        multiplayerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            guard !self.gameOver && self.sceneView.isPlaying else {
                timer.invalidate()
                return
            }
            self.updatePlayers()
            self.sendMultiplayerData()
        })
    }
    
    /// get position of opponents's poo
    func updatePlayers() {
        multiplayer?.updatePlayers({ (players) in
            for pl in players {
                if pl.id != self.getID() {
                    let poo = self.currentPlayers.pooWithPl(pl)
                    poo.node.runAction(SCNAction.move(to: SCNVector3(pl.position.x, pl.position.y, pl.position.z), duration: 0.1))
                }
            }
        })
    }
    
    /// send position of user's poo
    func sendMultiplayerData() {
        let pooPosition = pooNode.presentation.position
        multiplayer?.sendPosition(x: pooPosition.x, y: pooPosition.y, z: pooPosition.z)
    }
}
