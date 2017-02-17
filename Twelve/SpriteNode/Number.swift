//
//  Number.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class NumberSpriteNode : SKSpriteNode {
    
    
    typealias GridPosition = (row: Int , column: Int )
    typealias joker = Int
    
    var gridPosition: GridPosition
    
    let numberLabel: SKLabelNode!
    
    let shape: SKShapeNode!
    
    let isJoker: joker = -1
    
    var followingNumber: Int?
    
    var frozen: Bool = false {
        willSet(value) {
            if value {
                freeze()
            } else {
                unfreeze()
            }
        }
    }
    var value : Int = -1 {
        willSet(number) {
            if number != isJoker {
                if value == isJoker {
                    let textureFadeOutAction = SKAction.fadeAlpha(by: 0, duration: 0.1)
                    run(textureFadeOutAction, completion: {
                        self.texture = self.textureType
                    })
                }
                let fadeIn = SKAction.fadeIn(withDuration: 0.1)
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                numberLabel.run(fadeOut) {
                    self.numberLabel.text = String(number)
                    self.numberLabel.run(fadeIn)
                }
            } else {
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                let textureFadeOutAction = SKAction.fadeAlpha(by: 1, duration: 0.1)
                run(textureFadeOutAction)
                numberLabel.run(fadeOut)
            }
        }
        didSet(number) {
            
            self.texture = self.textureType
            let textureFadeOutAction = SKAction.fadeAlpha(by: 1, duration: 0.1)
            run(textureFadeOutAction)
            
            removeSolution()
            if value != number {
                if frozen {
                    freeze()
                } else {
                    unselected()
                }
            }
        }
    }
    
    var textureType : SKTexture? {
        get {
            switch value {
            case isJoker:
                return SKTexture(imageNamed: "joker")
            default:
                return nil
            }
        }
    }
    
    
    var colorType: UIColor {
        get {
            switch value {
            case 1...3:
                return .myGreen
            case 4...6:
                return .myRed
            case 7...9:
                return .myYellow
            case 10...12:
                return .myBlue
            default:
                return .myRandomColor
            }
        }
    }
    
    
    func showSolution() {
        let pulseUp = SKAction.scale(to: 1.4, duration: 0.25)
        let pulseDown = SKAction.scale(to: 0.8, duration: 0.25)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        let delay = SKAction.wait(forDuration: 2)
        let finalSequece = SKAction.sequence([delay, repeatPulse])
        run(finalSequece , withKey: "solution")
    }
    
    func removeSolution() {
        if (action(forKey: "solution") != nil) {
            let pulseUp = SKAction.scale(to: 1, duration: 0.1)
            run(pulseUp)
            removeAction(forKey: "solution")
        }
    }
    
    func selected() {
        if value == isJoker {
            let pulseUp = SKAction.scale(to: 1.3, duration: 0.20)
            let pulseDown = SKAction.scale(to: 1, duration: 0.20)
            let pulse = SKAction.sequence([pulseUp, pulseDown])
            let repeatAction = SKAction.repeatForever(pulse)
            run(repeatAction, withKey: "selected")
        } else if !frozen && value != isJoker  {
            let pulseUp = SKAction.scale(to: 1.3, duration: 0.20)
            let pulseDown = SKAction.scale(to: 1, duration: 0.20)
            let pulse = SKAction.sequence([pulseUp, pulseDown])
            let color = getColorFadeAction(startColor: .white, endColor: colorType, duration: 0.1, stroke: true, fill: true)
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            
            let repeatAction = SKAction.repeatForever(pulse)
            shape.run(SKAction.sequence([color, repeatAction]), withKey: "selected")
            
            numberLabel.run(fadeOut) {
                self.numberLabel.fontColor = .white
                self.numberLabel.run(fadeIn)
            }
        }
    }
    
    func unselected() {
        if value == isJoker {
            let numberScaleBackAction = SKAction.scale(to: 1, duration: 0.15)
            run(numberScaleBackAction)
            removeAction(forKey: "selected")
        }
        else if !frozen {
            let color = getColorFadeAction(startColor: colorType, endColor: .white, duration: 0.1, stroke: true, fill: true)
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let numberScaleBackAction = SKAction.scale(to: 1, duration: 0.15)
            shape.run(numberScaleBackAction)
            numberLabel.run(fadeOut) {
                self.shape.run(color, completion: {
                    self.shape.fillColor = .clear
                    self.shape.strokeColor = .clear
                    self.numberLabel.fontColor = self.colorType
                    self.numberLabel.run(fadeIn)
                })
            }
            shape.removeAction(forKey: "selected")
        }
    }
    
    func freeze() {
        let color = getColorFadeAction(startColor: shape.fillColor, endColor:colorType , duration: 0.5, stroke: true, fill: true)
        shape.run(color) {
            self.numberLabel.fontColor = .white
        }
    }
    
    func unfreeze() {
        let color = getColorFadeAction(startColor: colorType, endColor: .white , duration: 0.5, stroke: true, fill: true)
        shape.run(color) {
            self.numberLabel.fontColor = self.colorType
            self.shape.fillColor = .clear
            self.shape.strokeColor = .clear
        }
    }
    
    init(gridPosition: GridPosition) {
        numberLabel = SKLabelNode(fontNamed:"Exo2-Medium")
        shape = SKShapeNode()
        self.gridPosition = gridPosition
        super.init(texture: nil, color: .clear, size: CGSize(width: 80, height: 80))
        zPosition = 2
        numberLabel.fontSize = 55
        numberLabel.alpha = 0
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.verticalAlignmentMode = .center
        numberLabel.isUserInteractionEnabled = false
        numberLabel.fontColor = .white
        shape.isUserInteractionEnabled = false
        let corners : UIRectCorner = [UIRectCorner.allCorners]
        shape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: size).cgPath
        shape.strokeColor = .white
        shape.position = CGPoint(x: frame.midX, y:    frame.midY)
        shape.lineWidth = 3
        addChild(shape)
        addChild(numberLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol Adjacent {
    func adjacentNumber(on matrix:[[NumberSpriteNode]]) -> NumberSpriteNode?
}

extension NumberSpriteNode : Adjacent {
    
    func adjacentNumber(on matrix:[[NumberSpriteNode]]) -> NumberSpriteNode? {
        var row = -1
        var column = -1
        while row < 2 {
            column = -1
            while column < 2 {
                let rowTmp = self.gridPosition.row + row
                let columnTmp = self.gridPosition.column + column
                if rowTmp >= 0 && rowTmp < matrix[0].count && columnTmp >= 0 && columnTmp < matrix[0].count {
                    let value = matrix[rowTmp][columnTmp].value
                    if value == followingNumber {
                        return matrix[rowTmp][columnTmp]
                    }
                }
                column += 1
            }
            row += 1
        }
        return nil
    }
    
    
    
    func updateNumberValue() {
        var trueFalse: Bool {
            return arc4random_uniform(3) < 2
        }
        
        
        if value > 0 && trueFalse {
            if trueFalse {
                value = value.followingNumber().followingNumber()
            } else {
                value = value.followingNumber().followingNumber().followingNumber()
            }
        } else {
            value = randomValue()
        }
    }
    
    func randomValue() -> Int {
        var joker: Bool {
            return arc4random_uniform(15) < 1
        }
        return joker ? -1 : 1 + Int(arc4random_uniform(UInt32(12 - 1 + 1)))
    }
    
}


extension Sequence where Iterator.Element == NumberSpriteNode {
    func possibility(on matrix:[[NumberSpriteNode]]) -> NumberSpriteNode? {
        return self.first { $0.adjacentNumber(on: matrix) != nil }
    }
}


func ==(lhs: NumberSpriteNode, rhs: NumberSpriteNode) -> Bool {
    return lhs.gridPosition.column == rhs.gridPosition.column && lhs.gridPosition.row == rhs.gridPosition.row
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


