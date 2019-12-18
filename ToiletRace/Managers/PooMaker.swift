//
//  PooMaker.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 20/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit


struct FoodItem {
    var name: String
    var colorR: Float
    var colorG: Float
    var colorB: Float
    var size: Float // from 0 to 1
    var liquidity: Float // from 0 to 1
    var displacement: Float // from 0 to 1
    var mass: Float // from 0 to 1
}


struct BolusItem {
    var colorR: Float
    var colorG: Float
    var colorB: Float
    var radius: Float
    var restitution: Float
    var displacement: Float
    var mass: Float
}


class PooMaker {
    
    static let items : [FoodItem] = [FoodItem(name: "apple", colorR: 0, colorG: 230, colorB: 0, size: 0.2, liquidity: 0.2, displacement: -0.1, mass: 0),
                              FoodItem(name: "banana", colorR: 255, colorG: 255, colorB: 0, size: 0.1, liquidity: 0.1, displacement: -0.1, mass: 0),
                              FoodItem(name: "coco", colorR: 153, colorG: 102, colorB: 51, size: 0, liquidity: 0.5, displacement: -0.4, mass: -0.1),
                              FoodItem(name: "orange", colorR: 255, colorG: 153, colorB: 0, size: 0, liquidity: 0, displacement: -0.1, mass: 0),
                              FoodItem(name: "kiwi",  colorR: 0, colorG: 255, colorB: 0, size: 0.1, liquidity: -0.4, displacement: 0.4, mass: 0.1),
                              FoodItem(name: "avocado", colorR: 204, colorG: 255, colorB: 153, size: 0.1, liquidity: 0.4, displacement: -0.3, mass: 0.1),
                              FoodItem(name: "carrot", colorR: 255, colorG: 153, colorB: 0, size: 0.1, liquidity: -0.2, displacement: 0.2, mass: 0),
                              FoodItem(name: "cheese", colorR: 255, colorG: 255, colorB: 200, size: 0, liquidity: 0.4, displacement: -0.3, mass: -0.1),
                              FoodItem(name: "pepper", colorR: 255, colorG: 0, colorB: 0, size: 0.1, liquidity: -0.3, displacement: 0, mass: 0),
                              FoodItem(name: "croissant", colorR: 204, colorG: 153, colorB: 0, size: 0.2, liquidity: 0.2, displacement: -0.05, mass: 0.1),
                              FoodItem(name: "bread", colorR: 255, colorG: 204, colorB: 0, size: 0.3, liquidity: -0.2, displacement: 0.05, mass: 0.1),
                              ]
    
    static func createBolus(_ items: [FoodItem]) -> BolusItem {
        var bolus = BolusItem(colorR: 0.60, colorG: 0.40, colorB: 0.59, radius: 0.1, restitution: 0, displacement: 0, mass: 2)
        for item in items {
            if abs(bolus.restitution) <= 1 {
                bolus.restitution -= item.liquidity
            }
            if bolus.radius <= 0.5 {
                bolus.radius += item.size/2
            }
//            if bolus.displacement <= 0.05 {
//                bolus.displacement += item.displacement
//            }
            bolus.mass += item.mass
            bolus.colorR += item.colorR/1000
            bolus.colorG += item.colorG/1000
            bolus.colorB += item.colorB/1000
        }
        return bolus
    }
}

