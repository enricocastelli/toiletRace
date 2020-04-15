

import SceneKit
import UIKit

protocol NodeCreator {}

extension NodeCreator {
    
    func setBaseRandomNum(_ num: Int?) {
        if let num = num {
            Matrix.baseNum = num
        } else {
            Matrix.baseNum = Int(arc4random_uniform(99))
        }
    }
    
    func createBound(zed: Float) -> [SCNNode] {
        let geoOb = SCNBox(width: 1, height: CGFloat((zed - 1)*2), length: 5, chamferRadius: 0)
        geoOb.materials.first?.lightingModel = .physicallyBased
        geoOb.materials.first?.diffuse.contents = UIImage(named: "cement")
        geoOb.materials.first?.selfIllumination.contents = UIColor.white
        geoOb.materials.first?.emission.contents = UIColor.black
        geoOb.materials.first?.multiply.contents = UIColor.brown.withAlphaComponent(0.3)
        let leftNode = SCNNode(geometry: geoOb)
        leftNode.position = SCNVector3(x: -8, y: 0, z: 0)
        leftNode.opacity = 1
        leftNode.rotation = SCNVector4(x: 1, y: Float.pi/2, z: 0, w: 0)
        leftNode.pivot = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        leftNode.physicsBody = SCNPhysicsBody.kinematic()
        leftNode.physicsBody!.categoryBitMask = Collider.bounds
        leftNode.physicsBody?.restitution = 0.2
        leftNode.name = "bound"
        let rightNode = SCNNode(geometry: geoOb)
        rightNode.position = SCNVector3(x: 8, y: 0, z: 0)
        rightNode.opacity = 1
        rightNode.rotation = SCNVector4(x: 1, y: Float.pi/2, z: 0, w: 0)
        rightNode.pivot = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        rightNode.physicsBody = SCNPhysicsBody.kinematic()
        rightNode.physicsBody?.categoryBitMask = Collider.bounds
        rightNode.physicsBody?.restitution = 0.2
        rightNode.name = "bound"
        return [leftNode, rightNode,createCylinder(zed: -140, radius: 0.4), createCylinder(zed: -18, radius:  0.2)]
    }
    
    private func createCylinder(zed: Float, radius: CGFloat) -> SCNNode {
        let geoOb = SCNCylinder(radius: radius, height: 40)
        geoOb.materials.first?.lightingModel = .physicallyBased
        geoOb.materials.first?.diffuse.contents = UIColor.gray
        geoOb.materials.first?.metalness.contents = 1
        geoOb.materials.first?.metalness.intensity = 2
        geoOb.materials.first?.selfIllumination.contents = UIColor.black
        geoOb.materials.first?.emission.contents = UIColor.black
        let tubeNode = SCNNode(geometry: geoOb)
        tubeNode.position = SCNVector3(x: 0, y: 2, z: zed)
        tubeNode.eulerAngles = SCNVector3(x: Float.pi/2, y: Float.pi/2, z: 0)
        tubeNode.physicsBody = SCNPhysicsBody.static()
        tubeNode.physicsBody?.restitution = -1
        tubeNode.name = "tube"
        return tubeNode
    }
    
    //MARK:- obstacle
    
    func createPee(zed: Float) -> SCNNode {
        let pee = SCNCylinder(radius: 2, height: 0)
        pee.materials.first?.lightingModel = .physicallyBased
        pee.materials.first?.diffuse.contents = UIImage(named: "peeBase")
        pee.materials.first?.normal.contents = UIImage(named: "peeNormal")
        pee.materials.first?.transparent.contents = UIColor.white
        pee.materials.first?.ambientOcclusion.contents = UIImage(named: "peeOcc")
        pee.materials.first?.selfIllumination.contents = UIColor.init(red: 246/255, green: 236/255, blue: 114/255, alpha: 1)
        pee.materials.first?.emission.contents = UIColor.black
        let peeNode = SCNNode(geometry: pee)
        peeNode.position = SCNVector3(0, -0.6, zed)
        peeNode.opacity = 0.3
        return peeNode
    }

    func createSponge(zed : Float) -> SCNNode {
        let geo = SCNBox(width: 3.5, height: 1.7, length: 2.6, chamferRadius: 4)
        geo.materials.first?.lightingModel = .physicallyBased
        geo.materials.first?.diffuse.contents = UIImage(named: "foamBase")
        geo.materials.first?.normal.contents = UIImage(named: "foamNormal")
        geo.materials.first?.roughness.contents = UIImage(named: "foamRough")
        geo.materials.first?.transparent.contents = UIColor.white
        geo.materials.first?.ambientOcclusion.contents = UIImage(named: "foamOcc")
        geo.materials.first?.selfIllumination.contents = UIColor.white
        geo.materials.first?.emission.contents = UIColor.black
        geo.materials.first?.displacement.contents = UIImage(named: "foamDisp")
        geo.materials.first?.displacement.intensity = 0.1
        let randomX = 4 - Matrix.random(Matrix.positions)
        let randomCol = Int(arc4random_uniform(2))
        let colorArray = [UIColor.yellow.withAlphaComponent(0.3), UIColor.cyan.withAlphaComponent(0.3), UIColor.white]
        let col = colorArray[randomCol]
        geo.materials.first?.multiply.contents = col
        let spongeNode = SCNNode(geometry: geo)
        spongeNode.position = SCNVector3(randomX, -0.5, Float(zed))
        spongeNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        spongeNode.physicsBody?.contactTestBitMask = Collider.obstacle
        spongeNode.physicsBody?.categoryBitMask = Collider.obstacle
        spongeNode.physicsBody?.restitution = 2
        spongeNode.name = "sponge"
        return spongeNode
    }
    
    func createPaper(zed : Float) -> SCNNode {
        let paperScene = SCNScene(named: "art.scnassets/Nodes/ToiletPaper.scn")
        let paperNode = paperScene!.rootNode.childNodes.first!
        let randomX = 6.5 - Matrix.random(Matrix.positions)
        paperNode.position = SCNVector3(randomX, 0, Float(zed))
        paperNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        paperNode.physicsBody?.categoryBitMask = Collider.obstacle
        // i want to put more papers at limit
        if  Matrix.maxArray[Matrix.index] {
            let xPos: Float = Matrix.minArray[Matrix.index] ? -6.5 : 6.5
            paperNode.position = SCNVector3(xPos, 0, Float(zed))
        }
        paperNode.name = "paper"
        return paperNode
    }
    
    func createPill(safeEnd: Float) -> SCNNode {
        let randomZ = Matrix.random(Matrix.superSafe)
        let zedRandPill = safeEnd - randomZ
        let zed = 0 - zedRandPill
        let pillScene = SCNScene(named: "art.scnassets/Nodes/pill.scn")
        let pillNode = pillScene!.rootNode.childNodes.first!
        pillNode.position = SCNVector3(0, 0.5, Float(zed))
        pillNode.eulerAngles = SCNVector3(x: Float.pi/2, y: 0, z: 0)
        pillNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        pillNode.physicsBody?.mass = 6
        pillNode.physicsBody?.contactTestBitMask = Collider.obstacle
        pillNode.physicsBody?.categoryBitMask = Collider.obstacle
        pillNode.name = "pill"
        pillNode.moveForever()
        return pillNode
    }
    
    func createTunnel(safeEnd: Float) -> SCNNode {
        let randomZ = Matrix.random(Matrix.superSafe)
        let zedRand = safeEnd - randomZ
        let zed = 0 - zedRand
        let geoTunnel = SCNTube(innerRadius: 1.2, outerRadius: 1.3, height: 8)
        geoTunnel.materials.first?.diffuse.contents = UIColor.init(red: 185/255, green: 140/255, blue: 61/255, alpha: 1)
        geoTunnel.materials.first?.roughness.contents = 0.4
        geoTunnel.materials.first?.metalness.contents = 0
        geoTunnel.materials.first?.normal.contents = UIImage(named: "peeNorm")
        let tunnelNode = SCNNode(geometry: geoTunnel)
        tunnelNode.name = "bath"
        tunnelNode.eulerAngles = SCNVector3(x: Float.pi/2, y: 0, z: 0)
        let tunnelX : Float = 0
        tunnelNode.position = SCNVector3(tunnelX, 0.2, Float(zed))
        let shape = SCNPhysicsShape(geometry: geoTunnel,
                                    options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        tunnelNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        tunnelNode.physicsBody?.categoryBitMask = Collider.bounds
        let geoOB = SCNBox(width: (CGFloat(Matrix.boundsLength/2) - geoTunnel.outerRadius), height: 5, length: 2, chamferRadius: 1)
        geoOB.materials.first?.diffuse.contents = UIImage(named: "bath1")
        geoOB.materials.first?.roughness.contents = 1
        geoOB.materials.first?.roughness.intensity = 0
        geoOB.materials.first?.metalness.contents = 0.5
        geoOB.materials.first?.metalness.intensity = 0.5
        geoOB.materials.first?.selfIllumination.contents = UIColor.white
        geoOB.materials.first?.emission.contents = UIColor.black
        let boxNode = SCNNode(geometry: geoOB)
        boxNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        boxNode.physicsBody?.categoryBitMask = Collider.bounds
        boxNode.position = SCNVector3(-(geoOB.width/2) - geoTunnel.outerRadius, 0.0, CGFloat(zed + 4))
        let geoOB2 = geoOB.copy() as! SCNBox
        geoOB2.width = (CGFloat(Matrix.boundsLength/2) - geoTunnel.outerRadius)
        let boxNode2 = SCNNode(geometry: geoOB2)
        boxNode2.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        boxNode2.physicsBody?.categoryBitMask = Collider.bounds
        boxNode2.position = SCNVector3((geoOB.width/2) + geoTunnel.outerRadius, 0.0, CGFloat(zed + 4))
        boxNode.name = "bath"
        boxNode2.name = "bath"
        
        let geoPlane = SCNPlane(width: 12, height: 17)
        geoPlane.materials.first?.diffuse.contents = UIColor.clear
        let planeNode = SCNNode(geometry: geoPlane)
        planeNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        planeNode.physicsBody?.contactTestBitMask = Collider.obstacle
        planeNode.physicsBody?.categoryBitMask = Collider.obstacle
        planeNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
        planeNode.position = SCNVector3(0, -0.5, Float(zed + 2))
        planeNode.name = "bath"
        let node = SCNNode()
        node.addChildNode(boxNode)
        node.addChildNode(boxNode2)
        node.addChildNode(tunnelNode)
        node.addChildNode(planeNode)
        node.name = "bath"
        return node
    }
    
    func createCarpet(zed: Float) -> SCNNode {
        let plane =  SCNBox(width: 16, height: 1.5, length: 5, chamferRadius: 20)
        plane.materials.first?.lightingModel = .physicallyBased
        plane.materials.first?.diffuse.contents = UIImage(named: "carpetBase")
        plane.materials.first?.ambientOcclusion.contents = UIImage(named: "carpetAO")
        plane.materials.first?.normal.contents = UIImage(named: "carpetNormal")
        plane.materials.first?.roughness.contents = UIImage(named: "carpetRough")
        plane.materials.first?.emission.contents = UIColor.black
        let carpetNode = SCNNode(geometry: plane)
        carpetNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        carpetNode.physicsBody?.categoryBitMask = Collider.bounds
        carpetNode.physicsBody?.friction = 0
        carpetNode.physicsBody?.rollingFriction = 0
        carpetNode.position = SCNVector3(0, -0.5, zed + 10)
        carpetNode.name = "carpet"
        return carpetNode
    }
    
    func createFinish(zed: Float) -> SCNNode {
        let geoOb = SCNBox(width: 4, height: 2, length: 4, chamferRadius: 0)
        geoOb.materials.first?.diffuse.contents = UIColor.clear
        let roadNode = SCNNode(geometry: geoOb)
        roadNode.position = SCNVector3(x: 0, y: 3, z: zed + 1)
        roadNode.opacity = 1
        roadNode.eulerAngles = SCNVector3(x: Float(-Float.pi/4), y: Float(Float.pi/2)*1, z: Float(-Float.pi/4))
        roadNode.physicsBody = SCNPhysicsBody.kinematic()
        roadNode.physicsBody?.categoryBitMask = Collider.bounds
        roadNode.name = "finish"
        return roadNode
    }

}

fileprivate enum Matrix {
    
    static let positions: [Float] = [1.5, 3.5, 4.5, 6.5, 4.0, 6.5, 6.0, 5.5, 4.0, 0.0, 1.5, 3.5, 0.5, 0.0, 6.5, 1.0, 2.5, 0.0, 2.0, 0.0, 3.5, 6.0, 3.5, 0.0, 7.0, 1.0, 5.0, 7.5, 5.5, 3.5, 7.0, 3.0, 5.0, 6.0, 2.5, 2.0, 5.5, 3.5, 4.0, 2.0, 5.0, 2.0, 2.0, 6.5, 0.0, 6.0, 3.0, 5.0, 0.0, 1.0, 7.0, 3.0, 4.5, 7.5, 0.5, 0.0, 4.0, 1.5, 5.5, 4.5, 4.5, 2.0, 5.0, 7.5, 2.0, 5.0, 5.0, 3.0, 3.0, 4.5, 3.5, 0.0, 3.0, 7.5, 6.0, 4.5, 7.5, 0.0, 6.5, 1.5, 0.5, 7.5, 0.5, 3.0, 4.5]
    static let superSafe: [Float] = [135.0, 156.0, 114.0, 14.0, 200.0, 232.0, 216.0, 233.0, 22.0, 166.0, 318.0, 68.0, 16.0, 203.0, 310.0, 317.0, 58.0, 316.0, 75.0, 274.0, 103.0, 107.0, 54.0, 34.0, 205.0, 87.0, 256.0, 246.0, 301.0, 247.0, 304.0, 185.0, 221.0, 223.0, 30.0, 129.0, 48.0, 102.0, 11.0, 174.0, 99.0, 313.0, 272.0, 43.0, 127.0, 26.0, 181.0, 38.0, 313.0, 136.0, 7.0, 239.0, 123.0, 9.0, 55.0, 315.0, 307.0, 40.0, 218.0, 52.0, 148.0]
    static let maxArray: [Bool] = [false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, true, false, false, false, false, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, true, true, false, false, false, true, false, false]
    static let minArray: [Bool] = [false, true, true, true, true, true, true, false, true, false, true, true, true, false, false, false, false, true, false, true, true, false, false, true, true, false, true, false, true, false, false, true, true, true, false, true, true, false, false, false, false, false, false, true, true, false, false, true, false, false, true, false, true, true, false, false, true, true, false, false, true, true, true, true, false, false, true, false, true, false, false, true, false, true, true, true, false, true, false, false, false, true, false, true, true, false, true, false, true, false, true]
    static var index: Int!
    static var boundsLength : Float = 15
    static var baseNum = 5
    
    static func random(_ from: [Float]) -> Float {
        if index == nil {
            index = baseNum
        }
        index += 1
        if index >= from.count {
            index = 0
        }
        return from[index]*1.5
    }
}

