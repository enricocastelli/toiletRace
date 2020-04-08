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
    var vsOpponentNode: SCNNode?
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
    
    /// bool returning if game is in multiplayer mode
    var isMultiplayer: Bool { return multiplayer != nil }
    
    /// array of nodes that finished the track
    var winners : [SCNNode] = []
    
    /// Array of currentPlayers, generally copied from global var players. Order SHOULD NOT change
    var currentPlayers = players
    //test
//    var currentPlayers = [Poo(name: PooName.IndianSurprise)]
    
    /// Array of current opponents
    var opponents:[Poo] = []
    
    // vsPoo
    var vsPoo: Poo?
    
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
    
    /// create scene, user's node, floor and add opponents
    func prepare() {
        self.setupScene()
        self.pooNode = (PooNodeCreator.createPoo(postion: position))
        multiplayer?.sendName(SessionData.shared.selectedPlayer.name)
        self.scene.rootNode.addChildNode(self.pooNode)
        self.addOpponents()
        self.addVSOpponent()
        self.setupFloor()
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
    }
    
    func setupFloor() {
        floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
        floor.physicsBody?.categoryBitMask = Collider.floor
        floor.physicsBody?.collisionBitMask = Collider.obstacle | Collider.poo
    }
    
    
    /// returns a specific scene based on world passed
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
    
    /// works only if multiplayer is OFF. For every currentPlayers, create poo and nodes
    func addOpponents() {
        guard !isMultiplayer else { return }
        for index in 0...currentPlayers.count - 1 {
            if currentPlayers[index].name != SessionData.shared.selectedPlayer.name {
                // opponent
                let oppNode = PooNodeCreator.createOpponent(index: index, postion: position)
                currentPlayers[index].reset()
                scene.rootNode.addChildNode(oppNode)
                opponents.append( currentPlayers[index])
                currentPlayers[index].node = oppNode
                oppNode.name = currentPlayers[index].name.rawValue
            } else {
                initUsersPoo(index)
            }
        }
    }
    
    /// works only if multiplayer is ON. creates a node for VS player and
    func addVSOpponent() {
        guard let vsPoo = vsPoo, vsOpponentNode == nil else { return }
        vsOpponentNode = PooNodeCreator.createVSOpponent(name: vsPoo.name, position: SCNVector3(1, 0, 0))
        scene.rootNode.addChildNode(vsOpponentNode!)
        vsPoo.node = vsOpponentNode
        vsOpponentNode?.name = vsPoo.name.rawValue
        initUsersPoo(nil)
        currentPlayers = [vsPoo, SessionData.shared.selectedPlayer]
    }
    
    // init user's poo. Connects the node to the poo and saves it in local session data. Also resets it (for some reason 🧐)
    func initUsersPoo(_ index: Int?) {
        SessionData.shared.selectedPlayer.node = pooNode
        SessionData.shared.selectedPlayer.reset()
        guard let index = index, !isMultiplayer else { return }
        self.currentPlayers[index] = SessionData.shared.selectedPlayer
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
    
    /// actual moment when game starts (physics, camera ecc...)
    @objc func start() {
        if isMultiplayer {
            multiplayer?.sendReady()
        } else {
            shouldMoveCamera = true
            started = true
            scene.isPaused = false
            sceneView.isPlaying = true
            controllerView.start()
            raceResultManager.start()
            perform(#selector(startOppTimer), with: nil, afterDelay: 1)
        }
    }
    
    /// Adapt timing to the other player (can have different start time otherwise)
    func prepareMultiplayer() {
        guard let startDate = multiplayer?.connectionDate else { return }
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .second, value: 15, to: startDate)
        if let time = date?.timeIntervalSince(Date()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                self.startMultiplayer()
            })
        }
    }
    
    /// actual moment when game starts for Multiplayer (physics, camera ecc...)
    @objc func startMultiplayer() {
        ranking = currentPlayers
        guard vsOpponentNode != nil else { return }
        shouldMoveCamera = true
        started = true
        scene.isPaused = false
        sceneView.isPlaying = true
        controllerView.start()
        raceResultManager.start()
    }
    
    // MARK:- BONUS RELATED STUFF
    
    /// Timer to activate bonus for a random opponent, for simulation
    @objc func startOppTimer() {
        guard !isMultiplayer else { return }
        oppTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            let random = Int(arc4random_uniform(UInt32(self.currentPlayers.count)))
            self.activateOpponentBonus(index: random)
        })
    }
    
    /// activate bonus opponent (if there's any)
    func activateOpponentBonus(index: Int) {
        guard let bonus = currentPlayers[index].bonus() else { return }
        let bonusNode = currentPlayers[index].node
        let bonusPoo = currentPlayers[index]
        // check if it's really opponent and if can use bonus at the moment
        guard bonusNode != pooNode, bonusPoo.canUseBonus == true && bonusPoo.bonusEnabled == false else { return }
        currentPlayers[index].bonusEnabled = true
        let _ = Timer.scheduledTimer(timeInterval: TimeInterval(bonus.duration()), target: self, selector: #selector(stopOpponentBonus(sender:)), userInfo: ["index": index], repeats: false)
        showBonus(bonus: bonus, node: bonusNode!)
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
    
    
    /// display a bonus behaviour for a specific node
    func showBonus(bonus: Bonus, node: SCNNode) {
        if let bonusTrail = SCNParticleSystem(named: "smoke", inDirectory: nil) {
            bonusTrail.loops = true
            node.addParticleSystem(bonusTrail)
        }
        switch bonus {
        case .NoBonus:
            break
        case .Sprint:
            SessionData.shared.selectedPlayer.bonusEnabled = true
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
    
    /// stop the displaying of a bonus behaviour for a specific node
    func stopShowBonus(bonus: Bonus, node: SCNNode) {
        node.removeAllParticleSystems()
        node.opacity = 1
        switch bonus {
        case .NoBonus:
            break
        case .Sprint:
            SessionData.shared.selectedPlayer.bonusEnabled = false
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
    
    // MARK:- MOVING POOPS, CAMERA AND TURNING
    
    /// called from controllerView, user tapped the screen
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
    
    /// in a for loop, a force is applied on every poo based on it's speed (also with bonus)
    func movePoops() {
        let playersCount = isMultiplayer ? 3 : currentPlayers.count - 1
        for n in 0...playersCount {
            let poo = currentPlayers[n]
            print(n, poo.displayName)
            let bonusOffset = calculateBonusOffset(poo)
            guard let node = poo.node, node != vsOpponentNode else { return }
            checkIfBonusShouldDisabled(poo, node, n)
            node.physicsBody?.applyForce(SCNVector3(0, 0, poo.velocity() + bonusOffset), asImpulse: true)
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
        guard !isMultiplayer else { return }
        for opponent in opponents {
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
            switch StorageManager.retrieveLevel() {
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
        // TO BE OVERRIDDEN
    }
    
    // MARK:- END OF RACE
    
    /// game is finished for a specific poo: if poo is user, tells multiplayer and prepares finale
    func handleFinish(_ poo: SCNNode) {
        didFinish(node: poo)
        if poo == pooNode {
            gameOver = true
            multiplayer?.sendFinish()
            gameIsOver()
            addFinalAnimation()
            let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addFinishView), userInfo: nil, repeats: false)
        }
    }
    
    /// called by every poo when finish race. update winners array, raceResultManager (BUGGY) and multiplayer
    func didFinish(node: SCNNode) {
        if !winners.contains(node) {
            winners.append(node)
            if !isMultiplayer {
                raceResultManager.didFinish(poo: PooName(rawValue: node.name!)!, penalty: false)
            } else {
                guard node != pooNode else {return }
                raceResultManager.didFinishMultiplayer(poo: vsPoo!, gameOver: false)
            }
        }
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
        if !isMultiplayer {
            raceResultManager.getResults(opponents: opponents, length: length)
        } else {
            raceResultManager.didFinishMultiplayer(poo: SessionData.shared.selectedPlayer, gameOver: true)
        }
        multiplayer?.stop()
    }
    
    /// user stopped the game. Go back to main screen.
    func stopped() {
        oppTimer.invalidate()
        controllerView.stop()
        multiplayer?.stop()
        Navigation.main.popToRootViewController(animated: true)
    }
    
    /// final animation when race is finished. Of cours vary depends on the race.
    func addFinalAnimation() {
        // TO BE OVERRIDDEN
    }
    
    /// tells the controller to add the finish view on top (white screen with opacity animation)
    @objc func addFinishView(_ sender: Timer) {
        controllerView.addFinishView()
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
   
    /// the other player is ready
    func didReceiveStart() {
        prepareMultiplayer()
    }
    
    /// the other player finished
    func didReceiveEnd() {
        handleFinish(vsOpponentNode!)
    }
    
    /// send position of user's poo
    func sendMultiplayerData() {
        let pooPosition = pooNode.presentation.position
        multiplayer?.sendPosition(x: pooPosition.x, y: pooPosition.y, z: pooPosition.z)
    }
    
    /// received position of VSopponent poo and moves it
    func didReceivePosition(pos: PlayerPosition) {
        vsOpponentNode?.position = SCNVector3(pos.xPos, pos.yPos, pos.zPos)
    }
    
    /// display the poo name of VS and create the vsPoo object and node
    func didReceivePooName(_ name: PooName, displayName: String) {
        vsPoo = Poo(name: name)
        vsPoo?.displayName = displayName
        opponents.append(vsPoo!)
        if scene != nil && vsOpponentNode == nil {
            addVSOpponent()
        }
    }
}
