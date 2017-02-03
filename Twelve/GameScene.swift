//
//  GameScene.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/22/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ComboError: Error {
    case numberIsNotFollowingPile
    case lastNumberIsNill
    case matchedPileIsNill
    case gridHasNoPile
    case falseCombo
    case notAdjacent
    case noMorePossibilities
    case rowOutOfBounds
    case columnOutOfBounds
    case numberIsNotEqualWithFollowingNumber
    case tileDefinitionAsNotValue
    case noDefinitionAtPosition
    
    
}


enum Tile: String {
    case selected = "Selected"
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
}




class GameScene: SKScene {
    
    //    var entities = [GKEntity]()
    //    var graphs = [String : GKGraph]()
    
    typealias TileInformation = (gridPosition: GridPosition, definition: SKTileDefinition)
    
    var numberTile: TileInformation?
    var gridDispatcher = GridController()
    var combo: Combo?
    var objectsTileMap:SKTileMapNode!
    var scoreNode: ScoreNode?
    var gameStarted = false
    
    var totalPoints = 0 {
        willSet(number) {
            if let lbl = scoreNode {
                lbl.score = number
            }
            
            guard let node = childNode(withName: "topBarNode")
                as? SKSpriteNode else {
                    fatalError("menuEndGameSprite node not loaded")
            }
            
            guard let scoreNode = node.childNode(withName: "scoreNode")
                as? ScoreNode else {
                    fatalError("scoreNode node not loaded")
            }
            
            self.scoreNode = scoreNode
            self.scoreNode?.score = number
        }
    }
    
    override func didMove(to view: SKView) {
        setupObjects()
        showMenu()
        combo = Combo.init(lastNumber: nil, combo: [Int](), currentPile: gridDispatcher.pileForNumber(12))
        fullfillBoard()
    }
    
    
    func setupObjects() {
        guard let map = childNode(withName: "Tile Map Node")
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        self.objectsTileMap = map
    }
    
    func fullfillBoard() {
        guard let node = childNode(withName: "decks")
            as? SKSpriteNode else {
                fatalError("decks node not loaded")
        }
        let piles = node.children.filter {
            if let type = $0.userData?.value(forKey: "type") as? String , type == "deck" , $0 is Pile {
                return true
            }
            return false
            } as! [Pile]
        
        guard !piles.isEmpty else {
            print("piles array is empty!")
            return
        }
        gridDispatcher.fullfillGrid(objectsTileMap, with: piles)
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        analyzeTouch(touch)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if let targetNode = atPoint(touch.location(in: self)) as? SKSpriteNode , targetNode.name == "restartNode" {
            restartGame()
        }
        else {
            analyzeTouch(touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endsCombo()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        analyzeTouch(touch)
    }
    
    func analyzeTouch(_ touch: UITouch) {
        let location = touch.location(in: self.objectsTileMap)
        let row = self.objectsTileMap.tileRowIndex(fromPosition: location)
        let column = self.objectsTileMap.tileColumnIndex(fromPosition: location)
        print("row \(row) column \(column)")
        if let tile = self.objectsTileMap.tileDefinition(atColumn: column, row: row) {
            print("tile \(tile.userData?.value(forKey: "value") ?? "FUCK")")
            do {
                let tileInformation = (GridPosition(row, column), tile)
                try detect(tileInformation)
            } catch let error as ComboError where error == .notAdjacent || error == .numberIsNotFollowingPile  {
                endsCombo()
            } catch {
                numberTile = nil
            }
        }
    }
    
    func detect(_ tile : TileInformation) throws {
        
        if let prevNumber = numberTile , prevNumber.gridPosition == tile.gridPosition {
            return
        }
        
        if let previousTileSelected = numberTile {
            try isTile(previousTileSelected, adjacentWith: tile)
        }
        
        try addToCombo(number: tile)
        
        objectsTileMap.setTileGroup(nil, forColumn: numberTile!.gridPosition.column, row: numberTile!.gridPosition.row)
    }
    
    
    func isTile(_ currentTile: TileInformation, adjacentWith tile: TileInformation) throws {
        var row = -1
        var column = -1
        
        while row < 2 {
            column = -1
            while column < 2 {
                if currentTile.gridPosition.column == tile.gridPosition.column + column && currentTile.gridPosition.row == tile.gridPosition.row + row {
                    return
                }
                column += 1
            }
            row += 1
        }
        throw ComboError.notAdjacent
    }
    
    private func addToCombo(number: TileInformation) throws {
        guard let value = number.definition.userData?.value(forKey: "value") as? Int else {
            throw ComboError.tileDefinitionAsNotValue
        }
        
        print("value : \(value)")
        if let pile = combo?.currentPile {
            try combo?.addUpComboWith(number: value, on: pile)
        } else if let pile = gridDispatcher.pileForNumber(value) {
            try combo?.addUpComboWith(number: value, on: pile)
        } else {
            throw ComboError.numberIsNotFollowingPile
        }
        
        if let numbers = combo?.combo, numbers.count > 1 {
            
            guard let previousTileSelected = numberTile else {
                fatalError("it should have a tile!")
            }
            try gridDispatcher.updateDefinitionAt(position: previousTileSelected.gridPosition, with: gridDispatcher.randomTileValue())
            if !gameStarted {
                startGame()
            }
        }
        
        numberTile = number
    }
    
    
    func endsCombo() {
        
        guard let prevNumber = numberTile ,  let value = prevNumber.definition.userData?.value(forKey: "value") as? Int else {
            
            return
        }
        
        objectsTileMap.setTileGroup(gridDispatcher.tileGroupFor(tile: gridDispatcher.tileForValue(value: value)), forColumn: prevNumber.gridPosition.column, row: prevNumber.gridPosition.row)

        do {
            let points = try combo?.doneWithCombo() ?? 0
            totalPoints += points
            guard let previousTileSelected = numberTile else {
                fatalError("it should have a tile!")
            }
            _ = try gridDispatcher.tileDefinitionAt(position: previousTileSelected.gridPosition)
            try gridDispatcher.createTileAt(position: previousTileSelected.gridPosition, with: gridDispatcher.randomTileValue())
            numberTile = nil
            do {
                try gridDispatcher.checkBoard()
            } catch let error as ComboError where error == .noMorePossibilities {
                gridDispatcher.resetNumbers()
                try? gridDispatcher.disposeNumbers()
            } catch {
                
            }
        } catch  {
            numberTile = nil
            do {
                try gridDispatcher.checkBoard()
            } catch let error as ComboError where error == .noMorePossibilities {
                gridDispatcher.resetNumbers()
                try? gridDispatcher.disposeNumbers()
            } catch {
                
            }
        }
    }
    
    
    
    
    func showMenu() {
        gameStarted = false
        guard let node = childNode(withName: "menu_sprite")
            as? SKSpriteNode else {
                fatalError("menu_sprite node not loaded")
        }
        
        node.isHidden = false
        hideTopBar()
        removeScore()
        removeEndGameMenu()
        endGame()
        removeDecks()
    }
    
    func removeMenu() {
        guard let node = childNode(withName: "menu_sprite")
            as? SKSpriteNode else {
                fatalError("menu_sprite node not loaded")
        }
        node.isHidden = true
    }
    
    func startGame() {
        gameStarted = true
        guard let node = childNode(withName: "decks")
            as? SKSpriteNode else {
                fatalError("decks node not loaded")
        }
        removeMenu()
        node.isHidden = false
        showTopBar()
        startTimer()
    }
    
    func startTimer() {
        
        var levelTimerValue = 60
        
        guard let node = childNode(withName: "topBarNode")
            as? SKSpriteNode else {
                fatalError("topBarNode node not loaded")
        }
        guard let label = node.childNode(withName: "timerLabel")
            as? SKLabelNode else {
                fatalError("timerLabel node not loaded")
        }
        
        label.text = String("time left : \(levelTimerValue)")
        
        let wait = SKAction.wait(forDuration: 1)
        let run = SKAction.run {
            if levelTimerValue > 0 {
                levelTimerValue -= 1
                label.text = String("time left : \(levelTimerValue)")
            } else {
                label.removeAction(forKey: "countdown")
                self.endsCombo()
                self.showScore(self.totalPoints)
            }
        }
        label.run(SKAction.sequence([wait, run]))
        
        label.run(SKAction.repeatForever(SKAction.sequence([wait, run])) , withKey: "countdown")
        
    }
    
    func removeScore() {
        guard let node = childNode(withName: "endScoreSprite")
            as? SKSpriteNode else {
                fatalError("endScoreSprite node not loaded")
        }
        node.isHidden = true
    }
    
    func showScore(_ score: Int) {
        guard let node = childNode(withName: "endScoreSprite")
            as? SKSpriteNode else {
                fatalError("endScoreSprite node not loaded")
        }
        guard let scoreNode = node.childNode(withName: "score")
            as? EndScoreNode else {
                fatalError("scoreNode node not loaded")
        }
        node.isHidden = false
        hideTopBar()
        scoreNode.score = score
        showEndGameMenu()
        removeDecks()
    }
    
    func showEndGameMenu() {
        guard let node = childNode(withName: "menuEndGameSprite")
            as? SKSpriteNode else {
                fatalError("menuEndGameSprite node not loaded")
        }
        
        node.isHidden = false
        objectsTileMap.isHidden = true
    }
    
    func removeEndGameMenu() {
        guard let node = childNode(withName: "menuEndGameSprite")
            as? SKSpriteNode else {
                fatalError("menuEndGameSprite node not loaded")
        }
        node.isHidden = true
    }
    
    func restartGame() {
        objectsTileMap.isHidden = false
        totalPoints = 0
        removeEndGameMenu()
        removeScore()
        resetPiles()
        showMenu()
    }
    
    func showTopBar() {
        guard let node = childNode(withName: "topBarNode")
            as? SKSpriteNode else {
                fatalError("topBarNode node not loaded")
        }
        node.isHidden = false
    }
    
    func hideTopBar() {
        guard let node = childNode(withName: "topBarNode")
            as? SKSpriteNode else {
                fatalError("topBarNode node not loaded")
        }
        node.isHidden = true
    }
    
    
    func resetPiles() {
        gridDispatcher.resetPiles()
        gridDispatcher.resetNumbers()
        try? gridDispatcher.disposeNumbers()
    }
    
    
    
    func endGame() {
        fullfillBoard()
    }
    
    func removeDecks() {
        guard let node = childNode(withName: "decks")
            as? SKSpriteNode else {
                fatalError("decks node not loaded")
        }
        node.isHidden = true
    }
    
    
}



extension Int {
    func followingNumber() -> Int {
        if self == 12  {
            return 1
        }
        return self + 1
    }
}



