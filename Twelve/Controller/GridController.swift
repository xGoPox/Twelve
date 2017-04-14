//
//  File.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

protocol GridDispatcher {
    mutating func fullfillGrid()
    func resetPiles()
    mutating func disposeNumbers() throws
}

protocol Helper {
    func randomInt(min: Int, max:Int) -> Int
}

protocol Freeze {
    mutating func freezeNumbers() throws
    mutating func unFreezeNumbers() throws
    mutating func updateElementWithFrozenNumber(_ element: Element)
}



protocol GridValidator {
    func possibility() throws -> Solution
    func possibilityForPile(_ pile: Pile) throws -> Solution
    mutating func checkBoard() throws -> Solution?
    func cancelSolution()
}


typealias GridPosition = (row: Int, column: Int)
typealias Solution = (fromElement: Element, toElement: Element?)


protocol GridChecker {
    func isTile(_ currentTile: Element, adjacentWith tile: Element) throws
}


struct GridController : GridDispatcher {
    
    var matrix: [[Element?]]
    var piles: [Pile]
    var grid : SKTileMapNode
    var currentSolution: Solution?
    var frozen: Bool = false {
        willSet(freeze) {
            if freeze {
            }
        }
        
    }
    
    var gameMode: GameMode {
        get {
            return SharedGameManager.sharedInstance.gameCaracteristic.mode
        }
    }
    
    var gameDifficulty: GameDifficulty {
        get {
            return SharedGameManager.sharedInstance.gameCaracteristic.difficulty
        }
    }
    
    fileprivate var numberOfPossibilities: Int {
        get {
            switch gameDifficulty {
            case .easy:
                return randomInt(min: 1, max: 2)
            case .normal:
                return randomInt(min: 1, max: 2)
            case .hard:
                return randomInt(min: 0, max: 3)
            }
        }
    }
    
    fileprivate var lengthForCombo: Int {
        get {
            switch gameDifficulty {
            case .easy:
                return randomInt(min: 3, max: 8)
            case .normal:
                return randomInt(min: 1, max: 4)
            case .hard:
                return randomInt(min: 1, max: 5)
            }
        }
    }
    
    fileprivate var isJoker: Bool {
        get {
            if SharedGameManager.sharedInstance.hasAchievedAGame {
                return arc4random_uniform(50) < 2
            } else {
                return false
            }
        }
    }
    
    fileprivate var updateWithFollowingNumber: Bool {
        get {
            switch gameDifficulty {
            case .easy:
                return arc4random_uniform(4) < 3
            case .normal:
                return arc4random_uniform(3) < 2
            case .hard:
                return arc4random_uniform(2) < 1
            }
        }
        
    }
    
}


extension GridController {
    
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
    
    func resetPiles() {
        for pile in piles {
            pile.reset(lastNumber : 12)
        }
    }
    
    mutating func disposeNumbers() throws {
        if frozen {
            try disposeFrozenPossibilities()
            try disposeRandomNumbers()
        } else {
            try disposePossibilities()
            try disposeFuturesCombos()
            try disposeRandomNumbers()
        }
    }
    
    
    fileprivate mutating func disposePossibilities() throws {
        
        for pile in piles {
            
            for _ in 0..<numberOfPossibilities {
                
                var followingNumber = pile.followingNumber()
                
                var gridPosition: GridPosition
                
                if let possibility = pile.possibility , try (isNumberAt(position: possibility.gridPosition, equalWith: followingNumber) || isJokerAt(position: possibility.gridPosition)) {
                    gridPosition = possibility.gridPosition
                } else {
                    guard let position = randomEmptyPosition() else {
                        break
                    }
                    gridPosition = position
                    if try (isEmtpyAtPosition(gridPosition) || isNumberAt(position: gridPosition, equalWith: followingNumber) || isJokerAt(position: gridPosition)) {
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
    
    fileprivate mutating func disposeFrozenPossibilities() throws {
        
        for pile in piles {
            
            for _ in 0..<numberOfPossibilities {
                
                let followingNumber = pile.followingNumber()
                
                var gridPosition: GridPosition
                
                if let possibility = pile.possibility , try (isNumberAt(position: possibility.gridPosition, equalWith: followingNumber) || isJokerAt(position: possibility.gridPosition)) {
                    gridPosition = possibility.gridPosition
                } else {
                    guard let position = randomEmptyPosition() else {
                        break
                    }
                    gridPosition = position
                    if try (isEmtpyAtPosition(gridPosition) || isNumberAt(position: gridPosition, equalWith: followingNumber) || isJokerAt(position: gridPosition)) {
                        try createNumberAt(position: gridPosition, with: followingNumber)
                    }
                    
                }
                
                pile.possibility = try elementAt(position: gridPosition)
                
            }
            
        }
    }

    
    fileprivate mutating func disposeFuturesCombos() throws {
        
        for pile in piles {
            
            var followingNumber = pile.followingNumber().followingNumber().followingNumber().followingNumber().followingNumber()
            
            guard var gridPosition = randomEmptyPosition() else {
                break
            }
            
            try createNumberAt(position: gridPosition, with: followingNumber)
            
            var counterCombo = 1
            
            while counterCombo > 0 {
                
                followingNumber = followingNumber.followingNumber()
                
                guard let newGridPosition = createFollowingNumber(followingNumber, position: gridPosition) else {
                    break
                }
                
                gridPosition = newGridPosition
                counterCombo -= 1
            }
            
        }
    }
    
    
    
    fileprivate mutating func createNumberAt(position : GridPosition, with number: Int) throws {
        if let element = try elementAt(position: position) {
            if element is NumberSpriteNode {
                if isJoker {
                    let object = Joker(gridPosition: position)
                    updateElement(element, with: object, at: position)
                } else {
                    element.value = number
                }
            } else if element is Joker {
                if !isJoker {
                    let object = NumberSpriteNode(gridPosition: position)
                    object.value = number
                    updateElement(element, with: object, at: position)
                }
            } else {
                if isJoker {
                    let object = Joker(gridPosition: position)
                    updateElement(element, with: object, at: position)
                }
                else {
                    let object = NumberSpriteNode(gridPosition: position)
                    object.value = number
                    updateElement(element, with: object, at: position)
                }
            }
        } else {
            if frozen {
                let object = FrozenNumber(gridPosition: position, value : number)
                addElement(object)
            }
            else if isJoker {
                let object = Joker(gridPosition: position)
                addElement(object)
            } else {
                let object = NumberSpriteNode(gridPosition: position)
                object.value = number
                addElement(object)
            }
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

    
    fileprivate func isJokerAt(position: GridPosition) throws -> Bool {
        if let sprite = try elementAt(position: position) , sprite is Joker {
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
//                        if let element = try elementAt(position: gridPosition) {
//                            updateElement(element)
//                        }
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
                if let result = try? (isEmtpyAtPosition(gridPosition) || isNumberAt(position: gridPosition, equalWith: number) || isJokerAt(position: gridPosition)) , result == true {
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


extension GridController : GridChecker {
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


extension GridController : Freeze {
    mutating func freezeNumbers() throws {
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                guard let element = try elementAt(position: gridPosition) else {
                    fatalError("there should be an element at this position")
                }
                updateElementWithFrozenNumber(element)
                
            }
        }
    }
    
    
    mutating func unFreezeNumbers() throws {
        try resetNumbers()
        try disposeNumbers()
    }

    
    mutating func updateElementWithFrozenNumber(_ element: Element) {
        
        let position:GridPosition = element.gridPosition
        let object = FrozenNumber(gridPosition: position, value : randomValue())
        object.position = element.position
        object.alpha = 0
        let fadeOut = SKAction.fadeOut(withDuration: 0.10)
        let fadeIn = SKAction.fadeIn(withDuration: 0.10)
        element.run(fadeOut, completion: {
            element.removeFromParent()
        })
        matrix[position.row][position.column] = object
        object.addShape()
        self.grid.addChild(object)
        object.run(fadeIn)
    }
    
}


extension GridController {
    
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
        case is FrozenNumber:
            updateFrozenNumber(element as! FrozenNumber)
            break
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
            if isJoker {
                let position:GridPosition = element.gridPosition
                let object = Joker(gridPosition: position)
                object.alpha = 0
                object.position = element.position
                let fadeOut = SKAction.fadeOut(withDuration: 0.10)
                let fadeIn = SKAction.fadeIn(withDuration: 0.10)
                matrix[position.row][position.column] = object
                element.run(fadeOut, completion: {
                    element.removeFromParent()
                })
                self.grid.addChild(object)
                object.run(fadeIn)
                
            } else {
                element.value = randomValue()
            }
        }

    }
    
    mutating func updateFrozenNumber(_ element: FrozenNumber) {
        element.value = randomValue()
    }

    
    func randomValue() -> Int {
        return randomInt(min: 1, max: 12)
    }
    
}


extension GridController : Helper {
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
}



extension GridController {
    func pilesForNumber(_ number: Int) -> [Pile]? {
        if number == -1 {
            return piles
        } else {
            return piles.filter { $0.acceptFollowingNumber(number) }
        }
    }
}


extension GridController : GridValidator {
    
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
        if !frozen {
            return currentSolution
        }
        return nil
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
                if try (isNumberAt(position: gridPosition, equalWith: pile.followingNumber()) || isJokerAt(position: gridPosition)) , let number = try elementAt(position: gridPosition) {
                    number.followingNumber = pile.followingNumber().followingNumber()
                    array.append(number)
                }
            }
        }
        
        if frozen && array.isEmpty == false {
            return Solution(array.first!, nil)
        } else {
            guard let possibleNumber = array.possibility(on: matrix) else {
                throw TwelveError.noMorePossibilities
            }
            return possibleNumber
        }
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

extension Int {
    func followingNumber() -> Int {
        if self == 12  {
            return 1
        }
        return self + 1
    }
    
    func previousNumber() -> Int {
        if self == 1  {
            return 12
        }
        return self - 1
    }
    
}




