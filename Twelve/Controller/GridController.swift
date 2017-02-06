//
//  File.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

protocol GridDispatcher {
    mutating func fullfillGrid(_ grid : SKTileMapNode, with piles: [Pile])
}

typealias GridPosition = (row: Int, column: Int)

struct GridController : GridDispatcher {
    
    let numberOfPossibilities = 2
    let lengthForCombo = 10
    var matrix : [[NumberSpriteNode?]] = [[NumberSpriteNode]]()
    var piles = [Pile]()
    var grid : SKTileMapNode!
    
    
    mutating func fullfillGrid(_ grid : SKTileMapNode, with piles: [Pile]) {
        self.grid = grid
        
        var row = 0
        
        for _ in 0..<self.grid.numberOfRows {
            // Append an empty row.
            matrix.append([NumberSpriteNode]())
            var column = 0
            for _ in 0..<self.grid.numberOfColumns {
                // Populate the row.
                do  {
                    let position = GridPosition(row, column)
                    try tileGroupAt(position: position)
                    let sprite = NumberSpriteNode()
                    sprite.gridPosition = position
                    sprite.position = grid.centerOfTile(atColumn: sprite.gridPosition.column, row: sprite.gridPosition.row)
                    grid.addChild(sprite)
                    matrix[row].append(sprite)
                } catch {
                    matrix[row].append(nil)
                }
                column += 1
            }
            row += 1
            
        }
        
        
        self.piles = piles
        do {
            try disposeNumbers()
        } catch let error {
            print(error.localizedDescription)
            fatalError(error.localizedDescription)
        }
    }
    
    func resetPiles() {
        for pile in piles {
            pile.updateWithLastNumber(12)
        }
    }
    
    mutating func disposeNumbers() throws {
        try disposePossibilities()
        try disposeRandomNumbers()
    }
    
    
    
    mutating func disposePossibilities() throws {
        
        for pile in piles {
            
            for _ in 0..<numberOfPossibilities {
                
                var followingNumber = pile.followingNumber()
                
                var gridPosition = randomEmptyPosition()
                
                try createNumberAt(position: gridPosition, with: followingNumber)
                
                var counterCombo = 0;
                
                while counterCombo < lengthForCombo {
                    
                    followingNumber = followingNumber.followingNumber()
                    
                    guard let newGridPosition = createFollowingNumber(followingNumber, position: gridPosition) else {
                        break
                    }
                    
                    gridPosition = newGridPosition
                    counterCombo += 1
                }
                
            }
            
        }
    }
    
    mutating func createNumberAt(position : GridPosition, with number: Int) throws {
        if let sprite = try numberAt(position: position) {
            sprite.value = number
        }
    }
    
    func isNumberAt(position: GridPosition, equalWith number: Int) throws -> Bool {
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
    
    
    func tileGroupAt(position: GridPosition) throws {
        guard (position.row < grid.numberOfRows && position.row >= 0)  && (position.column < grid.numberOfColumns && position.column >= 0) else {
            throw TwelveError.outOfBounds
        }
        
        guard (grid.tileGroup(atColumn: position.column, row: position.row)) != nil else {
            throw TwelveError.noTileGroupAtPosition
        }
    }
    
    
    func updateNumberAt(position: GridPosition, with number: Int) throws {
        guard let sprite = try numberAt(position: position) else {
            throw TwelveError.noNumberAtPosition
        }
        sprite.value = number
    }
    
    
    
    
    func resetNumbers() throws {
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                try updateNumberAt(position: gridPosition, with: 0)
            }
        }
    }
    
    mutating func disposeRandomNumbers() throws {
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    if try isNumberAt(position: gridPosition, equalWith: 0) {
                        try createNumberAt(position: gridPosition, with: randomTileValue())
                    }
                } catch let error as TwelveError {
                    fatalError("there should be no error here : \(error)")
                }
            }
        }
    }
    
    mutating func createFollowingNumber(_ number: Int, position : GridPosition) -> GridPosition? {
        
        var newRow = -1
        while newRow <= 1 {
            
            var newColumn = -1
            
            while newColumn <= 1 {
                
                //                let evenNumber = position.row % 2 == 0 // pair
                
                let gridPosition = GridPosition(row: position.row + newRow, column: position.column + newColumn)
                
                if gridPosition != position {
                    do {
                        try tileGroupAt(position: gridPosition)
                        
                        if try (isNumberAt(position: gridPosition, equalWith: 0) || isNumberAt(position: gridPosition, equalWith: number)) {
                            try createNumberAt(position: gridPosition, with: number)
                            return gridPosition
                        }
                    } catch { }
                    
                }
                newColumn += 1
            }
            newRow += 1
        }
        
        return nil
        
    }
    
    
    func validPosition(_ gridPosition: GridPosition, for number: Int) -> Bool {
        do {
            try tileGroupAt(position: gridPosition)
            if try (isNumberAt(position: gridPosition, equalWith: 0) || isNumberAt(position: gridPosition, equalWith: number)) {
                return true
            }
            return false
        } catch let error {
            print("error : \(error) hmm what's up at  row : \(gridPosition.row) column : \(gridPosition.column)")
            return false
        }
    }
    
    
    func isTile(_ currentTile: NumberSpriteNode, adjacentWith tile: NumberSpriteNode) throws {
        
        var newRow = -1
        
        while newRow <= 1 {
            
            var newColumn = -1
            
            while newColumn <= 1 {
                
                let gridPosition = GridPosition(row: tile.gridPosition.row + newRow, column: tile.gridPosition.column + newColumn)
                
                if gridPosition == currentTile.gridPosition {
                    do {
                        try tileGroupAt(position: gridPosition)
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

    
    
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func randomTileValue() -> Int {
        return randomInt(min: 1, max: 12)
    }
    
    func randomEmptyPosition() -> GridPosition {
        while true {
            var gridPosition: GridPosition
            gridPosition.row = randomInt(min: 0, max: grid.numberOfRows - 1)
            gridPosition.column = randomInt(min: 0, max: grid.numberOfColumns - 1)
            do {
                try tileGroupAt(position: gridPosition)
                if try isNumberAt(position: gridPosition, equalWith: 0) {
                    return gridPosition
                }
            } catch { }
        }
    }
    
}

extension GridController {
    func pileForNumber(_ number: Int) -> Pile? {
        return piles.first { $0.acceptFollowingNumber(number) }
    }
}

protocol GridValidator {
    func possibility() throws -> Pile
    func possibilitiesForPile(_ pile: Pile) throws
    mutating func checkBoard() throws
}


extension GridController : GridValidator {
    
    mutating func checkBoard() {
        do {
            _ = try self.possibility()
        } catch let error as TwelveError where error == .noMorePossibilities {
            try? resetNumbers()
            try? disposeNumbers()
        } catch {
            fatalError("checkBoard exception should have been caught")
        }
        
    }
    
    func possibility() throws -> Pile {
        let pile = piles.first {
            do {
                try possibilitiesForPile($0)
                return true
            } catch {
                return false
            }
        }
        
        guard pile != nil else {
            throw TwelveError.noMorePossibilities
        }
        return pile!
    }
    
    func possibilitiesForPile(_ pile: Pile) throws {
        
        var array = [NumberSpriteNode]()
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let position = GridPosition(row, column)
                if try isNumberAt(position: position, equalWith: pile.followingNumber()) , let number = try numberAt(position: position) {
                    array.append(number)
                }
            }
        }
        
        let possibilities = (array.filter { do { return try adjacentForNumber($0) != nil } catch { return false } })
        
        print(possibilities)
        
        guard possibilities.isEmpty == false else {
            throw TwelveError.noMorePossibilities
        }
    }
    
    
    
    func adjacentForNumber(_ number : NumberSpriteNode) throws -> NumberSpriteNode? {
        
        var newRow = -1
        while newRow <= 1 {
            
            var newColumn = -1
            
            while newColumn <= 1 {
                
                let gridPosition = GridPosition(row: number.gridPosition.row + newRow, column: number.gridPosition.column + newColumn)
                
                if gridPosition != number.gridPosition {
                    try tileGroupAt(position: gridPosition)
                    return try numberAt(position: gridPosition)
                }
                newColumn += 1
            }
            newRow += 1
        }
        
        return nil
        
    }
    
    
    
}

