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



protocol Preparation {
    func fillUpMap()
}

protocol DrawLine {
    func drawLine(endingPoint: CGPoint)
}

extension GameScene : DrawLine {
    func drawLine(endingPoint: CGPoint) {
        if let number = numberTile {
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
}


extension GameScene : Preparation {
    
    
    func fillUpMap()  {
        do {
            let piles = try pilesAvailable()
            gridDispatcher = GridController(matrix: [[NumberSpriteNode]](), piles: piles, grid: objectsTileMap, currentSolution: nil, frozen: false)
            gridDispatcher.fullfillGrid()
            objectsTileMap.addChild(line)
        } catch let error as TwelveError where error == .gridHasNoPile {
            fatalError("no piles available on grid")
        } catch let error {
            print("unknown error \(error )")
        }
    }
    
}

class GameScene: SKScene {
    
    
    lazy var progressBar: ProgressBar = {
        guard let nodeProgressBar = self.childNode(withName: "progressBar")
            as? ProgressBar else {
                fatalError("comboBarTop node not loaded")
        }
        return nodeProgressBar
    }()
    
    lazy var objectsTileMap: SKTileMapNode = {
        guard let map = self.childNode(withName: "Tile Map Node")
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        return map
    }()
    
    lazy var scoreNode: ScoreNode = {
        guard let topBar = self.childNode(withName: "topBar")
            as? SKSpriteNode else {
                fatalError("topBar node not loaded")
        }
        
        guard let scoreNode = topBar.childNode(withName: "scoreNode")
            as? ScoreNode else {
                fatalError("scoreNode node not loaded")
        }
        return scoreNode
    }()
    
    
    lazy var timeLabel: SKLabelNode = {
        guard let topBar = self.childNode(withName: "topBar")
            as? SKSpriteNode else {
                fatalError("topBarNode node not loaded")
        }
        guard let label = topBar.childNode(withName: "timerNode")
            as? SKLabelNode else {
                fatalError("timerNode node not loaded")
        }
        return label
    }()
    
    
    
    var gridDispatcher : GridController!
    var gameType: GameType = .surviror
    var numberTile: NumberSpriteNode? {
        willSet(obj) {
            if let number = obj {
                gridDispatcher.cancelSolution()
                number.selected()
            } else {
                line.path = nil
            }
        }
    }
    
    
    lazy var combo: Combo = {
        return Combo(lastNumber: nil, numbers: [Int](), currentPile: self.gridDispatcher.pileForNumber(12))
    }()
    
    
    lazy var line: SKShapeNode = {
        return SKShapeNode()
    }()
    
    var timerValue = 60 {
        willSet(newValue) {
            timeLabel.text = String(newValue)
            self.progressBar.decrease()
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
                timeLabel.removeAction(forKey: "countdown")
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
            scoreNode.score = number
        }
    }
    
    override func didMove(to view: SKView) {
        fillUpMap()
        prepareGame()
    }
    

    
    
    func analyzeNumber(_ number: NumberSpriteNode) {
        
        do {
            try select(number)
        } catch  {
            numberTile = nil
            let action = SKAction.screenShakeWithNode(number, amount: CGPoint(x:5, y:5), oscillations: 20, duration: 0.50)
            number.run(action, completion: {
                self.endsCombo()
            })
        }
        
    }
    
    func select(_ number : NumberSpriteNode) throws  {
        numberTile?.unselected()
        if let prevNumber = numberTile {
            try gridDispatcher.isTile(prevNumber, adjacentWith: number)
        }
        try addToCombo(number: number)
    }
    
    
    
    private func addToCombo(number: NumberSpriteNode) throws {
        
        if let pile = combo.currentPile {
            try combo.addUpComboWith(number: number.value, on: pile)
        } else if let pile = gridDispatcher.pileForNumber(number.value) {
            try combo.addUpComboWith(number: number.value, on: pile)
        } else {
            throw TwelveError.numberIsNotFollowingPile
        }
        
        if combo.numbers.count > 1 && gridDispatcher.frozen == false {
            
            
            numberTile?.updateNumberValue()
            
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
        /*        if progressBar.increaseAndHasGivenBonus() == true {
         
         if let action = timeLabel.action(forKey: "countdown") {
         action.speed = 0
         }
         
         progressBar.value = 0
         
         let colorizeUp = SKAction.colorize(with: .black, colorBlendFactor: 1, duration: 0.25)
         //            let colorizeDown = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.25)
         //            let sequences = SKAction.sequence([colorizeUp])
         
         
         run(colorizeUp, completion: {
         
         self.gridDispatcher.frozen = true
         
         self.afterDelay(10, runBlock: {
         let colorizeDown = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.25)
         self.gridDispatcher.frozen = false
         self.run(colorizeDown, completion: {
         if let action = self.timeLabel.action(forKey: "countdown") {
         action.speed = 1
         }
         })
         })
         
         })
         
         }*/
    }
    
    
    
    
    func endsCombo() {
        
        numberTile?.unselected()
        do {
            let comboResult = try combo.doneWithCombo(frozenMode: gridDispatcher.frozen)
            gridDispatcher.frozen ? addSecond() : addPointsForCombo(comboResult)
            if gridDispatcher.frozen == false {
                for _ in 0..<comboResult.numberOfTwelve {
                    newPileAdded()
                }
            }
            numberTile?.updateNumberValue()
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
                    if let number = try? gridDispatcher.numberAt(position: gridPosition) {
                        let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: 0.1)
                        let secondHalfFlip = SKAction.scaleX(to: 1.0, duration: 0.1)
                        let action = SKAction.sequence([firstHalfFlip, secondHalfFlip])
                        number?.run(action)
                    }
                }
            }
            
            try? self.gridDispatcher.resetNumbers()
            try? self.gridDispatcher.disposeNumbers()
            
        } catch {
            fatalError("checkBoard exception should have been caught error : \(error)")
        }
        
    }
    
    
    func startTimer() {
        
        timerValue = 60
        
        let wait = SKAction.wait(forDuration: 1)
        let run = SKAction.run {
            if self.timerValue > 0 {
                self.timerValue -= 1
            } else {
                self.gameStarted = false
            }
        }
        
        timeLabel.run(SKAction.repeatForever(SKAction.sequence([wait, run])) , withKey: "countdown")
        
    }
    
}

extension GameScene {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endsCombo()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        if let number = (nodes(at: location).filter { $0 is NumberSpriteNode }).first as? NumberSpriteNode {
            guard let prevNumber = numberTile , prevNumber.gridPosition != number.gridPosition else {
                return
            }
            analyzeNumber(number)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if gridDispatcher.frozen == false {
            if numberTile != nil {
                drawLine(endingPoint: touch.location(in: self.objectsTileMap))
            }
            
            let location = touch.location(in: self)
            if let number = (nodes(at: location).filter { $0 is NumberSpriteNode }).first as? NumberSpriteNode {
                guard let prevNumber = numberTile , prevNumber.gridPosition != number.gridPosition else {
                    return
                }
                analyzeNumber(number)
            }
            
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
                analyzeNumber(number)
            }
        }
    }
}


extension GameScene {
    
    func addPointsForCombo(_ comboResult : ComboResult) {
        self.totalPoints += comboResult.points
    }
    
    func addSecond() {
        timerValue += 1
        let action = SKAction.screenZoomWithNode(timeLabel, amount: CGPoint(x:2, y:2), oscillations: 2, duration: 1)
        timeLabel.run(action)
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
    
    
    func pilesAvailable() throws -> [Pile] {
        
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
            throw TwelveError.gridHasNoPile
        }
        
        return piles
    }
    
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
                if let number = try? self.gridDispatcher.numberAt(position: gridPosition) {
                    let scale = SKAction.scale(to: 0.1, duration: 0.5)
                    let fade = SKAction.fadeOut(withDuration: 0.5)
                    let group = SKAction.group([scale, fade])
                    number?.run(group)
                }
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

    
}

