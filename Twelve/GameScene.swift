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


enum GameType {
    case surviror
    case points
}


class GameScene: SKScene {
    
    //    var entities = [GKEntity]()
    //    var graphs = [String : GKGraph]()
    var multiCombo: Multiplicator!
    var comboBar: ComboBar?
    var gameType: GameType = .surviror
    var numberTile: NumberSpriteNode?
    var gridDispatcher = GridController()
    var combo: Combo?
    var objectsTileMap:SKTileMapNode!
    var scoreNode: ScoreNode?
    var timeLabel: SKLabelNode?
    var levelTimerValue = 60 {
        willSet(newValue) {
            timeLabel?.text = String(newValue)
            comboBar?.value = Double(newValue)
        }
    }
    
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
                showGameOver(true)
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
                
                guard let topBar = childNode(withName: "topBar")
                    as? SKSpriteNode else {
                        fatalError("topBar node not loaded")
                }

                guard let scoreNode = topBar.childNode(withName: "scoreNode")
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
        guard let topBar = childNode(withName: "topBar")
            as? SKSpriteNode else {
                fatalError("topBar node not loaded")
        }
        
        guard let node = topBar.childNode(withName: "multiplicatorParent")
            as? Multiplicator else {
                fatalError("multiplicatorParent node not loaded")
        }
        
        multiCombo = node
        objectsTileMap = map
        
        combo = Combo.init(lastNumber: nil, combo: [Int](), currentPile: gridDispatcher.pileForNumber(12))
        fullfillBoard()
    }
    
    func fullfillBoard() {
        
        guard let bottomBar = childNode(withName: "bottomBar")
            as? SKSpriteNode else {
                fatalError("bottomBar node not loaded")
        }
        
        var piles = [Pile]()
        for child in bottomBar.children {
            if child.name == "pile" {
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
        if atPoint(touch.location(in: self)).name == "Restart" {
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
                if let prevNumber = numberTile , prevNumber.gridPosition == number.gridPosition {
                    return
                }
                numberTile?.haloShape.setScale(1)
                numberTile?.haloShape.removeAction(forKey: "selected")
                try detect(number)
                gridDispatcher.cancelSolution()
                let pulseUp = SKAction.scale(to: 1.3, duration: 0.20)
                let pulseDown = SKAction.scale(to: 1, duration: 0.20)
                let pulse = SKAction.sequence([pulseUp, pulseDown])
                let repeatAction = SKAction.repeatForever(pulse)
                numberTile?.haloShape.run(repeatAction , withKey: "selected")
                //numberTile?.alpha = 0
            } catch let error as TwelveError where error == .notAdjacent || error == .numberIsNotFollowingPile  {
                let action = SKAction.screenShakeWithNode(number, amount: CGPoint(x:5, y:5), oscillations: 20, duration: 0.50)
                number.run(action, completion: {
                    self.endsCombo()
                })
            } catch {
                numberTile = nil
            }
        }
    }
    
    func detect(_ tile : NumberSpriteNode) throws {
        
        
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
            
            if previousNumber.value == 12 {
                print("BOUM ++! YEAH")
                multiCombo.value = (multiCombo.value + 1 > 4) ? 4 : (multiCombo.value + 1.5)
            }
            
            try gridDispatcher.updateNumberAt(position: previousNumber.gridPosition, with: gridDispatcher.randomTileValue())
            
            if numbers.count > 2 {
                addSecondForCombo()
            }
            
            if !gameStarted {
                gameStarted = true
            }
        }
        
        numberTile = number
    }
    
    
    func endsCombo() {
        
        numberTile?.haloShape.setScale(1)
        numberTile?.haloShape.removeAction(forKey: "selected")
        do {
            if let comboResult = try combo?.doneWithCombo() {
                addPointsForCombo(comboResult)
                if let prevNumber = numberTile {
                    if prevNumber.value == 12 {
                        print("BOUM ++! OHHH")
                        multiCombo.value = (multiCombo.value + 1 > 4) ? 4 : (multiCombo.value + 1.5)
                    }
                    try gridDispatcher.updateNumberAt(position: prevNumber.gridPosition, with: gridDispatcher.randomTileValue())
                }
                numberTile = nil
                checkBoard()
            }
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
                            let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: 0.1)
                            let secondHalfFlip = SKAction.scaleX(to: 1.0, duration: 0.1)
                            let action = SKAction.sequence([firstHalfFlip, secondHalfFlip])
                            number.run(action)
                        }
                    } catch {  }
                }
            }

            try? self.gridDispatcher.resetNumbers()
            try? self.gridDispatcher.disposeNumbers()
            
            
        } catch {
            fatalError("checkBoard exception should have been caught")
        }
        
    }
    
    
    
    func startTimer() {
        
        if comboBar == nil {
            guard let node = childNode(withName: "comboBar")
                as? ComboBar else {
                    fatalError("comboBar node not loaded")
            }
            comboBar = node
        }

        comboBar?.value = 0
        levelTimerValue = 60
        
        if timeLabel == nil {
            guard let topBar = childNode(withName: "topBar")
                as? SKSpriteNode else {
                    fatalError("topBarNode node not loaded")
            }
            guard let label = topBar.childNode(withName: "timerNode")
                as? SKLabelNode else {
                    fatalError("timerNode node not loaded")
            }
            timeLabel = label
        
        }
        
        
        let wait = SKAction.wait(forDuration: 1)
        let run = SKAction.run {
            if self.levelTimerValue > 0 {
                self.levelTimerValue -= 1
                let newValue = self.multiCombo.value - 0.1
                self.multiCombo.value = newValue >= 0 ? newValue : 0
            } else {
                self.gameStarted = false
                self.timeLabel?.removeAction(forKey: "countdown")
            }
        }
        timeLabel?.run(SKAction.repeatForever(SKAction.sequence([wait, run])) , withKey: "countdown")
    }
    
}


extension GameScene {
    
    func addPointsForCombo(_ comboResult : ComboResult) {
        
        let points = comboResult.points * multiCombo.multiplicator
        guard let label = childNode(withName: "newPointsLabel")
            as? SKLabelNode else {
                fatalError("newPointsLabel node not loaded")
        }
        label.text = "+" + String(points)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
        let scaleIn = SKAction.scale(to: 1.5, duration: 1)
        let group = SKAction.group([fadeIn, scaleIn])
        label.run(group) {
            label.alpha = 0
        }
        afterDelay(0.1) {
            self.totalPoints += points
        }
    }
    
    func addSecondForCombo() {
        
        levelTimerValue += 1
        if let label = timeLabel {
            let action = SKAction.screenZoomWithNode(label, amount: CGPoint(x:2, y:2), oscillations: 2, duration: 1)
            label.run(action)
        }
    }
}

extension GameScene {
    
    
    func resetPiles() {
        gridDispatcher.resetPiles()
        try? gridDispatcher.resetNumbers()
        try? gridDispatcher.disposeNumbers()
    }
    
    func prepareGame() {
        
        for row in 0..<self.objectsTileMap.numberOfRows {
            for column in 0..<self.objectsTileMap.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    if let number = try self.gridDispatcher.numberAt(position: gridPosition) {
                        let scaleDown = SKAction.scale(to: 0, duration: 0)
                        let scaleBack = SKAction.scale(to: 1, duration: 0.5)
                        let fade = SKAction.fadeIn(withDuration: 0.5)
                        let group = SKAction.group([scaleDown, scaleBack, fade])
                        number.run(group)
                    }
                } catch {  }
            }
        }
        
        totalPoints = 0
        isEndMenuHidden(true)
        resetPiles()
        isMainMenuHidden(false)
        isTopBarHidden(true)
    }
    
}

extension GameScene  {
    
    
    func isDeckMenuHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "bottomBar")
            as? SKSpriteNode else {
                fatalError("bottomBar node not loaded")
        }
        node.isHidden = hidden
    }
    
    func isMainMenuHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "menu_sprite")
            as? SKSpriteNode else {
                fatalError("menu_sprite node not loaded")
        }
        node.isHidden = hidden
    }
    
    
    func updateTotal(score : Int) {
        guard let node = childNode(withName: "menuEndGameSprite")
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
        guard let topBar = childNode(withName: "topBar")
            as? SKSpriteNode else {
                fatalError("scoreNode node not loaded")
        }

        topBar.isHidden = hidden
    }
    
    func isEndMenuHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "menuEndGameSprite")
            as? SKSpriteNode else {
                fatalError("menuEndGameSprite node not loaded")
        }
        
        node.isHidden = hidden
    }
    
    func showEndMenu() {
        guard let node = childNode(withName: "menuEndGameSprite")
            as? SKSpriteNode else {
                fatalError("menuEndGameSprite node not loaded")
        }
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = false
        self.isEndMenuHidden(false)
    }
    
    func showGameOver(_ show: Bool) {
        
        guard let node = childNode(withName: "gameOverSprite")
            as? SKSpriteNode else {
                fatalError("gameOverSprite node not loaded")
        }
        node.position = CGPoint(x: frame.minX, y: 0)
        node.isHidden = !show
        let moveShow = SKAction.moveTo(x: 0, duration: 0.15)
        let rotR = SKAction.rotate(byAngle: 0.15, duration: 0.1)
        let rotL = SKAction.rotate(byAngle: -0.15, duration: 0.1)
        let rotates = SKAction.sequence([rotR, rotL])
        let repeatAction = SKAction.repeat(rotates, count: 2)
        let rotateBack = SKAction.rotate(toAngle: 0, duration: 0.15)
        let cycle = SKAction.sequence([repeatAction, rotateBack])
        let wait = SKAction.wait(forDuration: 0.25)
        let moveHide = SKAction.moveTo(x: frame.maxX + node.size.width, duration: 0.15)
        let move = SKAction.sequence([moveShow, cycle, wait, moveHide])
        
        for row in 0..<self.objectsTileMap.numberOfRows {
            for column in 0..<self.objectsTileMap.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    if let number = try self.gridDispatcher.numberAt(position: gridPosition) {
                        let scale = SKAction.scale(to: 0.1, duration: 0.5)
                        let fade = SKAction.fadeOut(withDuration: 0.5)
                        let group = SKAction.group([scale, fade])
                        number.run(group)
                    }
                } catch {  }
            }
        }
        
        
        node.run(move, completion: {
            self.showEndMenu()
        })
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



