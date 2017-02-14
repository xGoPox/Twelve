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
    var haloShape: SKShapeNode!

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
            haloShape.fillColor = colorType
            let color = getColorFadeAction(startColor: shape.fillColor, endColor: colorType, duration: 0.25)
            shape.run(color) { 
                self.shape.strokeColor = self.colorType
            }
        }
    }
    
    var colorType: UIColor {
        get {
            switch value {
            case 1...3:
                return UIColor(red: 34/255, green: 181/255.0, blue: 115/255.0, alpha: 1)
            case 4...6:
                return UIColor(red: 217/255.0, green: 83/255.0, blue: 79/255.0, alpha: 1)
            case 7...9:
                return UIColor(red: 240/255.0, green: 173/255.0, blue: 78/255.0, alpha: 1)
            case 10...12:
                return UIColor(red: 66/255.0, green: 139/255.0, blue: 202/255.0, alpha: 1)
            default:
                return .clear
            }
        }
    }
    
    
    init() {
        numberLabel = SKLabelNode(fontNamed:"ChalkboardSE-Light")
        shape = SKShapeNode()
        haloShape = SKShapeNode()
        super.init(texture: nil, color: .clear, size: CGSize(width: 80, height: 80))
        name = "NumberSprite"
        numberLabel.fontSize = 55
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.verticalAlignmentMode = .center
        numberLabel.isUserInteractionEnabled = false
        numberLabel.fontColor = UIColor(red:242/255, green:236/255, blue:225/255, alpha: 1)
        shape.isUserInteractionEnabled = false
        let corners : UIRectCorner = [UIRectCorner.allCorners]
        shape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: size).cgPath
        shape.strokeColor = UIColor(red:242/255, green:236/255, blue:225/255, alpha: 1)
        shape.position = CGPoint(x: frame.midX, y:    frame.midY)
        shape.lineWidth = 1
        haloShape = shape.copy() as! SKShapeNode
        haloShape.alpha = 0.5
        let shadow = SKShapeNode()
        shadow.path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: size).cgPath
        shadow.position = CGPoint(x: frame.midX, y:    frame.midY-2.5)
        shadow.lineWidth = 1
        shadow.alpha = 0.5
        shadow.strokeColor = UIColor.black
        shadow.fillColor = UIColor.black
        addChild(shadow)
        addChild(haloShape)
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
            node.strokeColor = color
            node.fillColor = color
        }
    }
    return action
}


