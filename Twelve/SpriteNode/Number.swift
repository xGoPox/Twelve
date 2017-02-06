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
            numberLabel.text = String(number)
        }
        didSet(number) {
            shape.fillColor = colorType
        }
    }
    
    var colorType: UIColor {
        get {
            switch value {
            case 1...4:
                return UIColor(red: 81/255, green: 77/255, blue: 152/255, alpha: 1.0)
            case 5...8:
                return UIColor(red: 183/255, green: 77/255, blue: 127/255, alpha: 1.0)
            case 9...12:
                return UIColor(red: 63/255, green: 149/255, blue: 114/255, alpha: 1.0)
            default:
                return .clear
            }
        }
    }

    
    
    init() {
        numberLabel = SKLabelNode(fontNamed:"MarkerFelt-Thin")
        shape = SKShapeNode()
        super.init(texture: nil, color: .clear, size: CGSize(width: 80, height: 80))
        numberLabel.fontSize = 30
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.verticalAlignmentMode = .center
        numberLabel.isUserInteractionEnabled = false
        shape.isUserInteractionEnabled = false
        let corners : UIRectCorner = [UIRectCorner.allCorners]
        shape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: size).cgPath
        shape.position = CGPoint(x: frame.midX, y:    frame.midY)
        shape.lineWidth = 1
        addChild(numberLabel)
        addChild(shape)
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





