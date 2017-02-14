//
//  Multiplicator.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/11/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//


import Foundation
import SpriteKit

class Multiplicator : SKSpriteNode {
        
    let denomiator = 0.1785 // 1 is to fill it up
    let total = 60.0
    var twoSprite : SKSpriteNode?
    var threeSprite : SKSpriteNode?
    var fourSprite : SKSpriteNode?
    var valueLabel : SKLabelNode?
    
    var multiplicator: Int {
        get {
            switch value {
            case 0...4:
                return 1
            case 4...8:
                return 2
            default:
                return 3
            }
        }
    }
    // ((1 / 4) * 0.8) every second we want to send 0.8 as value down
    
    var value : Double = 0.0 {
        willSet(newValue) {
            switch newValue {
            case 0...4:
                if value > 4 {
                    let scaleEmpty = SKAction.scaleY(to: 0, duration: 0.1)
                    fourSprite?.run(scaleEmpty)
                    threeSprite?.run(scaleEmpty, completion: {
                        self.valueLabel?.text = "x1"
                    })
                }
                var scaleValue = 0.0
                if value > 4 {
                    scaleValue = denomiator * ((newValue - value) - (0 - value))
                }
                else {
                    scaleValue = denomiator * (newValue < 0 ? 0 : newValue)
                }
                let growScale = SKAction.scaleY(to: CGFloat(scaleValue), duration: TimeInterval(0.1))
                twoSprite?.run(growScale)
                
            case 4...8:
                if value < 4 {
                    let scaleFull = SKAction.scaleY(to: CGFloat(denomiator * 4), duration: TimeInterval(0.1))
                    twoSprite?.run(scaleFull, completion: {
                        self.valueLabel?.text = "x2"
                    })
                }
                else if value > 8 {
                    let scaleEmpty = SKAction.scaleY(to: 0, duration: 0.1)
                    fourSprite?.run(scaleEmpty, completion: {
                        self.valueLabel?.text = "x2"
                    })
                }
                var scaleValue = 0.0
                if value < 4 {
                    scaleValue = denomiator * ((newValue - value) - (4 - value))
                } else {
                    scaleValue = denomiator * (newValue - 4)
                }
                
                print("TUUUT : scaleValue \(scaleValue) new value : \(newValue) value : \(value)")

                let growScale = SKAction.scaleY(to: CGFloat(scaleValue), duration: TimeInterval(0.1))
                threeSprite?.run(growScale)
            default:
                if value < 8 {
                    let scaleFull = SKAction.scaleY(to: CGFloat(denomiator * 4.0), duration: TimeInterval(0.1))
                    threeSprite?.run(scaleFull, completion: {
                        self.valueLabel?.text = "x3"
                    })
                }
                var scaleValue = 0.0
                if value < 8 {
                    scaleValue = denomiator * ((newValue - value) - (8 - value))
                } else {
                    scaleValue = denomiator * (newValue - 8)
                }
                print("TUUUT : scaleValue \(newValue) \(value)")
                let growScale = SKAction.scaleY(to: CGFloat(scaleValue > denomiator * 4 ? denomiator * 4 : scaleValue), duration: TimeInterval(0.1))
                fourSprite?.run(growScale)
            }
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // To check it worked:
        
        
        guard let twoNode = childNode(withName: "multiplicatorTwo")
            as? SKSpriteNode else {
                fatalError("twoNode node not loaded")
        }
        
        guard let threeNode = childNode(withName: "multiplicatorThree")
            as? SKSpriteNode else {
                fatalError("threeNode node not loaded")
        }
        
        guard let fourNode = childNode(withName: "multiplicatorFour")
            as? SKSpriteNode else {
                fatalError("fourNode node not loaded")
        }
        
        
        guard let nodeLabel = childNode(withName: "multiplicatorValue")
            as? SKLabelNode else {
                fatalError("multiplicatorTwo node not loaded")
        }
        
        twoSprite = twoNode
        threeSprite = threeNode
        fourSprite = fourNode
        valueLabel = nodeLabel
        
    }
    
    
}
