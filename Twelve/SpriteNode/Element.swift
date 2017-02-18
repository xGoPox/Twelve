//
//  Element.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/17/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class Element: SKSpriteNode {
    
    typealias GridPosition = (row: Int , column: Int )
    
    final var gridPosition: GridPosition
    
    var value : Int = 0
    
    var followingNumber: Int?
    
    
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
    
    
    init(gridPosition: GridPosition) {
        self.gridPosition = gridPosition
        super.init(texture: nil, color: .clear, size: CGSize(width: 80, height: 80))
        zPosition = 2
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}


protocol Animation {
    func selected()
    func unselected()
    func showSolution()
    func removeSolution()
}

extension Element : Animation {
    
    func selected() {
        
    }
    
    func unselected() {
        
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
    
}

extension Sequence where Iterator.Element == Element {
    func possibility(on matrix:[[Element]]) -> Element? {
        return self.first { $0.adjacentNumber(on: matrix) != nil }
    }
}


func ==(lhs: Element, rhs: Element) -> Bool {
    return lhs.gridPosition.column == rhs.gridPosition.column && lhs.gridPosition.row == rhs.gridPosition.row
}



protocol Adjacent {
    func adjacentNumber(on matrix:[[Element]]) -> Element?
}

extension Element : Adjacent {
    
    func adjacentNumber(on matrix:[[Element]]) -> Element? {
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
    
}
