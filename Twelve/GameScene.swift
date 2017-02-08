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
                updateTotal(score: totalPoints)
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
            } else {
                
                guard let scoreNode = childNode(withName: "scoreNode")
                    as? ScoreNode else {
                        fatalError("scoreNode node not loaded")
                }
                self.scoreNode = scoreNode
                self.scoreNode?.score = number
            }
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
        
        var piles = [Pile]()
        for child in children {
            if let type = child.userData?.value(forKey: "type") as? String , type == "pile" {
                let pile = Pile()
                child.addChild(pile)
                piles.append(pile)
            }
        }
        
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
        if let number = (nodes(at: location).filter { $0 is NumberSpriteNode }).first as? NumberSpriteNode {
            do {
                
                let scaleBack = SKAction.scaleX(to: 1, y: 1,
                                            duration: 0.25, delay: 0,
                                            usingSpringWithDamping: 0.25, initialSpringVelocity: 0)
                numberTile?.run(scaleBack)
                try detect(number)
                let scale = SKAction.scaleX(to: 0, y: 0,
                                            duration: 0.25, delay: 0,
                                            usingSpringWithDamping: 0.25, initialSpringVelocity: 0)
                numberTile?.run(scale)
            } catch let error as TwelveError where error == .notAdjacent || error == .numberIsNotFollowingPile  {
               let action = SKAction.screenShakeWithNode(number, amount: CGPoint(x:15, y:15), oscillations: 20, duration: 0.50)
                number.run(action, completion: {
                    self.endsCombo()
                })
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
        let scaleBack = SKAction.scaleX(to: 1, y: 1,
                                        duration: 0.25, delay: 0,
                                        usingSpringWithDamping: 0.2, initialSpringVelocity: 0)
        numberTile?.run(scaleBack)
        do {
            let points = try combo?.doneWithCombo() ?? 0
            totalPoints += points
            if let prevNumber = numberTile {
                try gridDispatcher.updateNumberAt(position: prevNumber.gridPosition, with: gridDispatcher.randomTileValue())
            }
            numberTile = nil
            checkBoard()
        } catch  {
            numberTile = nil
            checkBoard()
        }
    }
    
    func checkBoard() {
        do {
            try gridDispatcher.checkBoard()
        } catch let error as TwelveError where error == .noMorePossibilities {
            

            for row in 0..<objectsTileMap.numberOfRows {
                for column in 0..<objectsTileMap.numberOfColumns {
                    let gridPosition = GridPosition(row, column)
                    do {
                        if let number = try gridDispatcher.numberAt(position: gridPosition) {
                            let scaleSmall = SKAction.scaleX(to: 0, y: 0,
                                                             duration: 0.25, delay: 0,
                                                             usingSpringWithDamping: 0.25, initialSpringVelocity: 0)
                            number.run(scaleSmall)
                        }
                    } catch {  }
                }
            }
            
            try? self.gridDispatcher.resetNumbers()
            try? self.gridDispatcher.disposeNumbers()
            
            afterDelay(0.15, runBlock: {
                
                for row in 0..<self.objectsTileMap.numberOfRows {
                    for column in 0..<self.objectsTileMap.numberOfColumns {
                        let gridPosition = GridPosition(row, column)
                        do {
                            if let number = try self.gridDispatcher.numberAt(position: gridPosition) {
                                let scaleSmall = SKAction.scaleX(to: 1, y: 1,
                                                                 duration: 0.25, delay: 0,
                                                                 usingSpringWithDamping: 0.25, initialSpringVelocity: 0)
                                number.run(scaleSmall)
                            }
                        } catch {  }
                    }
                }
                
            })
            
            
            
        } catch {
            fatalError("checkBoard exception should have been caught")
        }

    }
    
    
  /*  func flip() {
        
        let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: 0.4)
        let secondHalfFlip = SKAction.scaleX(to: 1.0, duration: 0.4)
        
        setScale(1.0)
        
        if faceUp {
            run(firstHalfFlip) {
                self.texture = self.backTexture
                self.damageLabel.isHidden = true
                
                self.run(secondHalfFlip)
            }
        } else {
            run(firstHalfFlip) {
                self.texture = self.frontTexture
                self.damageLabel.isHidden = false
                
                self.run(secondHalfFlip)
            }
        }
        faceUp = !faceUp
    }

    */
    
    func startTimer() {
        
        var levelTimerValue = 60
        
        guard let label = childNode(withName: "timerNode")
            as? SKLabelNode else {
                fatalError("topBarNode node not loaded")
        }
        
        label.text = String(levelTimerValue)
        
        let wait = SKAction.wait(forDuration: 1)
        let run = SKAction.run {
            if levelTimerValue > 0 {
                levelTimerValue -= 1
                label.text = String(levelTimerValue)
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
    
    
    func isDeckMenuHidden(_ hidden: Bool) {
        _ = gridDispatcher.piles.map { $0.isHidden = hidden }
    }
    
    
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
    
    func updateTotal(score : Int) {
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
        guard let score = childNode(withName: "scoreNode")
            as? SKSpriteNode else {
                fatalError("scoreNode node not loaded")
        }
        guard let timer = childNode(withName: "timerNode") else {
            fatalError("timerNode node not loaded")
        }
        timer.isHidden = hidden
        score.isHidden = hidden
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



