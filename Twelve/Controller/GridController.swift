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
    func possibility() throws -> NumberSpriteNode
    func possibilityForPile(_ pile: Pile) throws -> NumberSpriteNode
    mutating func checkBoard() throws
    func cancelSolution()
}


typealias GridPosition = (row: Int, column: Int)

struct GridController : GridDispatcher {
    
    var matrix: [[NumberSpriteNode]]
    var piles: [Pile]
    var grid : SKTileMapNode
    var currentSolution: NumberSpriteNode?
    
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
    
     var frozen: Bool = false  {
        willSet(freeze) {
            if freeze {
                cancelSolution()
                freezeGrid(freeze: true)
            } else {
                freezeGrid(freeze: false)
            }
        }
    }
    
    mutating func fullfillGrid() {
        
        matrix = [[NumberSpriteNode]]()
        
        var row = 0
        
        for _ in 0..<self.grid.numberOfRows {
            matrix.append([NumberSpriteNode]())
            var column = 0
            for _ in 0..<self.grid.numberOfColumns {
                let sprite = NumberSpriteNode(gridPosition: GridPosition(row, column))
                sprite.position = grid.centerOfTile(atColumn: sprite.gridPosition.column, row: sprite.gridPosition.row)
                grid.addChild(sprite)
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
                
                if let possibility = pile.possibility , try isNumberAt(position: possibility.gridPosition, equalWith: followingNumber) {
                    gridPosition = possibility.gridPosition
                } else {
                    guard let position = randomEmptyPosition() else {
                        break
                    }
                    gridPosition = position
                    if try (isNumberAt(position: gridPosition, equalWith: 0) || isNumberAt(position: gridPosition, equalWith: followingNumber)) {
                        try createNumberAt(position: gridPosition, with: followingNumber)
                    }
                    
                }
                
                pile.possibility = try numberAt(position: gridPosition)
                
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
        if let sprite = try numberAt(position: position) {
            sprite.value = number
        }
    }
    
   fileprivate func isNumberAt(position: GridPosition, equalWith number: Int) throws -> Bool {
        if let sprite = try numberAt(position: position) , sprite.value == number {
            return true
        }
        return false
    }
    
    func numberAt(position: GridPosition) throws -> NumberSpriteNode? {
        
        guard (position.row < grid.numberOfRows && position.row >= 0)  && (position.column < grid.numberOfColumns && position.column >= 0) else {
            throw TwelveError.outOfBounds
        }
        
        return matrix[position.row][position.column]
    }
    
    
    
    
    
    func resetNumberAt(position: GridPosition) throws {
        guard let sprite = try numberAt(position: position) else {
            throw TwelveError.noNumberAtPosition
        }
        sprite.value = 0
    }
    
    
    
   private mutating func disposeRandomNumbers() throws {
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    if try isNumberAt(position: gridPosition, equalWith: 0) {
                        let number = try numberAt(position: gridPosition)
                        number?.updateNumberValue()
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
                if let result = try? (isNumberAt(position: gridPosition, equalWith: 0) || isNumberAt(position: gridPosition, equalWith: number)) , result == true {
                    try? createNumberAt(position: gridPosition, with: number)
                    return gridPosition
                }
            }
        }
        return nil
        
    }
    
    
    
    func isTile(_ currentTile: NumberSpriteNode, adjacentWith tile: NumberSpriteNode) throws {
        
        var newRow = -1
        
        while newRow <= 1 {
            
            var newColumn = -1
            
            while newColumn <= 1 {
                
                let gridPosition = GridPosition(row: tile.gridPosition.row + newRow, column: tile.gridPosition.column + newColumn)
                
                if gridPosition == currentTile.gridPosition {
                    do {
                        _  = try numberAt(position: gridPosition)
                        return
                    } catch let error {
                        print("error : \(error) at position \(gridPosition)")
                    }
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
    
    func resetNumbers() throws {
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                try resetNumberAt(position: gridPosition)
            }
        }
    }

    
}


extension GridController : Helper {
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    
}



extension GridController {
    
   fileprivate func freezeGrid(freeze: Bool) {
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                if let number = try? numberAt(position: gridPosition) {
                    number?.frozen = freeze
                }
            }
        }
    }
    
}

extension GridController {
    func pileForNumber(_ number: Int) -> Pile? {
        return piles.first { $0.acceptFollowingNumber(number) }
    }
}


extension GridController : GridValidator {
    
    func cancelSolution() {
        currentSolution?.removeSolution()
    }
    
    mutating func checkBoard() throws {
        currentSolution = try possibility()
        if !frozen {
            currentSolution?.removeSolution()
            currentSolution?.showSolution()
        }
    }
    
    
    func possibility() throws -> NumberSpriteNode {
        for pile in piles {
            do {
                return try possibilityForPile(pile)
            } catch {  }
        }
        throw TwelveError.noMorePossibilities
    }
    
    func possibilityForPile(_ pile: Pile) throws -> NumberSpriteNode {
        
        var array = [NumberSpriteNode]()
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let position = GridPosition(row, column)
                if try isNumberAt(position: position, equalWith: pile.followingNumber()) , let number = try numberAt(position: position) {
                    array.append(number)
                }
            }
        }
        
        if frozen {
            guard let possibleNumber = array.first else {
                throw TwelveError.noMorePossibilities
            }
            return possibleNumber
            
        } else {
            guard let possibleNumber = array.possibility(on: matrix) else {
                throw TwelveError.noMorePossibilities
            }
            return possibleNumber
        }
    }
    
    
    
    func adjacentForNumber(_ number : NumberSpriteNode) throws -> NumberSpriteNode? {
        
        var newRow = -1
        while newRow <= 1 {
            
            var newColumn = -1
            
            while newColumn <= 1 {
                
                let gridPosition = GridPosition(row: number.gridPosition.row + newRow, column: number.gridPosition.column + newColumn)
                
                if gridPosition != number.gridPosition {
                    return try numberAt(position: gridPosition)
                }
                newColumn += 1
            }
            newRow += 1
        }
        
        return nil
        
    }
    
}

