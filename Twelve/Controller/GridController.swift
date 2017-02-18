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


protocol GridValidator {
    func possibility() throws -> Element
    func possibilityForPile(_ pile: Pile) throws -> Element
    mutating func checkBoard() throws
    func cancelSolution()
}


typealias GridPosition = (row: Int, column: Int)

struct GridController : GridDispatcher {
    
    var matrix: [[Element]]
    var piles: [Pile]
    var grid : SKTileMapNode
    var currentSolution: Element?
    
    fileprivate var numberOfPossibilities: Int {
        get {
            return randomInt(min: 1, max: 3)
        }
    }
    fileprivate var lengthForCombo: Int {
        get {
            return randomInt(min: 1, max: 5)
        }
    }
    
    mutating func fullfillGrid() {
        
        matrix = [[Element]]()
        
        var row = 0
        
        for _ in 0..<self.grid.numberOfRows {
            matrix.append([Element]())
            var column = 0
            for _ in 0..<self.grid.numberOfColumns {
                let sprite = Element(gridPosition: GridPosition(row, column))
                sprite.position = grid.centerOfTile(atColumn: sprite.gridPosition.column, row: sprite.gridPosition.row)
                matrix[row].append(sprite)
                column += 1
            }
            row += 1
        }
        
    }
    
    func resetPiles() {
        for pile in piles {
            pile.reset()
        }
    }
    
    mutating func disposeNumbers() throws {
        try disposePossibilities()
        try disposeFuturesCombos()
        try disposeRandomNumbers()
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
                    if try (isNumberAt(position: gridPosition, equalWith: 0) || isNumberAt(position: gridPosition, equalWith: followingNumber) || isJokerAt(position: gridPosition)) {
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
            var isJoker: Bool {
                return arc4random_uniform(3) < 1
            }
            if element is NumberSpriteNode {
                if isJoker {
                    let position:GridPosition = element.gridPosition
                    let object = Joker(gridPosition: position)
                    matrix[position.row][position.column] = object
                    object.position = element.position
                    element.removeFromParent()
                    grid.addChild(object)
                } else {
                    element.value = number
                }
            } else if element is Joker {
                if !isJoker {
                    let object = NumberSpriteNode(gridPosition: position)
                    let element = matrix[position.row][position.column]
                    object.position = element.position
                    object.value = number
                    matrix[position.row][position.column] = object
                    element.removeFromParent()
                    grid.addChild(object)
                }
            } else {
                if isJoker {
                    let position:GridPosition = element.gridPosition
                    let object = Joker(gridPosition: position)
                    matrix[position.row][position.column] = object
                    object.position = element.position
                    element.removeFromParent()
                    grid.addChild(object)
                } else {
                    let object = NumberSpriteNode(gridPosition: position)
                    let element = matrix[position.row][position.column]
                    object.position = element.position
                    object.value = number
                    matrix[position.row][position.column] = object
                    element.removeFromParent()
                    grid.addChild(object)
                }
            }
        }
    }
    
    fileprivate func isNumberAt(position: GridPosition, equalWith number: Int) throws -> Bool {
        if let sprite = try elementAt(position: position) , sprite.value == number {
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
    
    
    
    mutating func resetNumberAt(position: GridPosition) throws {
        guard let element = try elementAt(position: position) else {
            throw TwelveError.noNumberAtPosition
        }
        if element is Joker {
            let position:GridPosition = element.gridPosition
            let object = NumberSpriteNode(gridPosition: position)
            matrix[position.row][position.column] = object
            object.position = element.position
            element.removeFromParent()
            grid.addChild(object)
        }
        element.value = 0
    }
    
    
    
    private mutating func disposeRandomNumbers() throws {
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    if try isNumberAt(position: gridPosition, equalWith: 0) {
                        if let element = try elementAt(position: gridPosition) {
                            updateElement(element)
                        }
                    }
                } catch let error as TwelveError {
                    fatalError("there should be no error here : \(error)")
                }
            }
        }
    }
    
    private mutating func createFollowingNumber(_ number: Int, position : GridPosition) -> GridPosition? {
        
        for _ in 0..<100 {
            
            let newRow = randomInt(min: -1, max: 1)
            
            let newColumn = randomInt(min: -1, max: 1)
            
            let gridPosition = GridPosition(row: position.row + newRow, column: position.column + newColumn)
            
            if gridPosition != position {
                if let result = try? (isNumberAt(position: gridPosition, equalWith: 0) || isNumberAt(position: gridPosition, equalWith: number) || isJokerAt(position: gridPosition)) , result == true {
                    try? createNumberAt(position: gridPosition, with:number)
                    return gridPosition
                }
            }
        }
        return nil
        
    }
    
    
    
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
    
    
    
    
    private func randomEmptyPosition() -> GridPosition? {
        for _ in 0..<100 {
            var gridPosition: GridPosition
            gridPosition.row = randomInt(min: 0, max: grid.numberOfRows - 1)
            gridPosition.column = randomInt(min: 0, max: grid.numberOfColumns - 1)
            do {
                if try isNumberAt(position: gridPosition, equalWith: 0) {
                    return gridPosition
                }
            } catch { }
        }
        return nil
    }
    
}

extension GridController {
    
    mutating func resetNumbers() throws {
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                try resetNumberAt(position: gridPosition)
            }
        }
    }
    
    
    mutating func updateElement(_ element: Element) {
        
        if element is NumberSpriteNode {
            
            var trueFalse: Bool {
                return arc4random_uniform(3) < 2
            }
            
            if element.value > 0 && trueFalse {
                if trueFalse {
                    element.value = element.value.followingNumber().followingNumber()
                } else {
                    element.value = element.value.followingNumber().followingNumber().followingNumber()
                }
            } else { // becomes a joker or a random number
                
                var isJoker: Bool {
                    return arc4random_uniform(3) < 1
                }
                
                if isJoker {
                    let position:GridPosition = element.gridPosition
                    let object = Joker(gridPosition: position)
                    object.position = element.position
                    element.removeFromParent()
                    matrix[position.row][position.column] = object
                    grid.addChild(object)
                } else {
                    element.value = randomValue()
                }
            }
            
        } else {
            let position:GridPosition = element.gridPosition
            let object = NumberSpriteNode(gridPosition: position)
            object.value = randomValue()
            object.position = element.position
            element.removeFromParent()
            matrix[position.row][position.column] = object
            grid.addChild(object)
        }
        
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
        currentSolution?.removeSolution()
    }
    
    mutating func checkBoard() throws {
        currentSolution = try possibility()
        currentSolution?.removeSolution()
        currentSolution?.showSolution()
    }
    
    
    func possibility() throws -> Element {
        for pile in piles {
            do {
                return try possibilityForPile(pile)
            } catch {  }
        }
        throw TwelveError.noMorePossibilities
    }
    
    func possibilityForPile(_ pile: Pile) throws -> Element {
        
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




