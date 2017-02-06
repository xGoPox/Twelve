//
//  GameScene.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/22/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit
import GameplayKit

enum TwelveError: Error {
    case numberIsNotFollowingPile
    case lastNumberIsNill
    case matchedPileIsNill
    case gridHasNoPile
    case falseCombo
    case notAdjacent
    case noMorePossibilities
    case outOfBounds
    case noNumberAtPosition
    case noNeedToCreateNumber
    case columnOutOfBounds
    case numberIsNotEqualWithFollowingNumber
    case tileDefinitionAsNotValue
    case noTileGroupAtPosition
}




class GameScene: SKScene {
    
    //    var entities = [GKEntity]()
    //    var graphs = [String : GKGraph]()
    
    var numberTile: NumberSpriteNode?
    var gridDispatcher = GridController()
    var combo: Combo?
    var objectsTileMap:SKTileMapNode!
    var scoreNode: ScoreNode?
    var gameStarted = false {
        willSet(started) {
            if started {
                totalPoints = 0
                isDeckMenuHidden(false)
                isMainMenuHidden(true)
                isTopBarHidden(false)
                startTimer()
            } else {
                update(score: totalPoints)
                isTopBarHidden(true)
                isScoreHidden(false)
                isEndMenuHidden(false)
                isDeckMenuHidden(true)
                endsCombo()
            }
        }
    }
    
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
        prepareGame()
    }
    
    
    func setupObjects() {
        guard let map = childNode(withName: "Tile Map Node")
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        self.objectsTileMap = map
        combo = Combo.init(lastNumber: nil, combo: [Int](), currentPile: gridDispatcher.pileForNumber(12))
        fullfillBoard()
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
        if let targetNode = atPoint(touch.location(in: self)) as? RestartSpriteNode , targetNode.name == "restartNode" {
            prepareGame()
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
        
        let location = touch.location(in: self)
        
        if let number = atPoint(location) as? NumberSpriteNode {
            do {
                numberTile?.alpha = 1
                try detect(number)
                number.alpha = 0
            } catch let error as TwelveError where error == .notAdjacent || error == .numberIsNotFollowingPile  {
                endsCombo()
            } catch {
                numberTile = nil
            }
        }
    }
    
    func detect(_ tile : NumberSpriteNode) throws {
        
        if let prevNumber = numberTile , prevNumber.gridPosition == tile.gridPosition {
            return
        }
        
        if let previousTileSelected = numberTile {
            try gridDispatcher.isTile(previousTileSelected, adjacentWith: tile)
        }
        try addToCombo(number: tile)
    }
    
    
    
    private func addToCombo(number: NumberSpriteNode) throws {
                
        if let pile = combo?.currentPile {
            try combo?.addUpComboWith(number: number.value, on: pile)
        } else if let pile = gridDispatcher.pileForNumber(number.value) {
            try combo?.addUpComboWith(number: number.value, on: pile)
        } else {
            throw TwelveError.numberIsNotFollowingPile
        }
        
        if let numbers = combo?.combo, numbers.count > 1 {
            
            guard let previousNumber = numberTile else {
                fatalError("it should have a tile!")
            }
            
            try gridDispatcher.updateNumberAt(position: previousNumber.gridPosition, with: gridDispatcher.randomTileValue())

            if !gameStarted {
                gameStarted = true
            }
        }
        
        numberTile = number
    }
    
    
    func endsCombo() {
        
        guard let previousNumber = numberTile else {
            return
        }
        
        previousNumber.alpha = 1

        do {
            let points = try combo?.doneWithCombo() ?? 0
            totalPoints += points
            try gridDispatcher.updateNumberAt(position: previousNumber.gridPosition, with: gridDispatcher.randomTileValue())
            numberTile = nil
            gridDispatcher.checkBoard()
        } catch  {
            numberTile = nil
            gridDispatcher.checkBoard()
        }
    }
    
  
    
    func startTimer() {
        
        var levelTimerValue = 10
        
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
                self.gameStarted = false
                label.removeAction(forKey: "countdown")
            }
        }
        label.run(SKAction.sequence([wait, run]))
        label.run(SKAction.repeatForever(SKAction.sequence([wait, run])) , withKey: "countdown")
    }
    
}


extension GameScene {
    
    
    func isDeckMenuHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "decks")
            as? SKSpriteNode else {
                fatalError("decks node not loaded")
        }
        node.isHidden = hidden
    }
    
    
    func resetPiles() {
        gridDispatcher.resetPiles()
        try? gridDispatcher.resetNumbers()
        try? gridDispatcher.disposeNumbers()
    }
    
    func prepareGame() {
        totalPoints = 0
        isEndMenuHidden(true)
        isScoreHidden(true)
        resetPiles()
        isMainMenuHidden(false)
        isTopBarHidden(true)
    }
    
}

extension GameScene  {
    
    
    func isMainMenuHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "menu_sprite")
            as? SKSpriteNode else {
                fatalError("menu_sprite node not loaded")
        }
        node.isHidden = hidden
    }

    
    func isScoreHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "endScoreSprite")
            as? SKSpriteNode else {
                fatalError("endScoreSprite node not loaded")
        }
        node.isHidden = hidden
    }
    
    func update(score : Int) {
        guard let node = childNode(withName: "endScoreSprite")
            as? SKSpriteNode else {
                fatalError("endScoreSprite node not loaded")
        }
        guard let scoreNode = node.childNode(withName: "score")
            as? EndScoreNode else {
                fatalError("scoreNode node not loaded")
        }
        scoreNode.score = score
    }
    
    
    
    func isTopBarHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "topBarNode")
            as? SKSpriteNode else {
                fatalError("topBarNode node not loaded")
        }
        node.isHidden = hidden
    }
    
    func isEndMenuHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "menuEndGameSprite")
            as? SKSpriteNode else {
                fatalError("menuEndGameSprite node not loaded")
        }
        
        node.isHidden = hidden
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



