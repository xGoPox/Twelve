//
//  Number.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class NumberSpriteNode : Element {
    
    
    let numberLabel: SKLabelNode!
    
    override var value : Int {
        
        willSet(number) {
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            numberLabel.run(fadeOut) {
                self.numberLabel.text = String(number)
                self.numberLabel.run(fadeIn)
            }
        }
        didSet(number) {
            removeSolution()
            if value != number {
                unselected()
            }
        }
    }
    
    
    override init(gridPosition: GridPosition) {
        numberLabel = SKLabelNode(fontNamed:"Exo2-Medium")
        super.init(gridPosition: gridPosition)
        texture = nil
        numberLabel.fontSize = 55
        numberLabel.alpha = 0
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.verticalAlignmentMode = .center
        numberLabel.color = .clear
        numberLabel.isUserInteractionEnabled = false
        numberLabel.fontColor = .white
        numberLabel.zPosition = 2
        addChild(numberLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NumberSpriteNode {
    
    override func selected() {
        let pulseUp = SKAction.scale(to: 1.3, duration: 0.20)
        let pulseDown = SKAction.scale(to: 1, duration: 0.20)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let color = SKAction.colorize(with: colorType, colorBlendFactor: 1, duration: 0.1)
        let shape = SKSpriteNode.init(texture: SKTexture.init(imageNamed: "number"), color: colorType, size: self.size)
        shape.name = "shape"
        shape.isUserInteractionEnabled = false
        shape.zPosition = 1
        addChild(shape)
        shape.run(SKAction.sequence([color, SKAction.repeatForever(pulse)]))
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.1)
        numberLabel.run(fadeOut) {
            self.numberLabel.fontColor = .white
            self.numberLabel.run(fadeIn)
        }
    }
    
    override func unselected() {
        let color = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.1)
        let numberScaleBackAction = SKAction.scale(to: 1, duration: 0.15)
        if let shp = childNode(withName: "shape") {
            shp.run(numberScaleBackAction)
            numberLabel.run(fadeOut) {
                shp.run(color, completion: {
                    self.numberLabel.fontColor = self.colorType
                    self.numberLabel.run(fadeIn)
                    shp.removeFromParent()
                })
            }
        } else {
            self.numberLabel.fontColor = self.colorType
            self.numberLabel.run(fadeIn)
        }
    }
    
}




private func getColorFadeAction(startColor: UIColor, endColor: UIColor, duration: TimeInterval, stroke: Bool, fill: Bool) -> SKAction {
    // Create a custom action for color fade
    let action = SKAction.customAction(withDuration: duration) {(node, elapsedTime) in
        if let node = node as? SKShapeNode {
            var color = endColor
            // Calculate the changing color during the elapsed time.
            let fraction = elapsedTime / CGFloat(duration)
            if let startColorRGB = startColor.rgb(), let endColorRGB = endColor.rgb(){
                let red = CGFloat().lerp(start: startColorRGB.red, end: endColorRGB.red, t: fraction)
                let green = CGFloat().lerp(start: startColorRGB.green, end: endColorRGB.green, t: fraction)
                let blue = CGFloat().lerp(start: startColorRGB.blue, end: endColorRGB.blue, t: fraction)
                let alpha = CGFloat().lerp(start: startColorRGB.alpha, end: endColorRGB.alpha, t: fraction)
                
                color = UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
            }
            // Node properties to change.
            if stroke {
                node.strokeColor = color
            }
            if fill {
                node.fillColor = color
            }
        }
    }
    return action
}


