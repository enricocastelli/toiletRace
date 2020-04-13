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

class GameViewController: UIViewController, BonusProvider, PooNodeCreator, ContactProvider {
    
        
    var sceneView:SCNView!
    var scene:SCNScene!
    
    // nodes in the game
    var pooNode: SCNNode!
    var selfieStickNode: SCNNode!
    var floor: SCNNode!
    var toiletNode: SCNNode!
    
    // managers
    var controllerView: ControllerView!
    var raceResultManager: RaceResultManager!
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
    
    override func viewDidLoad() {
        basicSetup()
        sceneView = SCNView(frame: view.frame)
        view.addSubview(sceneView)
        controllerView = ControllerView(frame: view.frame, gameVC: self)
        raceResultManager = RaceResultManager(length)
        DispatchQueue.global(qos: .background).async {
            self.prepare()
        }
        view.addSubview(controllerView)
        if let room = room, let index = currentPlayers.selfIndex(getID()) {
            multiplayer = MultiplayerManager(room: room, indexSelf: index)
            multiplayer?.delegate = self
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
    
    func basicSetup() {
        Values.yTot = 2.5
        Values.zTot = 4.0
        length = -400
    }
    
    func addObstacle() {
        let safeEnd = abs(length) - 20
        let supersafeEnd = abs(length) - 40
        let safeStart = UInt32(abs(length) - 40)
        let supersafeStart = UInt32(abs(length) - 70)
        for index in 0...Int(abs(length)/3) {
            let random = Float(index) * 2.7
            let zedRand = safeEnd - random
            scene.rootNode.addChildNode(createPaper(zed: ((0 - zedRand))))
        }
        for _ in 0...5 {
            let random = Float(arc4random_uniform(safeStart))
            let zedRand = safeEnd - random
            scene.rootNode.addChildNode(createSponge(zed: (0 - zedRand)))
        }
        
        let randomPill = Float(arc4random_uniform(supersafeStart))
        let zedRandPill = supersafeEnd - randomPill
        scene.rootNode.addChildNode(createPill(zed: 0 - zedRandPill))
        let random = Float(arc4random_uniform(supersafeStart))
        let zedRand = supersafeEnd - random
        scene.rootNode.addChildNode(createTunnel(zed: 0 - zedRand))
    }

    /// create scene, user's node, floor and add opponents
    func prepare() {
        self.setupScene()
        self.pooNode = createPoo()
        self.scene.rootNode.addChildNode(self.pooNode)
        self.addOpponents()
        self.setupFloor()
        let carpetNode = createCarpet(zed: length)
        self.scene.rootNode.addChildNode(carpetNode)
        for node in createBound(zed: abs(length)) {
            self.scene.rootNode.addChildNode(node)
        }
        self.addObstacle()
        self.scene.rootNode.addChildNode(createFinish(zed: self.length))
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
        scene.physicsWorld.contactDelegate = self
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
        SessionData.shared.selectedPlayer.displayName = getName()
        self.currentPlayers[index] = SessionData.shared.selectedPlayer
    }
    
    func newGame() {
        //time to stop waiting
        moveCamera()
        shouldRotateCamera = false
    }
    
    /// initial animation of camera moving from end off track to beginning. Scope of this action is also to load the nodes so that the rendering is less bumpy during the race.
    @objc func moveCamera() {
        navigation.stopLoading()
        let cameraPosition = SCNVector3(Values.xTot, Values.yTot, Values.zTot)
        let action = SCNAction.move(to: cameraPosition, duration: 2)
        selfieStickNode.runAction(action) {
            self.selfieStickNode.childNodes.first?.camera?.motionBlurIntensity = 0.0
            self.isReadyToStart()
        }
    }
    
    func isReadyToStart() {
        if let multiplayer = multiplayer {
            multiplayer.sendStatus(.Ready)
            controllerView.prepare()
        } else {
            start()
        }
    }
    
    /// actual moment when game starts (physics, camera ecc...)
    func start() {
        if multiplayer == nil {
            controllerView.prepare()
        }
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
            self.started = true
            self.scene.isPaused = false
            self.sceneView.isPlaying = true
            self.controllerView.start()
            self.raceResultManager.start()
            self.perform(#selector(self.startOppTimer), with: nil, afterDelay: 1)
        }

    }
    
    // MARK:- BONUS RELATED STUFF
    
    /// Timer to activate bonus for a random opponent, for simulation
    @objc func startOppTimer() {
        oppTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            let random = Int(arc4random_uniform(UInt32(self.currentPlayers.count)))
            self.activateOpponentBonus(poo: self.currentPlayers[random])
        })
    }
    
    // MARK:- MOVING POOPS, CAMERA AND TURNING
    
    /// called from controllerView, user tapped the screen
    func shouldTurn(force: CGFloat) {
        let turningForce = SessionData.shared.selectedPlayer.turningForce()*force
        let right = force > 0
        let force = SCNVector3(turningForce, 0, 0)
        pooNode.physicsBody?.applyForce(force, asImpulse: true)
        let rotation: CGFloat = right ? 0.002 : -0.002
        let rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: rotation, duration: 0.1)
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
    
    /// action when poo collides with carpet
    func jump(node: SCNNode) {
        node.physicsBody?.clearAllForces()
        if node == pooNode {
            shouldRotateCamera = true
            controllerView.hideTable()
            node.physicsBody?.clearAllForces()
            scene.physicsWorld.gravity = SCNVector3(0, -0.5, 0)
            node.physicsBody?.applyForce(SCNVector3(0, 3.7, -0.12), asImpulse: true)
            node.physicsBody?.applyTorque(SCNVector4(0.5, 0.5, 0.5, 0.5), asImpulse: true)
            let _ = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (_) in
                self.forceFinish()
            }
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
        didFinish(node: poo)
        if poo == pooNode {
            gameIsOver()
        }
    }
    
    /// if user didn't finish (ex: entered the toilet..) this force the game to end with a penalty. Basically same thing as handleFinish method but with small changes.
    func forceFinish() {
        raceResultManager.didFinish(poo: SessionData.shared.selectedPlayer)
        if !gameOver {
            gameIsOver()
        }
    }
    
    /// called by every poo when finish race.
    func didFinish(node: SCNNode) {
        guard let poo = currentPlayers.filter({$0.node == node}).first, !poo.isMultiplayer else { return }
        raceResultManager.didFinish(poo: poo)
        node.removeFromParentNode()
    }
    
    func addFinalAnimation() {
        guard let trail = SCNParticleSystem(named: "spluff", inDirectory: nil) else { return  }
        toiletNode.addParticleSystem(trail)
    }
    
    /// Stops controller view, multiplayer, invalidate timer,
    func gameIsOver() {
        gameOver = true
        oppTimer.invalidate()
        controllerView.stop()
        multiplayer?.sendStatus(.Finish(time: raceResultManager.userTime()?.string() ?? ""))
        addFinalAnimation()
        controllerView.addFinishView()
        let _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (_) in
            DispatchQueue.main.async {
                let resultVC = GameResultVC(results: self.raceResultManager.getResults(opponents: self.currentPlayers.filter({$0.id != self.getID()})))
                self.navigation.goTo(resultVC)
            }

        }
    }
    
    /// user stopped the game. Go back to main screen.
    func stopped() {
        oppTimer.invalidate()
        multiplayerTimer.invalidate()
        sceneView.stop(nil)
        scene.isPaused = true
        multiplayer?.removeObservers()
        navigation.goTo(WelcomeVC())
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

extension GameViewController: SCNPhysicsContactDelegate {
   
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        contactStarted(world, contact)
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
        guard started == true else { return }
        let cameraPosition = getCameraPosition()
        selfieStickNode.position = cameraPosition
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
            guard !self.gameOver else {
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
                guard pl.id != self.getID() else { continue }
                let poo = self.currentPlayers.pooWithPl(pl)
                switch pl.status {
                case .Finish(let time):
                    poo.node.removeFromParentNode()
                    self.raceResultManager.didFinish(poo: poo, timeString: time)
                default:
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
