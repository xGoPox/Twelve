//
//  ProgressBar.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/11/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//


import Foundation
import SpriteKit

class ProgressBar : SKSpriteNode {
        
    let denomiator = 3.73 / 4 // 1 is to fill it up
    let total = 60.0

    
    var multiplicator = 1
    // ((1 / 4) * 0.8) every second we want to send 0.8 as value down
    
    var value : Double = 0.0 {
        willSet(newValue) {
            let scaleValue = denomiator * (newValue < 0 ? 0 : newValue)
            let scale = SKAction.scaleX(to: CGFloat(scaleValue), duration: TimeInterval(0.1))
            if color != colorType {
                let colorize = SKAction.colorize(with: colorType, colorBlendFactor: 1, duration: 1)
                let group = SKAction.group([scale, colorize])
                run(group)
            } else {
                run(scale)
            }
        }
    }
    
    var colorType: UIColor {
        get {
            switch value {
            case 0...1:
                return .myGreen
            case 1...2:
                return .myRed
            case 2...3:
                return .myYellow
            default:
                return .myBlue
            }
        }
    }

    func decrease() {
        let newValue = value - 0.025
        value = newValue >= 0 ? newValue : 0
    }
    
    typealias GiveBonus = Bool
    
    func increaseAndHasGivenBonus() -> GiveBonus {
        var newValue = value + 4
        var bonus = false
        if newValue >= 4 {
            newValue = 4
            bonus = true
        }
        value = newValue
        return bonus
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // To check it worked:
    
    }
 
    
}
