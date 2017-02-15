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
    var progressBar: ProgressBar?
    
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
            self.progressBar?.decrease()
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
        
        guard let nodeProgressBar = childNode(withName: "progressBar")
            as? ProgressBar else {
                fatalError("comboBarTop node not loaded")
        }
        
        
        
        progressBar = nodeProgressBar
        
        objectsTileMap = map
        
        combo = Combo.init(lastNumber: nil, combo: [Int](), currentPile: gridDispatcher.pileForNumber(12))
        fullfillBoard()
        
        objectsTileMap.addChild(line)
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
    
    var line = SKShapeNode()
    
    func drawLine(endingPoint: CGPoint) {
        if let number = numberTile , gridDispatcher.freezed == false {
            let path = CGMutablePath()
            path.move(to: number.position)
            path.addLine(to: CGPoint(x: endingPoint.x, y:endingPoint.y))
            line.zPosition = 1
            line.path = path
            line.strokeColor = number.colorType.withAlphaComponent(0.5)
            line.lineWidth = 20
        } else {
            line.path = nil
        }
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if gridDispatcher.freezed == false {
            analyzeTouch(touch)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        if atPoint(touch.location(in: self)).name == "Restart" {
            prepareGame()
        }
        else {
            let location = touch.location(in: self)
            if let number = (nodes(at: location).filter { $0 is NumberSpriteNode }).first as? NumberSpriteNode {
                do {
                    if gridDispatcher.freezed == false {
                        numberTile?.unselected()
                        try detect(number)
                        gridDispatcher.cancelSolution()
                        numberTile?.selected()
                    } else {
                        try addToCombo(number: number)
                    }
                } catch let error as TwelveError where error == .notAdjacent || error == .numberIsNotFollowingPile  {
                    let action = SKAction.screenShakeWithNode(number, amount: CGPoint(x:8, y:8), oscillations: 20, duration: 0.50)
                    number.run(action, completion: {
                        self.endsCombo()
                    })
                } catch {
                    numberTile = nil
                    line.path = nil
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        line.path = nil
        endsCombo()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        analyzeTouch(touch)
    }
    
    func analyzeTouch(_ touch: UITouch) {
        
        if  numberTile != nil {
            drawLine(endingPoint: touch.location(in: self.objectsTileMap))
        }
        
        let location = touch.location(in: self)
        if let number = (nodes(at: location).filter { $0 is NumberSpriteNode }).first as? NumberSpriteNode {
            
            guard let prevNumber = numberTile , prevNumber.gridPosition != number.gridPosition else {
                return
            }
            
            do {
                numberTile?.unselected()
                try detect(number)
                gridDispatcher.cancelSolution()
                numberTile?.selected()
            } catch let error as TwelveError where error == .notAdjacent || error == .numberIsNotFollowingPile  {
                numberTile = nil
                line.path = nil
                let action = SKAction.screenShakeWithNode(number, amount: CGPoint(x:5, y:5), oscillations: 20, duration: 0.50)
                number.run(action, completion: {
                    self.endsCombo()
                })
            } catch {
                numberTile = nil
                line.path = nil
            }
        }
        
    }
    
    func detect(_ number : NumberSpriteNode) throws {
        if let prevNumber = numberTile {
            try gridDispatcher.isTile(prevNumber, adjacentWith: number)
        }
        try addToCombo(number: number)
    }
    
    
    
    private func addToCombo(number: NumberSpriteNode) throws {
        
        if let pile = combo?.currentPile {
            try combo?.addUpComboWith(number: number.value, on: pile)
        } else if let pile = gridDispatcher.pileForNumber(number.value) {
            try combo?.addUpComboWith(number: number.value, on: pile)
        } else {
            throw TwelveError.numberIsNotFollowingPile
        }
        
        if let numbers = combo?.combo, numbers.count > 1 && gridDispatcher.freezed == false {
            
            guard let previousNumber = numberTile else {
                fatalError("it should have a tile!")
            }
            
            try gridDispatcher.updateNumberAt(position: previousNumber.gridPosition, with: gridDispatcher.randomTileValue())
            
            //  if numbers.count > 2 {
            //      addSecond()
            // }
            
            if !gameStarted {
                gameStarted = true
            }
        }
        
        numberTile = number
    }
    
    
    func newPileAdded() {
        if progressBar?.increaseAndHasGivenBonus() == true {
            
            if let action = timeLabel?.action(forKey: "countdown") {
                action.speed = 0
            }
            
            progressBar?.value = 0
            
            let colorizeUp = SKAction.colorize(with: .black, colorBlendFactor: 1, duration: 0.25)
            //            let colorizeDown = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.25)
            //            let sequences = SKAction.sequence([colorizeUp])
            
            
            run(colorizeUp, completion: {
                
                self.gridDispatcher.freezed = true
                
                self.afterDelay(10, runBlock: {
                    let colorizeDown = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.25)
                    self.gridDispatcher.freezed = false
                    self.run(colorizeDown, completion: {
                        if let action = self.timeLabel?.action(forKey: "countdown") {
                            action.speed = 1
                        }
                    })
                })
                
            })
            
        }
    }
    
    
    
    
    func endsCombo() {
        
        numberTile?.unselected()
        do {
            if let comboResult = try combo?.doneWithCombo(frozenMode: gridDispatcher.freezed) {
                gridDispatcher.freezed ? addSecond() : addPointsForCombo(comboResult)
                if gridDispatcher.freezed == false {
                    for _ in 0..<comboResult.numberOfTwelve {
                        newPileAdded()
                    }
                }
                if let prevNumber = numberTile {
                    try gridDispatcher.updateNumberAt(position: prevNumber.gridPosition, with: gridDispatcher.randomTileValue())
                }
                numberTile = nil
                line.path = nil
                checkBoard()
            }
        } catch  {
            numberTile = nil
            line.path = nil
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
        
        /*        if comboBar == nil {
         guard let node = childNode(withName: "comboBar")
         as? ComboBar else {
         fatalError("comboBar node not loaded")
         }
         comboBar = node
         }
         
         comboBar?.value = 0*/
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
        
        let points = comboResult.points
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
    
    func addSecond() {
        
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


extension UIColor {
    
    static var myGreen: UIColor  { return UIColor(red: 34/255, green: 181/255.0, blue: 115/255.0, alpha: 1) }
    static var myRed: UIColor { return UIColor(red: 217/255.0, green: 83/255.0, blue: 79/255.0, alpha: 1) }
    static var myBlue: UIColor { return UIColor(red: 66/255.0, green: 139/255.0, blue: 202/255.0, alpha: 1) }
    static var myYellow: UIColor { return UIColor(red: 240/255.0, green: 173/255.0, blue: 78/255.0, alpha: 1) }
    static var myBackgroundColor : UIColor { return UIColor(red:252/255, green:252/255, blue:252/255, alpha: 1) }
    
}

