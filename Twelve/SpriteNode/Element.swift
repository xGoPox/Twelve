//
//  Element.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/17/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class Element: SKSpriteNode {
    
    let modeColor: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white

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
    
    
    var handTexture: SKTexture? {
        get {
            switch value {
            case 1...3:
                return SharedAssetsManager.sharedInstance.greenHand
            case 4...6:
                return SharedAssetsManager.sharedInstance.redHand
            case 7...9:
                return SharedAssetsManager.sharedInstance.yellowHand
            case 10...12:
                return SharedAssetsManager.sharedInstance.blueHand
            default:
                return SharedAssetsManager.sharedInstance.greenHand
            }
        }
    }

    
    
    init(gridPosition: GridPosition) {
        self.gridPosition = gridPosition
        super.init(texture: nil, color: .clear, size: CGSize(width: 80, height: 80))
        zPosition = 2
        alpha = 0
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
        removeAction(forKey: "showSolution")
        if (action(forKey: "solution") != nil) {
            let pulseUp = SKAction.scale(to: 1, duration: 0.1)
            run(pulseUp)
            removeAction(forKey: "solution")
        }
    }
    
}

extension Sequence where Iterator.Element == Element {
    func possibility(on matrix:[[Element?]]) -> Solution? {
        var toElement: Element?
        
        if let fromElement = self.first(where: { (element) -> Bool in
            toElement = element.adjacentNumber(on: matrix)
            if toElement != nil {
                return true
            } else {
                return false
            }
        }) {
            return Solution(fromElement, toElement)
        }
        return nil
    }
}


func ==(lhs: Element, rhs: Element) -> Bool {
    return lhs.gridPosition.column == rhs.gridPosition.column && lhs.gridPosition.row == rhs.gridPosition.row
}



protocol Adjacent {
    func adjacentNumber(on matrix:[[Element?]]) -> Element?
}

extension Element : Adjacent {
    
    func adjacentNumber(on matrix:[[Element?]]) -> Element? {
        var row = -1
        var column = -1
        while row < 2 {
            column = -1
            while column < 2 {
                let rowTmp = self.gridPosition.row + row
                let columnTmp = self.gridPosition.column + column
                if rowTmp >= 0 && rowTmp < matrix[0].count && columnTmp >= 0 && columnTmp < matrix[0].count && rowTmp < matrix.count {
                    if let element = matrix[rowTmp][columnTmp] {
                        if element.value == followingNumber {
                            return element
                        }
                    }
                }
                column += 1
            }
            row += 1
        }
        return nil
    }
    
}
