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
    
    typealias TileInformation = (gridPosition: GridPosition, definition: SKTileDefinition)
    let numberOfPossibilities = 1
    let lengthForCombo = 4
    //    var matrix:[[NumberSpriteNode]] = [[NumberSpriteNode]]()
    var piles = [Pile]()
    var grid : SKTileMapNode!
    
    
    mutating func fullfillGrid(_ grid : SKTileMapNode, with piles: [Pile]) {
        self.grid = grid
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
    
    
    func tileGroupFor(tile : Tile) -> SKTileGroup {
        guard let numbersTilesSet = SKTileSet(named: "Numbers Tiles") else {
            fatalError("Object Tiles Tile Set not found")
        }
        
        let tileGroups = numbersTilesSet.tileGroups
        
        guard let group = tileGroups.first(where: {$0.name == tile.rawValue}) else {
            fatalError(tile.rawValue)
        }
        
        return group
    }
    
    
    func disposePossibilities() throws {
        
        for pile in piles {
            
            for _ in 0..<numberOfPossibilities {
                
                var followingNumber = pile.followingNumber()
                
                var gridPosition = randomGridPosition()
                
                do {
                    _ = try self.tileDefinitionAt(position: gridPosition)
                } catch let error as ComboError where error == .noDefinitionAtPosition {
                    try self.createTileAt(position: gridPosition, with: followingNumber)
                }
                
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
    
    func tileDefinitionForEitherEqualValueOrNullAt(position: GridPosition, with followingNumber: Int) throws {
        guard let definition =  try tileDefinitionAt(position: position) , let value = definition.userData?.value(forKey: "value") as? Int , value == followingNumber else {
            throw ComboError.numberIsNotEqualWithFollowingNumber
        }
    }
    
    func tileDefinitionAt(position: GridPosition) throws -> SKTileDefinition? {
        guard position.row < grid.numberOfRows && position.row >= 0 else {
            throw ComboError.rowOutOfBounds
        }
        guard position.column < grid.numberOfColumns && position.column >= 0 else {
            throw ComboError.columnOutOfBounds
        }
        
        guard let definition = grid.tileDefinition(atColumn: position.column, row: position.row) else {
            throw ComboError.noDefinitionAtPosition
        }
        return definition
    }
    
    func createTileAt(position: GridPosition, with number: Int)  throws {
        guard position.row < grid.numberOfRows && position.row >= 0 else {
            throw ComboError.rowOutOfBounds
        }
        guard position.column < grid.numberOfColumns && position.column >= 0 else {
            throw ComboError.columnOutOfBounds
        }

        grid.setTileGroup(tileGroupFor(tile: tileForValue(value: number)), forColumn: position.column, row: position.row)
    }
    
    
    func updateDefinitionAt(position: GridPosition, with followingNumber: Int) throws {
        guard position.row < grid.numberOfRows && position.row >= 0 else {
            throw ComboError.rowOutOfBounds
        }
        guard position.column < grid.numberOfColumns && position.column >= 0 else {
            throw ComboError.columnOutOfBounds
        }
        
        grid.setTileGroup(tileGroupFor(tile: tileForValue(value: followingNumber)), forColumn: position.column, row: position.row)
    }
    
    
    
    
    func tileForValue(value : Int) -> Tile {
        switch value {
        case -1:
            return Tile.selected
        case 1:
            return Tile.one
        case 2:
            return Tile.two
        case 3:
            return Tile.three
        case 4:
            return Tile.four
        case 5:
            return Tile.five
        case 6:
            return Tile.six
        case 7:
            return Tile.seven
        case 8:
            return Tile.eight
        case 9:
            return Tile.nine
        case 10:
            return Tile.ten
        case 11:
            return Tile.eleven
        default:
            return Tile.twelve
        }
    }
    
    func resetNumbers() {
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                grid.setTileGroup(nil, forColumn: column, row: row)
            }
        }
    }
    
    func disposeRandomNumbers() throws {
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    _ = try self.tileDefinitionAt(position: gridPosition)
                } catch let error as ComboError where error == .noDefinitionAtPosition {
                    try self.createTileAt(position: gridPosition, with: randomTileValue())
                }
            }
        }
    }
    
    func createFollowingNumber(_ number: Int, position : GridPosition) -> GridPosition? {
        
        var newRow = -1
        while newRow < 2  {
            do {
                let gridPosition = GridPosition(row: position.row + newRow, column: position.column)
                do {
                    try tileDefinitionForEitherEqualValueOrNullAt(position: gridPosition, with: number)
                } catch let error as ComboError where error == .noDefinitionAtPosition {
                    try createTileAt(position: gridPosition, with: number)
                }
                print("position \(gridPosition), number \(number)")
                return gridPosition
            }
            catch let error {
                print("hmm what's up here ? \(error) row : \(position.row) column : \(position.column)")
            }
            var newColumn = -1
            while newColumn < 2  {
                do {
                    let gridPosition = GridPosition(row: position.row + newRow, column: position.column + newColumn)
                    do {
                        try tileDefinitionForEitherEqualValueOrNullAt(position: gridPosition, with: number)
                    } catch let error as ComboError where error == .noDefinitionAtPosition {
                        try createTileAt(position: gridPosition, with: number)
                    }
                    print("position \(gridPosition), number \(number)")
                    return gridPosition
                } catch {
                    print("\(error) row : \(position.row) column : \(position.column)")
                }
                newColumn += 1
            }
            newRow += 1
        }
        return nil
    }
    
    
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func randomTileValue() -> Int {
        return randomInt(min: 0, max: 12)
    }
    
    func randomGridPosition() -> GridPosition {
        var gridPosition: GridPosition
        gridPosition.row = randomInt(min: 0, max: grid.numberOfRows - 1)
        gridPosition.column = randomInt(min: 0, max: grid.numberOfColumns - 1)
        return gridPosition
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
    func checkBoard() throws
}


extension GridController : GridValidator {
    
    func checkBoard() throws {
        _ = try self.possibility()
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
            throw ComboError.noMorePossibilities
        }
        return pile!
    }
    
    func possibilitiesForPile(_ pile: Pile) throws {
        
        var array = [TileInformation]()
        
        for row in 0..<grid.numberOfRows {
            for column in 0..<grid.numberOfColumns {
                if let definition = grid.tileDefinition(atColumn: column, row: row) , let value = definition.userData?.value(forKey: "value") as? Int , value == pile.followingNumber() {
                    let tileInformation = TileInformation((row, column), definition)
                    array.append(tileInformation)
                }
            }
            //            array.append(contentsOf: matrix[row].filter { pile.followingNumber() == $0.value })
        }
        print("pile.followingNumber :: \(pile.followingNumber())")
        
        print("array :: \(array)")
        
        
        let possibilities = (array.filter { do { return try adjacentForTile($0) != nil } catch { return false } })
        
        print(possibilities)
        
        guard possibilities.isEmpty == false else {
            throw ComboError.noMorePossibilities
        }
    }
    
    
    func adjacentForTile(_ tile : TileInformation) throws  -> SKTileDefinition? {
        var row = -1
        while row < 2 {
            var column = -1
            while column < 2 {
                let gridPosition = (tile.gridPosition.row + row, tile.gridPosition.column + column)
                
                
                    guard let number =  tile.definition.userData?.value(forKey: "value") as? Int else {
                        fatalError("it shoul have a number")
                    }
                    do {
                        
                        try self.tileDefinitionForEitherEqualValueOrNullAt(position: gridPosition, with: number.followingNumber())
                        
                        if let tile = try self.tileDefinitionAt(position: gridPosition) {
                            
                            print(gridPosition)
                            
                            print(number.followingNumber())
                            
                            return tile
                            
                        }
                        
                    } catch {
                        
                    }

                column += 1

            }
            row += 1
        }
        return nil
    }
    
    
}
