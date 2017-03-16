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


enum TwelveNode: String {
    case progressBar = "progressBar"
    case tileMap = "Tile Map Node"
    case topBar = "topBar"
    case scoreNode = "scoreNode"
    case timerNode = "timerNode"
    case restartNode = "Restart"
    case resumeNode = "resumeNode"
    case leaveNode = "leaveNode"
    case closeClassicNode = "closeClassicNode"
    case closeJokerNode = "closeJokerNode"
    case closeSurvivalNode = "closeSurvivalNode"
    case confirmQuitNode = "confirmQuitNode"
    case cancelQuitNode = "cancelQuitNode"

}



protocol Preparation {
    func fillUpMap()
}

protocol DrawLine {
    func drawLine(endingPoint: CGPoint)
}

extension GameScene : DrawLine {
    func drawLine(endingPoint: CGPoint) {
        if let element = currentElement {
            let path = CGMutablePath()
            path.move(to: element.position)
            path.addLine(to: CGPoint(x: endingPoint.x, y:endingPoint.y))
            line.zPosition = 1
            line.path = path
            line.strokeColor = element.colorType.withAlphaComponent(0.5)
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
            gridDispatcher = GridController(matrix: [[NumberSpriteNode]](), piles: piles, grid: objectsTileMap, currentSolution: nil)
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
    
    var gameVC: GameViewController?
    
    
    lazy var progressBar: ProgressBar = {
        guard let nodeProgressBar = self.childNode(withName: TwelveNode.progressBar.rawValue)
            as? ProgressBar else {
                fatalError("comboBarTop node not loaded")
        }
        return nodeProgressBar
    }()
    
    lazy var objectsTileMap: SKTileMapNode = {
        guard let map = self.childNode(withName: TwelveNode.tileMap.rawValue)
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        return map
    }()
    
    lazy var scoreNode: ScoreNode = {
        guard let topBar = self.childNode(withName: TwelveNode.topBar.rawValue)
            as? SKSpriteNode else {
                fatalError("topBar node not loaded")
        }
        
        guard let scoreNode = topBar.childNode(withName: TwelveNode.scoreNode.rawValue)
            as? ScoreNode else {
                fatalError("scoreNode node not loaded")
        }
        return scoreNode
    }()
    
    
    lazy var timeLabel: SKLabelNode = {
        guard let topBar = self.childNode(withName: TwelveNode.topBar.rawValue)
            as? SKSpriteNode else {
                fatalError("topBarNode node not loaded")
        }
        guard let label = topBar.childNode(withName: TwelveNode.timerNode.rawValue)
            as? SKLabelNode else {
                fatalError("timerNode node not loaded")
        }
        return label
    }()
    
    
    var gridDispatcher : GridController!
    
    var gameMode: GameMode {
        get {
            return SharedGameManager.sharedInstance.gameCaracteristic.mode
        }
    }
    
    var gameDifficulty: GameDifficulty {
        get {
            return SharedGameManager.sharedInstance.gameCaracteristic.difficulty
        }
    }
    
    
    var currentElement: Element? {
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
        return Combo(lastNumber: nil, numbers: [Int](), possiblePiles: self.gridDispatcher.pilesForNumber(1))
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
        
        // Do something once texture atlas has loaded
        fillUpMap()
        prepareGame()
        shouldShowTutorial()
    }
    
    
    
    func analyzeElement(_ element: Element) {
        
        do {
            try selectElement(element)
        } catch  {
            currentElement = nil
            let action = SKAction.screenShakeWithNode(element, amount: CGPoint(x:30, y:30), oscillations: 20, duration: 0.50)
            element.run(action, completion: {
                self.endsCombo()
            })
        }
        
    }
    
    func selectElement(_ element : Element) throws  {
        currentElement?.unselected()
        if let prevNumber = currentElement {
            try gridDispatcher.isTile(prevNumber, adjacentWith: element)
        }
        try addToCombo(element: element)
    }
    
    
    
    private func addToCombo(element: Element) throws {
        
        if let piles = combo.possiblePiles {
            try combo.addUpComboWith(number: element.value, on: piles)
        } else if let piles = gridDispatcher.pilesForNumber(element.value) {
            try combo.addUpComboWith(number: element.value, on: piles)
        } else {
            throw TwelveError.numberIsNotFollowingPile
        }
        
        if combo.numbers.count > 1  {
            
            
            if let element = currentElement {
                gridDispatcher.updateElement(element)
            }
            
            addSecond()
            
            
            if !gameStarted {
                gameStarted = true
            }
        }
        
        currentElement = element
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
        
        currentElement?.unselected()
        do {
            let comboResult = try combo.doneWithCombo()
            addPointsForCombo(comboResult)
            for _ in 0..<comboResult.numberOfTwelve {
                newPileAdded()
            }
            if let element = currentElement {
                gridDispatcher.updateElement(element)
            }
            currentElement = nil
            checkBoard()
        } catch  {
            currentElement = nil
            checkBoard()
        }
    }
    
    func checkBoard() {
        
        do {
            try gridDispatcher.checkBoard()
        } catch let error as TwelveError where error == .noMorePossibilities {
            
            try? self.gridDispatcher.resetNumbers()
            try? self.gridDispatcher.disposeNumbers()
            
        } catch {
            fatalError("checkBoard exception should have been caught error : \(error)")
        }
        
    }
    
    
    func startTimer() {
        
        timerValue = gameMode == .survival ? 20 : 60
        
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
        if let element = (nodes(at: location).filter { $0 is Element }).first as? Element {
            guard let prevElement = currentElement , prevElement.gridPosition != element.gridPosition else {
                return
            }
            analyzeElement(element)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if currentElement != nil {
            drawLine(endingPoint: touch.location(in: self.objectsTileMap))
        }
        
        let location = touch.location(in: self)
        if let element = (nodes(at: location).filter { $0 is Element }).first as? Element {
            guard let prevElement = currentElement , prevElement.gridPosition != element.gridPosition else {
                return
            }
            analyzeElement(element)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        if let name = atPoint(location).name {
            switch name {
            case TwelveNode.restartNode.rawValue:
                prepareGame()
            case TwelveNode.resumeNode.rawValue:
                resumeGame()
            case TwelveNode.leaveNode.rawValue:
                showConfirmationLeaveGame()
            case TwelveNode.closeClassicNode.rawValue:
                removeBackgroundLayer()
                isClassicTutorialHidden(true)
            case TwelveNode.closeSurvivalNode.rawValue:
                removeBackgroundLayer()
                isSurvivalTutorialHidden(true)
            case TwelveNode.closeJokerNode.rawValue:
                removeBackgroundLayer()
                isJokerTutorialHidden(true)
            case TwelveNode.timerNode.rawValue:
                showPauseMenu()
            case TwelveNode.confirmQuitNode.rawValue:
                leaveGame()
            case TwelveNode.cancelQuitNode.rawValue:
                resumeGame()
            default:
                print("nothing to care about")
            }
        }  else {
            if let element = (nodes(at: location).filter { $0 is Element }).first as? Element {
                analyzeElement(element)
            }
        }
        
    }
}


extension GameScene {
    
    func addPointsForCombo(_ comboResult : ComboResult) {
        self.totalPoints += comboResult.points
    }
    
    func addSecond() {
        if gameMode == .survival {
            var comboForSeconds = 0
            switch gameDifficulty {
            case .easy:
                comboForSeconds = 3
            case .normal:
                comboForSeconds = 4
            case .hard:
                comboForSeconds = 5
            }
            if combo.numbers.count > comboForSeconds  {
                timerValue += 1
                let action = SKAction.screenZoomWithNode(timeLabel, amount: CGPoint(x:2, y:2), oscillations: 2, duration: 1)
                timeLabel.run(action)
            }
        }
    }
}

extension GameScene {
    
    
    func resetPiles() {
        gridDispatcher.resetPiles()
        try? gridDispatcher.resetNumbers()
        try? gridDispatcher.disposeNumbers()
    }
    
    func leaveGame() {
        removeBackgroundLayer()
        gameStarted = false
        cleanScene()
        gameVC?.navigationController?.popToRootViewController(animated: true)
    }
    
    func cleanScene() {
        line.removeFromParent()
        try? gridDispatcher.removeNumbers()
    }
    
    func shouldShowTutorial() {
        switch gameMode {
        case .classic:
            shouldShowClassicTutorial()
        case .survival:
            shouldShowSurvivalTutorial()
        }
    }
    
    func shouldShowClassicTutorial() {
        if  SharedGameManager.sharedInstance.classicTutorialSeen == false {
            addBackgroundLayer(belowNode: "tutorialClassicNode")
            isClassicTutorialHidden(false)
        }
    }
    
    func shouldShowSurvivalTutorial() {
        if  SharedGameManager.sharedInstance.survivalTutorialSeen == false {
            addBackgroundLayer(belowNode: "tutorialSurvivalNode")
            isSurvivalTutorialHidden(false)
        }
    }
    
    func shouldShowJokerTutorial() {
        if  SharedGameManager.sharedInstance.jokerTutorialSeen == false {
            addBackgroundLayer(belowNode: "tutorialJokerNode")
            isJokerTutorialHidden(false)
        }
    }
    
    
    func prepareGame() {
        
        for row in 0..<self.objectsTileMap.numberOfRows {
            for column in 0..<self.objectsTileMap.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                do {
                    if let number = try self.gridDispatcher.elementAt(position: gridPosition) {
                        let scaleDown = SKAction.scale(to: 0, duration: 0)
                        let scaleBack = SKAction.scale(to: 1, duration: 0.5)
                        let fade = SKAction.fadeIn(withDuration: 0.5)
                        let group = SKAction.group([scaleDown, scaleBack, fade])
                        number.run(group)
                    }
                } catch {  }
            }
        }
        isPauseHidden(true)
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
                if let spriteNode = child.childNode(withName: "PileSprite") {
                    spriteNode.isHidden = true
                } else {
                    let pile = Pile()
                    pile.isHidden = true
                    child.addChild(pile)
                }
                
                if let value = child.userData?.value(forKey: "difficulty") as? Int {
                    print("gameDifficulty : \(gameDifficulty)")
                    let difficulty = GameDifficulty(rawValue: value)
                    if difficulty == .easy && gameDifficulty == .easy || difficulty == .normal && gameDifficulty == .normal || gameDifficulty == .hard {
                        if let pileSprite = child.childNode(withName: "PileSprite") as? Pile {
                            pileSprite.isHidden = false
                            piles.append(pileSprite)
                        }
                    }
                }
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
    
    func isClassicTutorialHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "tutorialClassicNode")
            as? SKSpriteNode else {
                fatalError("tutorialClassicNode node not loaded")
        }
        if hidden == false {
            node.position = CGPoint(x: 0, y: 0)
        }
        node.isHidden = hidden
    }
    
    func isSurvivalTutorialHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "tutorialSurvivalNode")
            as? SKSpriteNode else {
                fatalError("tutorialSurvivalNode node not loaded")
        }
        if hidden == false {
            node.position = CGPoint(x: 0, y: 0)
        }
        node.isHidden = hidden
    }
    
    func isJokerTutorialHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "tutorialJokerNode")
            as? SKSpriteNode else {
                fatalError("tutorialJokerNode node not loaded")
        }
        if hidden == false {
            node.position = CGPoint(x: 0, y: 0)
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
        guard let topBar = childNode(withName: TwelveNode.topBar.rawValue)
            as? SKSpriteNode else {
                fatalError("scoreNode node not loaded")
        }
        
        topBar.isHidden = hidden
    }
    
    func isPauseHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "pauseMenu")
            as? SKSpriteNode else {
                fatalError("pauseMenu node not loaded")
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
    
    func showEndMenu() {
        guard let node = childNode(withName: "menuEndGameSprite")
            as? SKSpriteNode else {
                fatalError("menuEndGameSprite node not loaded")
        }
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = false
        self.isEndMenuHidden(false)
    }
    
    func resumeGame() {
        isPauseHidden(true)
        removeBackgroundLayer()
    }
    
    func showConfirmationLeaveGame(){
        
        guard let pauseMenu = childNode(withName: "pauseMenu")
            as? SKSpriteNode else {
                fatalError("pauseMenu node not loaded")
        }
        
        guard let confirmationLeaveMenu = pauseMenu.childNode(withName: "pauseConfirmationMenu")
            as? SKSpriteNode else {
                fatalError("confirmationLeaveMenu node not loaded")
        }
        
        let currentScaleX = pauseMenu.xScale
        
        let flip = SKAction.scaleX(to: 0, duration: 0.1)
        
        let flipBack = SKAction.scaleX(to: currentScaleX, duration: 0.1)
        
        let changeView = SKAction.run( {
            confirmationLeaveMenu.isHidden = false
        })
        
        let action = SKAction.sequence([flip, changeView, flipBack] )
        
        pauseMenu.run(action)
        
    }
    
    
    func showPauseMenu() {
        guard let node = childNode(withName: "pauseMenu")
            as? SKSpriteNode else {
                fatalError("pauseMenu node not loaded")
        }
        guard let confirmationLeaveMenu = node.childNode(withName: "pauseConfirmationMenu")
            as? SKSpriteNode else {
                fatalError("confirmationLeaveMenu node not loaded")
        }
        confirmationLeaveMenu.isHidden = true
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = false
        addBackgroundLayer(belowNode: "pauseMenu")
        isPauseHidden(false)
        
    }
    
    func addBackgroundLayer(belowNode: String) {
        hideNumbers(hide: true)
        guard let node = childNode(withName: "pauseMenu")
            as? SKSpriteNode else {
                fatalError("pauseMenu node not loaded")
        }
        let sizeScreen = UIScreen.main.nativeBounds.size
        let size = CGSize(width: sizeScreen.width, height: sizeScreen.height)
        let backgroundNode = SKSpriteNode.init(color: UIColor.myTextColor.withAlphaComponent(0.30), size: size)
        backgroundNode.name = "backgroundNode"
        backgroundNode.position = CGPoint(x: 0, y: 0)
        backgroundNode.zPosition = node.zPosition - 1
        addChild(backgroundNode)
    }
    
    func removeBackgroundLayer() {
        hideNumbers(hide: false)
        guard let node = childNode(withName: "backgroundNode")
            as? SKSpriteNode else {
                fatalError("backgroundNode node not loaded")
        }
        node.removeFromParent()
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
                if let element = try? self.gridDispatcher.elementAt(position: gridPosition) {
                    let scale = SKAction.scale(to: 0.1, duration: 0.5)
                    let fade = SKAction.fadeOut(withDuration: 0.5)
                    let group = SKAction.group([scale, fade])
                    element?.run(group)
                }
            }
        }
        
        node.run(move, completion: {
            self.showEndMenu()
        })
    }
    
    func hideNumbers(hide: Bool) {
        
        for row in 0..<self.objectsTileMap.numberOfRows {
            for column in 0..<self.objectsTileMap.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                if let element = try? self.gridDispatcher.elementAt(position: gridPosition) {
                    if hide {
                        let scale = SKAction.scale(to: 0.1, duration: 0.25)
                        let fade = SKAction.fadeOut(withDuration: 0.25)
                        let group = SKAction.group([scale, fade])
                        element?.run(group)
                    } else {
                        let scale = SKAction.scale(to: 1, duration: 0.25)
                        let fade = SKAction.fadeIn(withDuration: 0.25)
                        let group = SKAction.group([scale, fade])
                        element?.run(group)
                    }
                }
            }
        }
        
    }
    
    
}




extension CGFloat {
    // Used to calculate a linear interpolation between two values.
    func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        return start + (end - start) * t
    }
}

