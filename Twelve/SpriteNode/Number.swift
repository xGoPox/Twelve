//
//  Number.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class NumberSpriteNode : SKSpriteNode {
    
    enum TileImage: String {
        case one = "One"
        case two = "Two"
        case three = "Three"
        case four = "Four"
        case five = "Five"
        case six = "Six"
        case seven = "Seven"
        case eight = "Eight"
        case nine = "Nine"
        case ten = "Ten"
        case eleven = "Eleven"
        case twelve = "Twelve"
        case null = "Null"

    }

    typealias GridPosition = (row: Int , column: Int )
    
    var gridPosition: GridPosition = (0, 0)
    
    let numberLabel: SKLabelNode!
    let shape: SKShapeNode!

    var value : Int = 0 {
        willSet(number) {
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            numberLabel.run(fadeOut) {
                self.numberLabel.text = String(number)
                self.numberLabel.run(fadeIn)
            }
        }
        didSet(number) {
            removeAction(forKey: "pulse")
            numberLabel.fontColor = colorType
        //    if shape.strokeColor != colorType {
        //        let color = getStrokeColorFadeAction(startColor: shape.strokeColor, endColor: colorType, duration: 0.1)
         //       shape.run(color)
         //   }
            if value != number {
                unselected()
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
                return .clear
            }
        }
    }
    
    func showSolution() {
        
    }
    
    func removeSolution() {
        
    }
    
    func selected() {
        
        let pulseUp = SKAction.scale(to: 1.3, duration: 0.20)
        let pulseDown = SKAction.scale(to: 1, duration: 0.20)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        
        let color = getColorFadeAction(startColor: colorType, endColor: colorType, duration: 0.1)
        shape.run(color)

        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)

        self.shape.run(color)
        numberLabel.run(fadeOut) {
            self.numberLabel.fontColor = .white
            self.numberLabel.run(fadeIn)
        }
        
        let repeatAction = SKAction.repeatForever(pulse)
        shape.run(repeatAction, withKey: "selected")
    }
    
    func unselected() {
        let color = getColorFadeAction(startColor: colorType, endColor: .white, duration: 0.1)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        
        let numberScaleBackAction = SKAction.scale(to: 1, duration: 0.15)
        shape.run(numberScaleBackAction)
        numberLabel.run(fadeOut) {
            self.shape.run(color)
            self.numberLabel.fontColor = self.colorType
            self.numberLabel.run(fadeIn)
        }
        shape.removeAction(forKey: "selected")
    }
    
    init() {
        numberLabel = SKLabelNode(fontNamed:"Exo2-Medium")
        shape = SKShapeNode()
        super.init(texture: nil, color: .clear, size: CGSize(width: 80, height: 80))
        name = "NumberSprite"
        numberLabel.fontSize = 55
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
                    if matrix[rowTmp][columnTmp].value == self.value.followingNumber() {
                        return matrix[rowTmp][columnTmp]
                    }
                }
                column += 1
            }
            row += 1
        }
        return nil
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


private func getStrokeColorFadeAction(startColor: UIColor, endColor: UIColor, duration: TimeInterval) -> SKAction {
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
            node.strokeColor =  color
        }
    }
    return action
}


private func getColorFadeAction(startColor: UIColor, endColor: UIColor, duration: TimeInterval) -> SKAction {
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
            node.fillColor = color
            node.strokeColor = color

        }
    }
    return action
}


