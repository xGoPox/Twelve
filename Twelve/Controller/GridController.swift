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
    
    var numberOfPossibilities: Int {
        get {
            return randomInt(min: 1, max: 3)
        }
    }
    var lengthForCombo: Int {
        get {
            return randomInt(min: 2, max: 5)
        }
    }
    
    var freezed = false  {
        willSet(freeze) {
            if freeze {
                freezeGrid()
            } else {
                unfreezeGrid()
            }
        }
    }

    
    var matrix : [[NumberSpriteNode]] = [[NumberSpriteNode]]()
    var piles = [Pile]()
    var grid : SKTileMapNode!
    var currentSolution: NumberSpriteNode?
    
    mutating func fullfillGrid(_ grid : SKTileMapNode, with piles: [Pile]) {
        self.grid = grid
        
        var row = 0
        
        for _ in 0..<self.grid.numberOfRows {
            // Append an empty row.
            matrix.append([NumberSpriteNode]())
            var column = 0
            for _ in 0..<self.grid.numberOfColumns {
                // Populate the row.
                let position = GridPosition(row, column)
                let sprite = NumberSpriteNode()
                sprite.zPosition = 2
                sprite.gridPosition = position
                sprite.position = grid.centerOfTile(atColumn: sprite.gridPosition.column, row: sprite.gridPosition.row)
                grid.addChild(sprite)
                matrix[row].append(sprite)
                column += 1
            }
            row += 1
            
        }
        
        
        self.piles = piles
        do {
            try disposeNumbers()
        } catch let error {
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
        try disposeFuturesCombos()
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
    
    mutating func disposeFuturesCombos() throws {
        
        for pile in piles {
            
            var followingNumber = pile.followingNumber().followingNumber().followingNumber().followingNumber().followingNumber()
            
            var gridPosition = randomEmptyPosition()
            
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
    
    
    //    func tileGroupAt(position: GridPosition) throws {
    //        guard (position.row < grid.numberOfRows && position.row >= 0)  && (position.column < grid.numberOfColumns && position.column >= 0) else {
    //            throw TwelveError.outOfBounds
    //        }
    
    //        guard (grid.tileGroup(atColumn: position.column, row: position.row)) != nil else {
    //            throw TwelveError.noTileGroupAtPosition
    //       }
    //   }
    
    
    var trueFalse: Bool {
        return arc4random_uniform(3) < 2
    }
    
    func updateNumberAt(position: GridPosition, with number: Int) throws {
        guard let sprite = try numberAt(position: position) else {
            throw TwelveError.noNumberAtPosition
        }
        if sprite.value > 0 && trueFalse {
            if trueFalse {
                sprite.value = sprite.value.followingNumber().followingNumber()
            } else {
                sprite.value = sprite.value.followingNumber().followingNumber().followingNumber()
            }
        } else {
            sprite.value = number
        }
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
        
        for _ in 0..<100 {
            
            let newRow = randomInt(min: -1, max: 1)
            
            let newColumn = randomInt(min: -1, max: 1)
            
            let gridPosition = GridPosition(row: position.row + newRow, column: position.column + newColumn)
            
            if gridPosition != position {
                do {
                    if try (isNumberAt(position: gridPosition, equalWith: 0) || isNumberAt(position: gridPosition, equalWith: number)) {
                        try createNumberAt(position: gridPosition, with: number)
                        return gridPosition
                    }
                } catch { }
                
            }
        }
        
        return nil
        
    }
    
    
    func validPosition(_ gridPosition: GridPosition, for number: Int) -> Bool {
        do {
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
    
    
    
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func randomTileValue() -> Int {
        return randomInt(min: 1, max: 12)
    }
    
    func randomEmptyPosition() -> GridPosition {
        for _ in 1...1000 {
            var gridPosition: GridPosition
            gridPosition.row = randomInt(min: 0, max: grid.numberOfRows - 1)
            gridPosition.column = randomInt(min: 0, max: grid.numberOfColumns - 1)
            do {
                //                try tileGroupAt(position: gridPosition)
                if try isNumberAt(position: gridPosition, equalWith: 0) {
                    return gridPosition
                }
            } catch { }
        }
        return (0, 0)
    }
    
}

protocol Freezer {
    func unfreezeGrid()
    func freezeGrid()
}

extension GridController : Freezer {
    
    func unfreezeGrid() {
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    if let number = try numberAt(position: gridPosition) {
                        number.frozen = false
                    }
                } catch {  }
            }
        }
    }
    func freezeGrid() {
        
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    if let number = try numberAt(position: gridPosition) {
                        number.frozen = true
                    }
                } catch {  }
            }
        }
        
      

    }
    
}

extension GridController {
    func pileForNumber(_ number: Int) -> Pile? {
        return piles.first { $0.acceptFollowingNumber(number) }
    }
}

protocol GridValidator {
    func possibility() throws -> NumberSpriteNode
    func possibilityForPile(_ pile: Pile) throws -> NumberSpriteNode
    mutating func checkBoard() throws
    func cancelSolution()
}


extension GridController : GridValidator {
    
    func cancelSolution() {
        currentSolution?.removeSolution()
    }
    
    mutating func checkBoard() throws {
        currentSolution = try possibility()
        if !freezed {
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
        
        if freezed {
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
                    //   try tileGroupAt(position: gridPosition)
                    return try numberAt(position: gridPosition)
                }
                newColumn += 1
            }
            newRow += 1
        }
        
        return nil
        
    }
    
    
    
}

