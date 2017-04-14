//
//  GameScene.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/22/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit
import GameplayKit
import AudioToolbox

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
    case tutorialNode = "tutorialNode"
    case survivalNode = "survivalNode"
    case classicNode = "classicNode"
    case settingsNode = "settingsNode"
    //    TutorialContainerViewController
    
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
            gridDispatcher = GridController(matrix: [[NumberSpriteNode]](), piles: piles, grid: objectsTileMap, currentSolution: nil, frozen: false)
            gridDispatcher?.fullfillGrid()
            objectsTileMap.addChild(line)
        } catch let error as TwelveError where error == .gridHasNoPile {
            fatalError("no piles available on grid")
        } catch let error {
            print("unknown error \(error )")
        }
    }
    
    
    
    
}




class GameScene: KVOScene {
    
    var menuVC: MenuViewController?
    
    
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
        
        guard let scoreTitle = scoreNode.childNode(withName: "points")
            as? SKLabelNode else {
                fatalError("white node not loaded")
        }
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .white : .black
        scoreTitle.colorBlendFactor = 1
        scoreTitle.fontColor = color
        
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
        
        guard let timeLabel = topBar.childNode(withName: "time")
            as? SKLabelNode else {
                fatalError("timerNode node not loaded")
        }
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .white : .black
        timeLabel.colorBlendFactor = 1
        timeLabel.fontColor = color
        
        return label
    }()
    
    
    var gridDispatcher : GridController?
    
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
                gridDispatcher?.cancelSolution()
                number.selected()
            } else {
                line.path = nil
            }
        }
    }
    
    
    lazy var combo: Combo = {
        return Combo(lastNumber: nil, numbers: [Int](), possiblePiles: self.gridDispatcher?.pilesForNumber(1))
    }()
    
    
    lazy var line: SKShapeNode = {
        return SKShapeNode()
    }()
    
    var timerValue = 60 {
        willSet(newValue) {
            let secondsMade = (newValue - totalSeconds) > 0 ? (newValue - totalSeconds) : 0
            totalSeconds = totalSeconds + secondsMade
            print("totalSeconds : \(totalSeconds)")
            timeLabel.text = String(newValue)
            if gameMode == .classic {
                self.progressBar.decrease()
            }
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
            }
        }
    }
    
    var totalPoints = 0 {
        willSet(number) {
            scoreNode.score = number
        }
    }
    
    var totalSeconds = 0
    
    
    override func updateForMode() {
        super.updateForMode()
        guard let classicButton = childNode(withName: TwelveNode.classicNode.rawValue)
            as? SKSpriteNode else {
                fatalError("testButton node not loaded")
        }
        guard let classicLabelNode = classicButton.childNode(withName: TwelveNode.classicNode.rawValue)
            as? SKLabelNode else {
                fatalError("labelNode node not loaded")
        }
        
        guard let survivalButton = childNode(withName: TwelveNode.survivalNode.rawValue)
            as? SKSpriteNode else {
                fatalError("testButton node not loaded")
        }
        guard let survivalLabelNode = survivalButton.childNode(withName: TwelveNode.survivalNode.rawValue)
            as? SKLabelNode else {
                fatalError("labelNode node not loaded")
        }
        
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
        survivalLabelNode.colorBlendFactor = 1
        classicLabelNode.colorBlendFactor = 1
        classicLabelNode.fontColor = color
        survivalLabelNode.fontColor = color
        
    }
    
    
    
    override func didMove(to view: SKView) {
        // Do something once texture atlas has loaded
        let color: UIColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
        backgroundColor = color
        isTopBarHidden(true)
        fillUpMap()
        prepareGame()
        shouldShowTutorial()
        updateTopBarForDarkMode()
    }
    
    
    func setPaused() {
        if timeLabel.isPaused == false && gameStarted {
            showPauseMenu()
        }
    }
    
    
    
    func analyzeElement(_ element: Element) {
        
        do {
            try selectElement(element)
        } catch  {
            currentElement = nil
            let action = SKAction.screenShakeWithNode(element, amount: CGPoint(x:30, y:30), oscillations: 20, duration: 0.50)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            element.run(action, completion: {
                self.endsCombo()
            })
        }
        
    }
    
    func selectElement(_ element : Element) throws  {
        currentElement?.unselected()
        if let prevNumber = currentElement {
            try gridDispatcher?.isTile(prevNumber, adjacentWith: element)
        }
        try addToCombo(element: element)
    }
    
    
    
    private func addToCombo(element: Element) throws {
        
        if let piles = combo.possiblePiles {
            if gridDispatcher!.frozen {
                try combo.addUpFrozenNumber(number: element.value, on: piles)
            } else {
                try combo.addUpComboWith(number: element.value, on: piles)
            }
        } else if let piles = gridDispatcher?.pilesForNumber(element.value) {
            if gridDispatcher!.frozen {
                try combo.addUpFrozenNumber(number: element.value, on: piles)
            } else {
                try combo.addUpComboWith(number: element.value, on: piles)
            }
        } else {
            throw TwelveError.numberIsNotFollowingPile
        }
        
        if combo.numbers.count > 1  {
            
            if let element = currentElement {
                gridDispatcher?.updateElement(element)
            }
            
            addSecond()
            
            
            if !gameStarted {
                gameStarted = true
            }
        }
        
        currentElement = element
    }
    
    
    func newPileAdded() {
        
        //        twelve_reached_view
        
        
        let reachedMax = progressBar.increaseAndHasGivenBonus()
        
        let size = (scene?.view?.frame.size)!
        
        let flashView = SKSpriteNode(texture: SKTexture(image: UIImage(named: "twelve_reached_view")!), size: size)
        flashView.colorBlendFactor = 1
        flashView.color = progressBar.colorType
        flashView.alpha = 0
        flashView.position = CGPoint(x: 0, y: 0)
        flashView.zPosition = 10
        addChild(flashView)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 0.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut])
        flashView.run(sequence) {
            flashView.removeFromParent()
        }
        
        if reachedMax {
            
            timeLabel.action(forKey: "countdown")?.speed = 0
            
            //progressBar.value = 0
            progressBar.isPaused = true
            
            
            self.gridDispatcher?.frozen = true
            
            for pile in try! pilesAvailable() {
                pile.frozen = true
            }
            try? self.gridDispatcher?.freezeNumbers()
            
            self.afterDelay(10, runBlock: {
                self.gridDispatcher?.frozen = false
                for pile in try! self.pilesAvailable() {
                    pile.frozen = false
                }
                try? self.gridDispatcher?.unFreezeNumbers()
                self.progressBar.isPaused = false
                self.timeLabel.action(forKey: "countdown")?.speed = 1
//                let colorizeDown = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.25)
//                self.gridDispatcher.frozen = false
//                self.run(colorizeDown, completion: {
//                    if let action = self.timeLabel.action(forKey: "countdown") {
//                        action.speed = 1
//                    }
//                })
            })
            
            
        }
        
        
    }
    
    
    
    func endsCombo() {
        
        currentElement?.unselected()
        
        do {
            if !gridDispatcher!.frozen {
                let comboResult = try combo.doneWithCombo()
                addPointsForCombo(comboResult)
                if gameMode == .classic {
                    for _ in 0..<comboResult.numberOfTwelve {
                        newPileAdded()
                    }
                }
            }
            if let element = currentElement {
                gridDispatcher?.updateElement(element)
            }
            currentElement = nil
            checkBoard()
        } catch  {
            currentElement = nil
            checkBoard()
        }
    }
    
    func checkBoard() {
        
        gridDispatcher?.cancelSolution()
        
        do {
            if let solution = try gridDispatcher?.checkBoard() , gridDispatcher?.frozen == false {
                showSolution(solution)
            }
            
        } catch let error as TwelveError where error == .noMorePossibilities {
            
            scaleElements(to: 0, duration: gridDispatcher!.frozen ? 0.05 : 0.25)
            
            afterDelay(gridDispatcher!.frozen ? 0.05 : 0.10, runBlock: {
                
                self.showShuffle()
                
                self.afterDelay( self.gridDispatcher!.frozen ? 0.25 : 0.75, runBlock: {
                    
                    try? self.gridDispatcher?.resetNumbers()
                    
                    self.gridDispatcher!.grid.isHidden = true
                    
                    try? self.gridDispatcher?.disposeNumbers()
                    
                    self.scaleElements(to: 0, duration: 0)
                    
                    self.afterDelay(self.gridDispatcher!.frozen ? 0.05 : 0.25, runBlock: {
                        self.removeShuffle()
                        self.gridDispatcher!.grid.isHidden = false
                        self.scaleElements(to: 1, duration: self.gridDispatcher!.frozen ? 0.5 : 0.25)
                    })
                })
            })
            
        } catch {
            fatalError("checkBoard exception should have been caught error : \(error)")
        }
    }
    
    func showSolution(_ solution : Solution) {
        
        
        solution.fromElement.showSolution()
        
        guard let toElement = solution.toElement else {
            return
        }
        
        var positionFromElement = solution.fromElement.position
        var positionToElement = toElement.position
        
        guard let solutionNode = self.objectsTileMap.childNode(withName: "showSolution")
            as? SKSpriteNode else {
                fatalError("showSolution node not loaded")
        }
        solutionNode.isUserInteractionEnabled = false
        solutionNode.alpha = 0
        if let texture = solution.fromElement.handTexture {
            solutionNode.texture = texture
        }
        
        let fromGridPosition = solution.fromElement.gridPosition
        let toGridPosition = toElement.gridPosition
        
        print("from : \(fromGridPosition) to : \(toGridPosition)")
        if fromGridPosition.row > toGridPosition.row && fromGridPosition.column > toGridPosition.column {
            positionFromElement = positionFromElement.offset(dx: -30, dy: -30)
            positionToElement = positionToElement.offset(dx: 30, dy: 30)
        } else if fromGridPosition.row == toGridPosition.row && fromGridPosition.column > toGridPosition.column {
            positionFromElement = positionFromElement.offset(dx: -30, dy: 0)
            positionToElement = positionToElement.offset(dx: 30, dy: 0)
        } else if fromGridPosition.row < toGridPosition.row && fromGridPosition.column > toGridPosition.column {
            positionFromElement =  positionFromElement.offset(dx: -30, dy: 30)
            positionToElement = positionToElement.offset(dx: 30, dy: -30)
        } else if fromGridPosition.row < toGridPosition.row && fromGridPosition.column == toGridPosition.column {
            positionFromElement =  positionFromElement.offset(dx: 0, dy: 30)
            positionToElement = positionToElement.offset(dx: 0, dy: -30)
        } else if fromGridPosition.row > toGridPosition.row && fromGridPosition.column == toGridPosition.column {
            positionFromElement =  positionFromElement.offset(dx: 0, dy: -30)
            positionToElement = positionToElement.offset(dx: 0, dy: 30)
        } else if fromGridPosition.row < toGridPosition.row && fromGridPosition.column < toGridPosition.column {
            positionFromElement =  positionFromElement.offset(dx: 30, dy: 30)
            positionToElement = positionToElement.offset(dx: -30, dy: -30)
        } else if fromGridPosition.row == toGridPosition.row && fromGridPosition.column < toGridPosition.column {
            positionFromElement =  positionFromElement.offset(dx: 30, dy: 0)
            positionToElement = positionToElement.offset(dx: -30, dy: 0)
        } else if fromGridPosition.row > toGridPosition.row && fromGridPosition.column < toGridPosition.column {
            positionFromElement = positionFromElement.offset(dx: 30, dy: -30)
            positionToElement = positionToElement.offset(dx: -30, dy: 40)
        }
        solutionNode.position = positionFromElement
        let move = SKAction.move(to: positionToElement, duration: 1)
        let moveBack = SKAction.move(to: positionFromElement, duration: 0)
        let sequence = SKAction.sequence([move, moveBack])
        let repeatAction = SKAction.repeatForever(sequence)
        let showNode = SKAction.fadeAlpha(to: 0.75, duration: 0.10)
        let group = SKAction.sequence([showNode, repeatAction])
        let delay = (gameStarted == true) ? 5 : 0
        let finalAction = SKAction.afterDelay(TimeInterval(delay), performAction: group)
        solutionNode.run(finalAction, withKey: "showSolution")
    }
    
    func startTimer() {
        
        timerValue = gameMode == .survival ? 20 : 60
        
        let wait = SKAction.wait(forDuration: 1)
        let run = SKAction.run {
            if self.timerValue > 0 {
                self.timerValue -= 1
            } else {
                self.endGame()
            }
        }
        
        timeLabel.run(SKAction.repeatForever(SKAction.sequence([wait, run])) , withKey: "countdown")
        
    }
    
    func endGame() {
        gridDispatcher?.cancelSolution()
        SharedGameManager.sharedInstance.hasAchievedAGame = true
        SharedGameManager.sharedInstance.gameCaracteristic.points = totalPoints
        SharedGameManager.sharedInstance.gameCaracteristic.seconds = totalSeconds
        endsCombo()
        gameStarted = false
        updateTotal(score: totalPoints)
        isPauseHidden(true)
        cleanScene()
        menuVC?.transitionResultGame()
    }
    
    func scaleElements(to scaleValue: CGFloat, duration : TimeInterval) {
        for row in 0..<self.objectsTileMap.numberOfRows {
            for column in 0..<self.objectsTileMap.numberOfColumns {
                let gridPosition = GridPosition(row, column)
                let element = try! self.gridDispatcher?.elementAt(position: gridPosition)
                let scale = SKAction.scale(to: scaleValue, duration: duration)
                element?.run(scale)
            }
        }
    }
    
    
}

extension GameScene {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gridDispatcher != nil else {
            return
        }
        guard gridDispatcher?.frozen == false else {
            return
        }
        endsCombo()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gridDispatcher != nil else {
            return
        }
        guard let touch = touches.first , gridDispatcher?.frozen == false else {
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
        guard gridDispatcher != nil else {
            return
        }
        guard let touch = touches.first , gridDispatcher?.frozen == false else {
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
        
        if gridDispatcher?.frozen == false {
            currentElement?.unselected()
        }
        
        gridDispatcher?.cancelSolution()
        
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
            case TwelveNode.timerNode.rawValue, TwelveNode.topBar.rawValue:
                showPauseMenu()
            case TwelveNode.confirmQuitNode.rawValue:
                leaveGame()
            case TwelveNode.cancelQuitNode.rawValue:
                resumeGame()
            default:
                if gridDispatcher!.frozen {
                    touchElement(at: location)
                }
                
                /*
                 if let node = atPoint(location) as? SKSpriteNode , node.name == "shapeSelected" {
                 if node.parent is Element {
                 analyzeElement(node.parent as! Element)
                 if currentElement != nil , gridDispatcher!.frozen {
                 endsCombo()
                 }
                 }
                 }*/
            }
        }
        else {
            touchElement(at: location)
        }
        
    }
    
    func touchElement(at location : CGPoint) {
        if let element = (nodes(at: location).filter { $0 is Element }).first as? Element {
            analyzeElement(element)
            if currentElement != nil , gridDispatcher!.frozen {
                endsCombo()
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
            let comboForSeconds = 3
            if combo.numbers.count > comboForSeconds  {
                timerValue += 1
                let action = SKAction.screenZoomWithNode(timeLabel, amount: CGPoint(x:2.5, y:2.5), oscillations: 2, duration: 1)
                timeLabel.run(action)
            }
   
        } else if gridDispatcher!.frozen {
                timerValue += 1
                let action = SKAction.screenZoomWithNode(timeLabel, amount: CGPoint(x:2.5, y:2.5), oscillations: 2, duration: 1)
                timeLabel.run(action)
            }
        }
    
}

extension GameScene {
    
    
    func resetPiles() {
        gridDispatcher?.resetPiles()
        try? gridDispatcher?.resetNumbers()
        try? gridDispatcher?.disposeNumbers()
    }
    
    func leaveGame() {
        isPauseHidden(true)
        removeBackgroundLayer()
        gameStarted = false
        cleanScene()
        objectsTileMap.isHidden = true
        afterDelay(0.3) {
            self.menuVC?.transitionBack(from: self.scene)
        }
    }
    
    func cleanScene() {
        removeAllActions()
        line.removeFromParent()
        try? gridDispatcher?.removeNumbers()
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
        } else {
            shouldShowJokerTutorial()
        }
    }
    
    func shouldShowSurvivalTutorial() {
        if  SharedGameManager.sharedInstance.survivalTutorialSeen == false {
            addBackgroundLayer(belowNode: "tutorialSurvivalNode")
            isSurvivalTutorialHidden(false)
        } else  {
            shouldShowJokerTutorial()
        }
    }
    
    func shouldShowJokerTutorial() {
        if SharedGameManager.sharedInstance.hasAchievedAGame == true {
            if  SharedGameManager.sharedInstance.jokerTutorialSeen == false {
                addBackgroundLayer(belowNode: "tutorialJokerNode")
                isJokerTutorialHidden(false)
            }
        }
    }
    
    
    func prepareGame() {
        
        guard let solutionNode = self.objectsTileMap.childNode(withName: "showSolution")
            as? SKSpriteNode else {
                fatalError("showSolution node not loaded")
        }
        
        solutionNode.alpha = 0
        
        objectsTileMap.isHidden = true
        
        
        isDeckMenuHidden(true)
        isPauseHidden(true)
        totalPoints = 0
        isEndMenuHidden(true)
        resetPiles()
        isMainMenuHidden(false)
        isTopBarHidden(true)
        checkBoard()
        
        afterDelay(0.5) {
            self.scaleElements(to: 0, duration: 0)
            self.objectsTileMap.isHidden = false
            self.scaleElements(to: 1, duration: 0.25)
        }
        
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
                            pileSprite.updatePileView()
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
        guard let node = childNode(withName: "pauseMenuContainer")
            as? SKSpriteNode else {
                fatalError("pauseMenu node not loaded")
        }
        
        node.isHidden = hidden
    }
    
    func isShuffleHidden(_ hidden: Bool) {
        guard let node = childNode(withName: "shuffleNode")
            as? SKSpriteNode else {
                fatalError("shuffleNode node not loaded")
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
        
        guard let node = childNode(withName: "pauseMenuContainer")
            as? SKSpriteNode else {
                fatalError("pauseMenu node not loaded")
        }
        
        guard let pauseMenu = node.childNode(withName: "pauseMenu")
            as? SKSpriteNode else {
                fatalError("pauseMenu node not loaded")
        }
        
        
        
        let hidePauseAction = SKAction.fadeOut(withDuration: 0.15)
        pauseMenu.run(hidePauseAction)
        self.isPauseHidden(true)
        
        
        //        self.timeLabel.action(forKey: "countdown")?.speed = 1
        self.timeLabel.isPaused = false
        
        
        
        removeBackgroundLayer()
    }
    
    
    
    
    
    func showConfirmationLeaveGame(){
        
        guard let node = childNode(withName: "pauseMenuContainer")
            as? SKSpriteNode else {
                fatalError("pauseMenuContainer node not loaded")
        }
        guard let pauseMenu = node.childNode(withName: "pauseMenu")
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
        guard let node = childNode(withName: "pauseMenuContainer")
            as? SKSpriteNode else {
                fatalError("pauseMenuContainer node not loaded")
        }
        
        guard let pauseMenu = node.childNode(withName: "pauseMenu")
            as? SKSpriteNode else {
                fatalError("pauseMenu node not loaded")
        }
        
        guard let confirmationLeaveMenu = pauseMenu.childNode(withName: "pauseConfirmationMenu")
            as? SKSpriteNode else {
                fatalError("confirmationLeaveMenu node not loaded")
        }
        pauseMenu.alpha = 0
        confirmationLeaveMenu.isHidden = true
        node.size = size
        
        node.position = CGPoint(x: 0, y: 0)
        
        addBackgroundLayer(belowNode: "pauseMenuContainer")
        isPauseHidden(false)
        //        timeLabel.action(forKey: "countdown")?.speed = 0
        timeLabel.isPaused = true
        
        let showPauseAction = SKAction.fadeIn(withDuration: 0.15)
        pauseMenu.run(showPauseAction)
    }
    
    
    func showShuffle() {
        guard let node = childNode(withName: "shuffleNode")
            as? SKSpriteNode else {
                fatalError("shuffleNode node not loaded")
        }
        
        node.alpha = 0
        node.position = CGPoint(x: 0, y: 0)
        isShuffleHidden(false)
        timeLabel.isPaused = true
        let showPauseAction = SKAction.fadeIn(withDuration: 0.25)
        node.run(showPauseAction)
    }
    
    func removeShuffle() {
        guard let node = childNode(withName: "shuffleNode")
            as? SKSpriteNode else {
                fatalError("shuffleNode node not loaded")
        }
        let hideShuffle = SKAction.fadeOut(withDuration: 0.15)
        node.run(hideShuffle)
        isShuffleHidden(true)
        self.timeLabel.isPaused = false
        
    }
    
    
    func addBackgroundLayer(belowNode: String) {
        scaleElements(to: 0, duration: 0.25)
        guard let node = childNode(withName: belowNode)
            as? SKSpriteNode else {
                fatalError("\(belowNode) node not loaded")
        }
        
        guard let leftPause = childNode(withName: "leftPause")
            as? SKSpriteNode else {
                fatalError("leftPause node not loaded")
        }
        guard let rightPause = childNode(withName: "rightPause")
            as? SKSpriteNode else {
                fatalError("rightPause node not loaded")
        }
        
        leftPause.zPosition = node.zPosition - 1
        rightPause.zPosition = node.zPosition - 1
        rightPause.alpha = 0
        leftPause.alpha = 0
        let sizeScreen = UIScreen.main.bounds.size
        let size = CGSize(width: sizeScreen.width, height: sizeScreen.height)
        
        leftPause.size = size
        leftPause.position = CGPoint(x : -size.width, y: -sizeScreen.height / 3)
        rightPause.size = size
        rightPause.position = CGPoint(x : +size.width, y: sizeScreen.height / 3)
        let actionMoveCenter = SKAction.move(to: CGPoint(x : 0, y : 0), duration: 0.25)
        let fadeIn = SKAction.fadeIn(withDuration: 0.10)
        let groupAction = SKAction.group([actionMoveCenter, fadeIn])
        leftPause.run(groupAction)
        rightPause.run(groupAction)
        
        /*
         let sizeScreen = UIScreen.main.bounds.size
         let size = CGSize(width: sizeScreen.width, height: sizeScreen.height)
         let backgroundNode = SKSpriteNode.init(color: UIColor.myTextColor.withAlphaComponent(0.30), size: size)
         backgroundNode.name = "backgroundNode"
         */
        
    }
    
    func removeBackgroundLayer() {
        scaleElements(to: 1, duration: 0.25)
        guard let leftPause = childNode(withName: "leftPause")
            as? SKSpriteNode else {
                fatalError("leftPause node not loaded")
        }
        guard let rightPause = childNode(withName: "rightPause")
            as? SKSpriteNode else {
                fatalError("rightPause node not loaded")
        }
        
        let sizeScreen = UIScreen.main.bounds.size
        let size = CGSize(width: sizeScreen.width, height: sizeScreen.height)
        let leftPausePosition = CGPoint(x : -size.width, y: -sizeScreen.height / 3)
        let rightPausePosition = CGPoint(x : +size.width, y: sizeScreen.height / 3)
        let leftActionMoveOutOfBounds = SKAction.move(to: leftPausePosition, duration: 0.25)
        let rightActionMoveOutOfBounds = SKAction.move(to: rightPausePosition, duration: 0.25)
        leftPause.run(leftActionMoveOutOfBounds)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.10)
        let groupActionLeft = SKAction.group([leftActionMoveOutOfBounds, fadeOut])
        let groupActionRight = SKAction.group([rightActionMoveOutOfBounds, fadeOut])
        
        
        leftPause.run(groupActionLeft)
        rightPause.run(groupActionRight)
        /*        guard let node = childNode(withName: "backgroundNode")
         as? SKSpriteNode else {
         fatalError("backgroundNode node not loaded")
         }
         node.removeFromParent()
         */
    }
    
    
    
}


extension GameScene {
    
    
    func updateTopBarForDarkMode() {
        
        guard let topBar = self.childNode(withName: TwelveNode.topBar.rawValue)
            as? SKSpriteNode else {
                fatalError("topBarNode node not loaded")
        }
        
        
        guard let timeLabel = topBar.childNode(withName: "time")
            as? SKLabelNode else {
                fatalError("timerNode node not loaded")
        }
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .white : .black
        timeLabel.colorBlendFactor = 1
        timeLabel.fontColor = color
        
        
        guard let scoreNode = topBar.childNode(withName: TwelveNode.scoreNode.rawValue)
            as? ScoreNode else {
                fatalError("scoreNode node not loaded")
        }
        
        guard let scoreTitle = scoreNode.childNode(withName: "points")
            as? SKLabelNode else {
                fatalError("white node not loaded")
        }
        
        scoreTitle.colorBlendFactor = 1
        scoreTitle.fontColor = color
        
        
    }
}


extension CGFloat {
    // Used to calculate a linear interpolation between two values.
    func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        return start + (end - start) * t
    }
}

