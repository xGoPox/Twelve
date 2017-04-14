//
//  TutorialController.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

struct TutorialController  {
    
    var matrix: [[Element?]]
    var piles: [Pile]
    var grid : SKTileMapNode
    var currentSolution: Solution?
    var tutorialStep: TutorialStep

    
    fileprivate var numberOfPossibilities: Int {
        get {
            switch tutorialStep {
            case .firstStep:
                return 1
            case .secondStep:
                return 2
            case .thirdStep:
                return 1
            }
        }
    }
    
    fileprivate var lengthForCombo: Int {
        get {
            switch tutorialStep {
            case .firstStep:
                return 3
            case .secondStep:
                return 4
            case .thirdStep:
                return 6
            }
        }
    }
    
    fileprivate var updateWithFollowingNumber: Bool {
        get {
            return false
        }
    }
    
}


extension TutorialController {
    
    mutating func fullfillGrid() {
        
        matrix = [[Element]]()
        
        var row = 0
        
        for _ in 0..<self.grid.numberOfRows {
            matrix.append([Element?](repeating: nil, count: 5))
            var column = 0
            for _ in 0..<self.grid.numberOfColumns {
                matrix[row].append(nil)
                column += 1
            }
            row += 1
        }
        
    }
    
    mutating func disposeNumbers() throws {
        try disposePossibilities()
        try disposeRandomNumbers()
    }
    
    
    fileprivate mutating func disposePossibilities() throws {
        
        for pile in piles {
            
            for _ in 0..<numberOfPossibilities {
                
                var followingNumber = pile.followingNumber()
                
                var gridPosition: GridPosition
                
                if let possibility = pile.possibility , try (isNumberAt(position: possibility.gridPosition, equalWith: followingNumber)) {
                    gridPosition = possibility.gridPosition
                } else {
                    guard let position = randomEmptyPosition() else {
                        break
                    }
                    gridPosition = position
                    if try (isEmtpyAtPosition(gridPosition) || isNumberAt(position: gridPosition, equalWith: followingNumber)) {
                        try createNumberAt(position: gridPosition, with: followingNumber)
                    }
                    
                }
                
                pile.possibility = try elementAt(position: gridPosition)
                
                for _ in 0..<lengthForCombo {
                    followingNumber = followingNumber.followingNumber()
                    guard let newGridPosition = createFollowingNumber(followingNumber, position: gridPosition) else {
                        break
                    }
                    gridPosition = newGridPosition
                }
                
            }
            
        }
    }
    
    func resetPiles() {
        for pile in piles {
            switch tutorialStep {
            case .firstStep:
                pile.reset(lastNumber: 12)
            case .secondStep:
                pile.reset(lastNumber: 4)
            case .thirdStep:
                pile.reset(lastNumber: 10)
            }
        }
    }

    
    fileprivate mutating func createNumberAt(position : GridPosition, with number: Int) throws {
        if let element = try elementAt(position: position) {
            if element is NumberSpriteNode {
                element.value = number
            }
        } else {
            let object = NumberSpriteNode(gridPosition: position)
            object.value = number
            addElement(object)
        }
    }
    
    private mutating func updateElement(_ element : Element, with object : Element, at position: GridPosition) {
        object.position = element.position
        matrix[position.row][position.column] = object
        let fadeOut = SKAction.fadeOut(withDuration: 0.10)
        let fadeIn = SKAction.fadeIn(withDuration: 0.10)
        element.run(fadeOut, completion: {
            element.removeFromParent()
        })
        grid.addChild(object)
        object.run(fadeIn)
    }
    
    private mutating func addElement(_ element : Element) {
        element.position = grid.centerOfTile(atColumn: element.gridPosition.column, row: element.gridPosition.row)
        matrix[element.gridPosition.row][element.gridPosition.column] = element
        let fadeIn = SKAction.fadeIn(withDuration: 0.10)
        grid.addChild(element)
        element.run(fadeIn)
    }
    
    
    fileprivate func isNumberAt(position: GridPosition, equalWith number: Int) throws -> Bool {
        if let sprite = try elementAt(position: position) , sprite.value == number {
            return true
        }
        return false
    }
    
    fileprivate func isEmtpyAtPosition(_ position: GridPosition) throws -> Bool {
        if try elementAt(position: position) == nil {
            return true
        }
        return false
    }
    
    
    func elementAt(position: GridPosition) throws -> Element? {
        
        guard (position.row < grid.numberOfRows && position.row >= 0)  && (position.column < grid.numberOfColumns && position.column >= 0) else {
            throw TwelveError.outOfBounds
        }
        
        return matrix[position.row][position.column]
    }
    
    
    
    func removeNumbers() throws {
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                guard let element = try elementAt(position: gridPosition) else {
                    throw TwelveError.noNumberAtPosition
                }
                element.removeFromParent()
            }
        }
        
    }
    
    mutating func resetNumberAt(position: GridPosition) throws {
        guard let element = try elementAt(position: position) else {
            throw TwelveError.noNumberAtPosition
        }
        //        if element is Joker , element is FrozenNumber {
        let position:GridPosition = element.gridPosition
        //            let object = NumberSpriteNode(gridPosition: position)
        //            object.alpha = 0
        matrix[position.row][position.column] = nil
        //            object.position = element.position
        let fadeOut = SKAction.fadeOut(withDuration: 0.10)
        element.run(fadeOut, completion: {
            element.removeFromParent()
        })
        //            self.grid.addChild(object)
        //            let fadeIn = SKAction.fadeIn(withDuration: 0)
        //            object.run(fadeIn)
        //       }
        //element.value = 0
    }
    
    
    
    private mutating func disposeRandomNumbers() throws {
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    
                    if try isEmtpyAtPosition(gridPosition) {
                        try createNumberAt(position: gridPosition, with: randomValue())
                    }
                } catch let error as TwelveError {
                    fatalError("there should be no error here : \(error)")
                }
            }
        }
    }
    
    private mutating func createFollowingNumber(_ number: Int, position : GridPosition) -> GridPosition? {
        
        for _ in 0..<1000 {
            
            let newRow = randomInt(min: -1, max: 1)
            
            let newColumn = randomInt(min: -1, max: 1)
            
            let gridPosition = GridPosition(row: position.row + newRow, column: position.column + newColumn)
            
            if gridPosition != position {
                if let result = try? (isEmtpyAtPosition(gridPosition) || isNumberAt(position: gridPosition, equalWith: number)) , result == true {
                    try? createNumberAt(position: gridPosition, with:number)
                    return gridPosition
                }
            }
        }
        return nil
        
    }
    
    
    
    
    private func randomEmptyPosition() -> GridPosition? {
        for _ in 0..<1000 {
            var gridPosition: GridPosition
            gridPosition.row = randomInt(min: 0, max: grid.numberOfRows - 1)
            gridPosition.column = randomInt(min: 0, max: grid.numberOfColumns - 1)
            do {
                if try isEmtpyAtPosition(gridPosition) {
                    return gridPosition
                }
            } catch { }
        }
        return nil
    }
    
    
}

extension TutorialController {
    
    func isTile(_ currentTile: Element, adjacentWith tile: Element) throws {
        
        var newRow = -1
        
        while newRow <= 1 {
            
            var newColumn = -1
            
            while newColumn <= 1 {
                
                let gridPosition = GridPosition(row: tile.gridPosition.row + newRow, column: tile.gridPosition.column + newColumn)
                
                if gridPosition == currentTile.gridPosition {
                    _ =  try? elementAt(position: gridPosition)
                    return
                }
                
                newColumn += 1
            }
            newRow += 1
        }
        throw TwelveError.notAdjacent
    }
}



extension TutorialController {
    
    mutating func resetNumbers() throws {
        cancelSolution()
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                try resetNumberAt(position: gridPosition)
            }
        }
    }
    
    
    mutating func updateElement(_ element: Element) {
        cancelSolution()
        switch element {
        case is NumberSpriteNode:
            updateNumber(element as! NumberSpriteNode)
        default:
            let position:GridPosition = element.gridPosition
            let object = NumberSpriteNode(gridPosition: position)
            object.alpha = 0
            object.value = randomValue()
            object.position = element.position
            let fadeOut = SKAction.fadeOut(withDuration: 0.10)
            let fadeIn = SKAction.fadeIn(withDuration: 0.10)
            
            element.run(fadeOut, completion: {
                element.removeFromParent()
            })
            matrix[position.row][position.column] = object
            self.grid.addChild(object)
            object.run(fadeIn)
            
        }
        
        
    }
    
    mutating func updateNumber(_ element: NumberSpriteNode) {
        if element.value > 0 && updateWithFollowingNumber {
            if updateWithFollowingNumber {
                element.value = element.value.followingNumber().followingNumber()
            } else {
                element.value = element.value.followingNumber().followingNumber().followingNumber()
            }
        } else { // becomes a joker or a random number
            element.value = randomValue()
        }
        
    }
    
    
    func randomValue() -> Int {
        switch tutorialStep {
        case .firstStep:
            return randomInt(min: 6, max: 12)
        case .secondStep:
            return randomInt(min: 1, max: 4)
        case .thirdStep:
            return randomInt(min: 1, max: 8)
        }
    }
    
}


extension TutorialController {
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
}



extension TutorialController {
    func pilesForNumber(_ number: Int) -> [Pile]? {
        if number == -1 {
            return piles
        } else {
            return piles.filter { $0.acceptFollowingNumber(number) }
        }
    }
}


extension TutorialController {
    
    func cancelSolution() {
        let solutionNode = grid.childNode(withName: "showSolution")
            as? SKSpriteNode
        solutionNode?.removeAction(forKey: "showSolution")
        solutionNode?.alpha = 0
        currentSolution?.fromElement.removeSolution()
    }
    
    mutating func checkBoard() throws -> Solution? {
        currentSolution = try possibility()
        cancelSolution()
        return currentSolution
    }
    
    
    func possibility() throws -> Solution {
        for pile in piles {
            do {
                return try possibilityForPile(pile)
            } catch {  }
        }
        throw TwelveError.noMorePossibilities
    }
    
    func possibilityForPile(_ pile: Pile) throws -> Solution {
        
        var array = [Element]()
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                if try (isNumberAt(position: gridPosition, equalWith: pile.followingNumber())) , let number = try elementAt(position: gridPosition) {
                    number.followingNumber = pile.followingNumber().followingNumber()
                    array.append(number)
                }
            }
        }
        
        guard let possibleNumber = array.possibility(on: matrix) else {
            throw TwelveError.noMorePossibilities
        }
        return possibleNumber
    }
    
    
    
    func adjacentForNumber(_ number : Element) throws -> Element? {
        
        var newRow = -1
        while newRow <= 1 {
            
            var newColumn = -1
            
            while newColumn <= 1 {
                
                let gridPosition = GridPosition(row: number.gridPosition.row + newRow, column: number.gridPosition.column + newColumn)
                
                if gridPosition != number.gridPosition {
                    return try elementAt(position: gridPosition)
                }
                newColumn += 1
            }
            newRow += 1
        }
        
        return nil
        
    }
    
}

