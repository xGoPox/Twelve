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
    
    var value : Int = 0 {
        didSet(number) {
            self.texture = SKTexture(imageNamed: self.imageName.rawValue)
        }
    }
    
    var imageName: TileImage {
        get {
            switch value {
            case 1:
                return .one
            case 2:
                return .two
            case 3:
                return .three
            case 4:
                return .four
            case 5:
                return .five
            case 6:
                return .six
            case 7:
                return .seven
            case 8:
                return .eight
            case 9:
                return .nine
            case 10:
                return .ten
            case 11:
                return .eleven
            case 12:
                return .twelve
            default:
                return .null
            }
        }
    }
    
    init() {
        let texture = SKTexture(imageNamed: TileImage.null.rawValue)
        super.init(texture: texture, color: .clear, size: CGSize(width: 100, height: 100))
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





