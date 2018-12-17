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
    var ballNode:SCNNode!
    var selfieStickNode:SCNNode!
    var floor : SCNNode!
    var contactManager: ContactManager!
    /// length of track
    var length: Float = -250
    
    /// timer that triggers specific opponents actions (bonus usage)
    var oppTimer = Timer()
    
    /// timer that triggers update of the table result
    var tableTimer = Timer()
    
    // UI: Label ready/Go, bonus button
    var startLabel = UILabel()
    var bonusButton : BonusButton?

    /// started is true when game is playing, so balls are moved
    var started = false
    
    /// game is over when ballNode has completed the track
    var gameOver = false
    
    /// bool triggered at the right time at beginning so that camera moves nicely from the end to the beginning of the track
    var shouldMoveCamera = false
    
    /// startDate is saved when game start (calculate the timing off players when they finish the track -> totalTime = startDate - arrivalDate
    var startDate : Date?
    /// tableView showing the results in real time (updated every 0.3 sec)
    var resultTable: UITableView!
    
    /// array of nodes that finished the track
    var winners : [SCNNode] = []
    
    ///final results created when players finish the track and passed to GameResultVC for showing time and positions
    var finalResults: [Result] = []
    
    /// Array of currentPlayers, generally copied from global var players. Order SHOULD NOT change
    var currentPlayers = players
    //test
//    var currentPlayers = [Poo(name: PooName.IndianSurprise)]
    
    /// Array of current opponents
    var opponents:[Poo] = []

    
    /// Array of players, generally copied from global var players. It SHOULD CHANGE depending on players position
    var ranking = players
    //test
//    var ranking = [Poo(name: PooName.IndianSurprise)]

    
    /// Ydistance of camera from user poop
    var yTot : Float = 4.0
    
    /// Zdistance of camera from user poop
    var zTot : Float = 4.0
    
    /// Zdistance of camera from user poop
    var xTot : Float = 0

    /// if is bonus from slower activated
    var slowerActivated = false
    
    /// color of text in table result
    var cellTextColor = UIColor.black
    
    /// color of layer background of cell text if poop has bonus enabled
    var backgroundCellColor = UIColor.white
    
    /// specifies a special position at beginning for poos
    var position: SCNVector3?
    
    /// bool if it should rotate camera
    var shouldRotateCamera: Bool = true

    override func viewDidLoad() {
        sceneView = SCNView(frame: view.frame)
        view.addSubview(sceneView)
        prepare()
        contactManager = ContactManager(gameVC: self)
    }
    
    // MARK:- PREPARATION AND INITIAL COMMON METHODS
    
    func prepare() {
        self.setupScene()
        self.ballNode = (NodeCreator.createBall(postion: position))
        self.scene.rootNode.addChildNode(self.ballNode)
        self.addOpponents()
        self.setupFloor()
        self.setupTable()
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
            if currentPlayers[index].name != Data.shared.selectedPlayer.name {
                let oppNode = NodeCreator.createOpponent(index: index, postion: position)
                currentPlayers[index].reset()
                scene.rootNode.addChildNode(oppNode)
                opponents.append( currentPlayers[index])
                currentPlayers[index].node = oppNode
                oppNode.name = currentPlayers[index].name.rawValue
            } else {
                Data.shared.selectedPlayer.node = ballNode
                self.currentPlayers[index] = Data.shared.selectedPlayer
                self.currentPlayers[index].reset()
            }
        }
    }
    
    func newGame() {
        //time to stop waiting
        perform(#selector(moveCamera), with: nil, afterDelay: 1)
    }
    
    @objc func moveCamera() {
        Navigation.stopLoading()
        let cameraPosition = getCameraPosition()
        let action = SCNAction.move(to: cameraPosition, duration: 3)
        
        selfieStickNode.runAction(action) {
            self.prepareForStart()
        }
    }
    
    @objc func prepareForStart() {
        startLabel = UILabel(frame: CGRect(x: 300, y: 200, width: 400, height: 100))
        startLabel.font = UIFont.boldSystemFont(ofSize: 50)
        startLabel.text = "READY"
        startLabel.textColor = UIColor.red
        self.view.insertSubview(startLabel, at: 2)
        perform(#selector(start), with: nil, afterDelay: 1)
    }
    
    @objc func start() {
        shouldMoveCamera = true
        started = true
        scene.isPaused = false
        startDate = Date()
        startLabel.text = "GO!!!"
        startLabel.textColor = UIColor.green
        sceneView.isPlaying = true
        perform(#selector(removeLabel), with: nil, afterDelay: 1)
        perform(#selector(startOppTimer), with: nil, afterDelay: 1)
        startUpdateTimer()
        UIView.animate(withDuration: 0.3) {
            self.resultTable.alpha = 1
        }
        addBonusButton()
        addStopButton()
//        let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(blockAvoider), userInfo: nil, repeats: true)
    }
    
    @objc func removeLabel() {
        UIView.animate(withDuration: 1, animations: {
            self.startLabel.alpha = 0
        }) { (done) in
            self.startLabel.removeFromSuperview()
        }
    }
        
    @objc func startOppTimer() {
        oppTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(createRandomBonusOpponent), userInfo: nil, repeats: true)
    }
    
    @objc func startUpdateTimer() {
        tableTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updateTable), userInfo: nil, repeats: true)
    }
    
    @objc func updateTable() {
        ranking = currentPlayers.sorted { (obj1, obj2) -> Bool in
            return obj1.distance < obj2.distance
        }
        DispatchQueue.main.async {
            self.resultTable.reloadData()
        }
    }
    
    func addBonusButton() {
        guard let bonus = Data.shared.selectedPlayer.bonus() else { return }
        bonusButton = BonusButton(frame: CGRect(x: view.frame.width - 100, y: view.frame.height - 100, width: 64, height: 64))
        bonusButton?.initWithBonus(bonus: bonus)
        stopBonus()
        bonusButton?.addTarget(self, action: #selector(activateBonus), for: .touchUpInside)
        view.addSubview(bonusButton!)
    }
    
    func addStopButton() {
        let stopButton = UIButton(frame: CGRect(x: view.frame.width - 44, y: 8, width: 36, height: 36))
        stopButton.setTitle("⏹", for: .normal)
        stopButton.addTarget(self, action: #selector(stopped), for: .touchUpInside)
        stopButton.alpha = 0.3
        view.addSubview(stopButton)
    }
    
    @objc func createRandomBonusOpponent() {
        let random = Int(arc4random_uniform(UInt32(currentPlayers.count)))
        activateOpponentBonus(index: random)
    }
    
    @objc func stopped() {
        oppTimer.invalidate()
        Navigation.main.popToRootViewController(animated: true)
    }

    func setupFloor() {
        floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
        floor.physicsBody?.categoryBitMask = Collider.floor
        floor.physicsBody?.collisionBitMask = Collider.obstacle | Collider.ball
    }
    
    func setupTable() {
        resultTable = UITableView(frame: CGRect(x: 10, y: 10, width: 250, height: 400), style: .plain)
        resultTable.delegate = self
        resultTable.dataSource = self
        resultTable.backgroundColor = UIColor.clear
        resultTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        resultTable.separatorStyle = .none
        resultTable.rowHeight = 34
        resultTable.isUserInteractionEnabled = false
        resultTable.alpha = 0
        self.view.addSubview(resultTable)
    }
    
    @objc func gameIsOver() {
        oppTimer.invalidate()
        DispatchQueue.main.async {
            self.perform(#selector(self.showResults), with: nil, afterDelay: 2)
        }
    }
    
    @objc func showResults() {
        tableTimer.invalidate()
        if finalResults.count != currentPlayers.count {
            for opponent in opponents {
                if finalResults.contains(where: { $0.player.name.rawValue == opponent.name.rawValue}) {
                } else {
                    let distance = abs(length) + opponent.node!.presentation.position.z
                    var time = calculateTime(firstDate: startDate!)
                    time += distance/10
                    let timeToWinner : Float = {
                        if let winner = finalResults.first?.time {
                            return winner - time
                        }
                        return 0
                    }()
                    let total = (Data.shared.scores[opponent.name.rawValue] ?? 0)
                    let res = Result(player: Poo(name: PooName(rawValue: opponent.name.rawValue)!), time: time, timeToWinner: timeToWinner, points: 0, totalPoints: total)
                    finalResults.append(res)
                }
            }
        }
        let result = GameResultVC(results: finalResults)
        self.navigationController?.viewControllers = [result]
    }
    
    var location = CGPoint()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self.view)
        location = loc
        guard gameOver == false && started == true else { return }
        if loc.x > UIScreen.main.bounds.width/2 {
            //right
            let force = SCNVector3(Data.shared.selectedPlayer.turningForce(), 0, 0.01)
            ballNode.physicsBody?.applyForce(force, asImpulse: true)
            if shouldRotateCamera {
                let rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: 0.05, duration: 0.4)
                selfieStickNode.runAction(rotateAction) {
                    self.selfieStickNode.runAction(rotateAction.reversed())
                }
            }
        } else {
            //left
            let force = SCNVector3(-Data.shared.selectedPlayer.turningForce(), 0, 0.01)
            ballNode.physicsBody?.applyForce(force, asImpulse: true)
            if shouldRotateCamera {
                let rotateAction = SCNAction.rotateBy(x: 0, y: 0, z: -0.05, duration: 0.3)
                selfieStickNode.runAction(rotateAction) {
                    self.selfieStickNode.runAction(rotateAction.reversed())
                }
            }
        }
    }
    
    @objc func activateBonus() {
        // ENABLE POWER UP
        if let bonus = Data.shared.selectedPlayer.bonus() {
            guard Data.shared.selectedPlayer.canUseBonus == true else { return }
            Data.shared.selectedPlayer.bonusEnabled = true
            perform(#selector(stopBonus), with: nil, afterDelay: TimeInterval(bonus.duration()))
            showBonus(bonus: bonus, node: ballNode)
        }
    }
    
    func activateOpponentBonus(index: Int) {
        if let bonus = currentPlayers[index].bonus() {
            let bonusNode = currentPlayers[index].node
            guard bonusNode != ballNode else { return }
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
    
    @objc func stopBonus() {
        if let bonus = Data.shared.selectedPlayer.bonus() {
            Data.shared.selectedPlayer.bonusEnabled = false
            stopShowBonus(bonus: bonus, node: ballNode)
            bonusButton?.stopped()
            perform(#selector(rechargeBonus), with: nil, afterDelay: TimeInterval(bonus.rechargeDuration()))
        }
    }
    
    @objc func rechargeBonus() {
        bonusButton?.alpha = 0.6
        bonusButton?.ready()
    }
    
    @objc func rechargeOpponentBonus(sender: Timer) {
        guard let info = sender.userInfo as? [String: Int], let index = info["index"] else { return }
        currentPlayers[index].canUseBonus = true
    }
    
    func showBonus(bonus: Bonus, node: SCNNode) {
        let bonusTrail = SCNParticleSystem(named: "smoke", inDirectory: nil)
        node.addParticleSystem(bonusTrail!)
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
            node.runAction(SCNAction.move(to: SCNVector3(ballNode.presentation.position.x, ballNode.presentation.position.y, ballNode.presentation.position.z - 15), duration: 0.05))
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
            let ball = currentPlayers[n]
            let bonusOffset = calculateBonusOffset(ball: ball)
            if ball.node!.presentation.position.z < length + 50 && ball.canUseBonus == true {
                if ball.node == ballNode {
                    ball.canUseBonus = false
                    DispatchQueue.main.async {
                        self.bonusButton?.removeFromSuperview()
                    }
                } else {
                    ball.canUseBonus = false
                }
                currentPlayers[n] = ball
            }
            ball.node?.physicsBody?.applyForce(SCNVector3(0, 0, ball.velocity() + bonusOffset), asImpulse: true)
        }
    }
    
    func calculateBonusOffset(ball: Poo) -> Float {
        let offset : Float  = {
            if slowerActivated && ball.bonus() != .Slower && ball.bonus() != .Almighty {
                return 0.015
            } else { return 0 }
        }()
        guard ball.bonusEnabled else { return offset }
        if let bonus = ball.bonus() {
            if bonus == .Sprint {
                if ball.bonusEnabled {
                    return -0.07 + offset
                }
            }
        }
        return offset
    }
    
    func getCameraPosition() -> SCNVector3 {
        let ballPosition = ballNode.presentation.position
        let targetPosition = SCNVector3(x: ballPosition.x + xTot, y: ballPosition.y + yTot, z:ballPosition.z + zTot)
        var cameraPosition = selfieStickNode.position
        let camDamping:Float = 0.3
        let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
        let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
        let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping
        cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
        return cameraPosition
    }
    
    @objc func blockAvoider() {
        for opponent in currentPlayers {
            if opponent.name == .GuanoStar {
            opponent.turn(direction: getBestDirection(pos: opponent.node.presentation.position))
            }
        }
    }
    
    func getBestDirection(pos: SCNVector3) -> Direction {
        var rightList = [SCNHitTestResult]()
        var leftList = [SCNHitTestResult]()
        let straightList = scene.physicsWorld.rayTestWithSegment(from: pos, to: SCNVector3(pos.x, 0.5, pos.z - 5), options: nil)
        for ind in 1...10 {
            let x = 12/2 - Float(ind)/2
            let z = -Float(ind)/3
            let pointR = SCNVector3(pos.x + x, 0.5, pos.z + z)
            let pointL = SCNVector3(pos.x - x, 0.5, pos.z + z)
            rightList = rightList + scene.physicsWorld.rayTestWithSegment(from: pos, to: pointR, options: nil)
            leftList = leftList + scene.physicsWorld.rayTestWithSegment(from: pos, to: pointL, options: nil)
        }
        if straightList.count == 0 {
            return .straight
        }
        if leftList.count == rightList.count {
            if pos.x == 0 { return arc4random_uniform(2) == 1 ? .left : .right }
        }
        return leftList.count > rightList.count ? .right : .left
    }
    
   func shouldAvoidBlock(hitResult: PoopHitResult, opponent: Poo) {

    }
    
    func addFinalAnimation() {
        
    }
    
    
    func calculateTime(firstDate: Date) -> Float {
        return Float(Date().timeIntervalSince(firstDate))
    }
    
    @objc func checkFinish() {
        if !winners.contains(ballNode) {
            let time : Float =  (calculateTime(firstDate: startDate!) + 3)
            winners.append(ballNode)
            //            let total = Data.shared.scores[node.name!] ?? 0
            let total : Float = 0
            let result = Result(player: Poo(name: PooName(rawValue: ballNode.name!)!), time: time, timeToWinner: nil, points: 0, totalPoints: total)
            finalResults.append(result)
            gameOver = true
            gameIsOver()
        }
    }
    
    func jump(node: SCNNode) {
        // TO BE OVERRIDDEN
    }
    
    func handleFinish(ball: SCNNode) {
        if ball == ballNode {
            gameOver = true
            gameIsOver()
            addFinalAnimation()
            let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addFinishView), userInfo: nil, repeats: false)
        }
        didFinish(node: ball)
    }
    
    func didFinish(node: SCNNode) {
        if !winners.contains(node) {
            let time : Float =  calculateTime(firstDate: startDate!)
            winners.append(node)
            //            let total = Data.shared.scores[node.name!] ?? 0
            let total : Float = 0
            let timeToWinner : Float = {
                if let winner = finalResults.first?.time {
                    return winner - time
                }
                return 0
            }()
            let result = Result(player: Poo(name: PooName(rawValue: node.name!)!), time: time, timeToWinner: timeToWinner, points: 0, totalPoints: total)
            finalResults.append(result)
        }
    }
    
    @objc func addFinishView(_ sender: Timer) {
        DispatchQueue.main.async {
            let finishView = UIView(frame: self.view.frame)
            finishView.backgroundColor = UIColor.white
            finishView.alpha = 0
            self.view.addSubview(finishView)
            UIView.animate(withDuration: 0.5, animations: {
                finishView.alpha = 1
            }, completion: { (done) in
            })
        }
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
    }
}
    

extension GameViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ranking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.layer.cornerRadius = 10
        if finalResults.count > indexPath.row {
            cell.textLabel?.text = "\(indexPath.row + 1)) \(finalResults[indexPath.row].player.name.rawValue)"
            cell.imageView?.image = UIImage(color: finalResults[indexPath.row].player.color())
            
            let ball = finalResults[indexPath.row]
            if indexPath.row != 0 {
                cell.detailTextLabel?.text = "\((ball.timeToWinner ?? 0).string())"
                cell.detailTextLabel?.textColor = UIColor.red
            } else {
                cell.detailTextLabel?.text = "\(ball.time.string())"
                cell.detailTextLabel?.textColor = cellTextColor
            }
        } else {
            cell.textLabel?.text = " \(indexPath.row + 1)) \(ranking[indexPath.row].name.rawValue) "
            cell.imageView?.image = UIImage(color: ranking[indexPath.row].color())
            if ranking[indexPath.row].bonusEnabled == true {
                cell.textLabel?.layer.backgroundColor = backgroundCellColor.cgColor
            } else {
                cell.textLabel?.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        
        // common config
        cell.textLabel?.textColor = cellTextColor
        cell.backgroundColor = UIColor.clear
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 10
        if cell.textLabel?.text?.contains(Data.shared.selectedPlayer.name.rawValue) ?? false {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.contentView.alpha = 0.8
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.contentView.alpha = 0.4
        }
        return cell
    }
}

extension GameViewController: UITableViewDelegate {


}
