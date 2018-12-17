//
//  Poo.swift
//  TheRace
//
//  Created by Enrico Castelli on 05/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

var players : [Poo] = [Poo(name: .GuanoStar), Poo(name: .HoleRunner), Poo(name: .IndianSurprise), Poo(name: .BrownTornado), Poo(name: .GarganTurd), Poo(name: .FecalRaider), Poo(name: .ApolloPoo)]

enum PooName : String {
    
    case GuanoStar = "Guano Star"  // Soft Basic
    case HoleRunner = "Hole Runner" // Softclear
    case IndianSurprise = "Indian Surprise" // IndianSurprise
    case BrownTornado = "Brown Tornado" // BrownTornado
    case GarganTurd = "Garganturd" // GarganTurd
    case FecalRaider = "Fecal Raider" //  FecalRaider
    case ApolloPoo = "Apollo Poo" // Hard raisins
    // BEWARE OF THE ALMIGHTYYY POOOOPPPP
    case MightyPoop = "The Mighty Poop"
}

class Poo {
    
    var name: PooName
    var distance: Float {
        get {
            return node.presentation.position.z
        }
    }
    var node: SCNNode!
    var bonusEnabled = false
    var canUseBonus = true
    var direction: Direction = .straight
    var isMoving = false {
        didSet {
            if isMoving {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self.isMoving = false
                })
            }
        }
    }
    var actualTurning: CGFloat = 0
    
    init(name: PooName) {
        self.name = name
    }
    
    func turn(direction: Direction) {
        //        guard direction != self.direction else { return }
        guard let force = forcePerDirection(direction: direction) else { return }
        actualTurning -= force
        self.direction = direction
        self.node.physicsBody?.applyForce(SCNVector3(force, 0, 0), asImpulse: true)
    }
    
    func forcePerDirection(direction: Direction) -> CGFloat? {
        switch direction {
        case .straight:
            if self.direction == .straight { return actualTurning/10 }
            else { return actualTurning/5 }
        case .left:
            if self.direction == .left { return 0.2 }
            else if self.direction == .straight { return -1 }
            else { return -2 }
        case .right:
            if self.direction == .right { return 0.2 }
            else if self.direction == .straight { return 1 }
            else { return 2 }
        }
    }
    
    /// z speed. Renderer is applying this force at z.
    func velocity() -> Float {
        switch name {
        case .GuanoStar:
            return -0.037
        case .HoleRunner:
            return -0.039
        case .IndianSurprise:
            return -0.040
        case .BrownTornado:
            return -0.040
        case .GarganTurd:
            return -0.038
        case .FecalRaider:
            return -0.041
        case .ApolloPoo:
            return -0.041
        case .MightyPoop:
            return -0.050
        }
    }
    
    /// Radius of sphere.
    func radius() -> CGFloat {
        switch name {
        case .GuanoStar:
            return 0.33
        case .HoleRunner:
            return 0.27
        case .IndianSurprise:
            return 0.3
        case .BrownTornado:
            return 0.32
        case .GarganTurd:
            return 0.3
        case .FecalRaider:
            return 0.2
        case .ApolloPoo:
            return 0.28
        case .MightyPoop:
            return 0.45
        }
    }
    
    /// Restitution force when poop collide with obstacle.
    func restitution() -> CGFloat {
        switch name {
        case .GuanoStar:
            return 0.5
        case .HoleRunner:
            return 0.4
        case .IndianSurprise:
            return 0.1
        case .BrownTornado:
            return 0.4
        case .GarganTurd:
            return 0
        case .FecalRaider:
            return 0.3
        case .ApolloPoo:
            return 0.3
        case .MightyPoop:
            return 0
        }
    }
    
    /// When user taps, poop apply this force at x.
    func turningForce() -> CGFloat {
        switch name {
        case .GuanoStar:
            return 1
        case .HoleRunner:
            return 1
        case .IndianSurprise:
            return 1.2
        case .BrownTornado:
            return 1.3
        case .GarganTurd:
            return 0.8
        case .FecalRaider:
            return 1.1
        case .ApolloPoo:
            return 1.4
        case .MightyPoop:
            return 3
        }
    }
    
    /// Color shown in result table
    func color() -> UIColor {
        switch name {
        case .GuanoStar:
            return UIColor(red: 159/255, green: 127/255, blue: 91/155, alpha: 1)
        case .HoleRunner:
            return UIColor(red: 135/255, green: 132/255, blue: 69/155, alpha: 1)
        case .IndianSurprise:
            return UIColor(red: 206/255, green: 179/255, blue: 105/155, alpha: 1)
        case .BrownTornado:
            return UIColor(red: 51/255, green: 48/255, blue: 45/155, alpha: 1)
        case .GarganTurd:
            return UIColor(red: 130/255, green: 86/255, blue: 52/255, alpha: 1)
        case .FecalRaider:
            return UIColor(red: 121/255, green: 97/255, blue: 81/255, alpha: 1)
        case .ApolloPoo:
            return UIColor(red: 97/255, green: 70/255, blue: 47/255, alpha: 1)
        case .MightyPoop:
            return UIColor.white
        }
    }
    
    /// Bonus (optional) that poop can use.
    func bonus() -> Bonus? {
        switch name {
        case .GuanoStar:
            return .NoBonus
        case .HoleRunner:
            return .NoBonus
        case .IndianSurprise:
            return .Sprint
        case .BrownTornado:
            return .MiniPoo
        case .GarganTurd:
            return .Slower
        case .FecalRaider:
            return .Ghost
        case .ApolloPoo:
            return .Teleport
        case .MightyPoop:
            return .Almighty
        }
    }
    
    /// Method that create specific material for poop
    func createMaterial() -> SCNMaterial {
        switch name {
        case .GuanoStar:
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIImage(named: "puffBase")
            material.diffuse.intensity = 0.7
            material.ambientOcclusion.contents = UIImage(named: "puffOcc")
            material.normal.contents = UIImage(named: "puffNormal")
            material.specular.contents = UIImage(named: "puffSpec")
            material.roughness.contents = 0.8
            material.selfIllumination.contents = UIColor.brown
            material.displacement.contents = UIImage(named: "raisHei")
            material.displacement.intensity = 0.1
            return material
        case .HoleRunner:
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIImage(named: "nuggetBase")
            material.diffuse.intensity = 1
            material.roughness.contents = UIImage(named: "nuggetRough")
            material.normal.contents = UIImage(named: "nuggetNormal")
            material.transparent.contents = UIColor.black
            material.ambientOcclusion.contents = UIColor.brown
            material.selfIllumination.contents = UIColor.brown
            material.displacement.contents = UIImage(named: "raisHei")
            material.displacement.intensity = 0.1
            return material
        case .IndianSurprise:
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIImage(named: "bactBase")
            material.normal.contents = UIImage(named: "bactNormal")
            material.transparent.contents = UIColor.black
            material.ambientOcclusion.contents = UIImage(named: "bactOcc")
            material.specular.contents = UIImage(named: "bactSpec")
            material.selfIllumination.contents = UIColor.brown
            material.emission.contents = UIColor.brown
            material.emission.intensity = 1
            material.displacement.contents = UIImage(named: "bactDisp")
            material.displacement.intensity = 0.1
            return material
        case .BrownTornado:
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIImage(named: "brownBase")
            material.diffuse.intensity = 0.7
            material.transparent.contents = UIColor.black
            material.ambientOcclusion.contents = UIColor.brown
            material.selfIllumination.contents = UIColor.brown
            material.emission.contents = UIColor.black
            material.displacement.contents = UIImage(named: "cornHeight")
            material.displacement.intensity = 0.1
            return material
        case .GarganTurd:
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIColor(red: 130/255, green: 86/255, blue: 52/255, alpha: 1)
            material.ambientOcclusion.contents = UIImage(named: "cornAO")
            material.normal.contents = UIImage(named: "cornNorm")
            material.roughness.contents = UIImage(named: "cornRough")
            material.selfIllumination.contents = UIColor.white
            material.emission.contents = UIColor.black
            material.emission.intensity = 1
            material.displacement.contents = UIImage(named: "cornHeight")
            material.displacement.intensity = 0.35
            return material
        case .FecalRaider:
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIImage(named: "cornBase")
            material.ambientOcclusion.contents = UIImage(named: "absOcc")
            material.normal.contents = UIColor.white
            material.selfIllumination.contents = UIColor.white
            material.emission.contents = UIColor.black
            material.emission.intensity = 1
            material.displacement.contents = UIImage(named: "absDisp")
            material.displacement.intensity = 0.05
            return material
        case .ApolloPoo:
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIImage(named: "raisBase")
            material.diffuse.intensity = 0.5
            material.ambientOcclusion.contents = UIImage(named: "raisOcc")
            material.normal.contents = UIImage(named: "raisNormal")
            material.roughness.contents = UIImage(named: "raisSpec")
            material.selfIllumination.contents = UIColor.white
            material.displacement.contents = UIImage(named: "raisHei")
            material.displacement.intensity = 0.2
            return material
        case .MightyPoop:
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIColor.brown
            material.ambientOcclusion.contents = UIImage(named: "raisOcc")
            material.roughness.contents = UIImage(named: "nuggetNormal")
            material.selfIllumination.contents = UIColor.black
            material.displacement.contents = UIImage(named: "bactDisp")
            material.displacement.intensity = 0.2
            return material
        }
    }
    
    func reset() {
        canUseBonus = true
        bonusEnabled = false
        isMoving = false
    }
}

