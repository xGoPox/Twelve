//
//  GameScene.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/22/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit
import GameplayKit


extension TutorialScene : Preparation {
    
    
    func fillUpMap()  {
        do {
            let piles = try pilesAvailable()
            gridDispatcher = TutorialController(matrix: [[NumberSpriteNode]](), piles: piles, grid: objectsTileMap, currentSolution: nil, tutorialStep: .firstStep)
            gridDispatcher?.fullfillGrid()
            objectsTileMap.addChild(line)
        } catch let error as TwelveError where error == .gridHasNoPile {
            fatalError("no piles available on grid")
        } catch let error {
            print("unknown error \(error )")
        }
    }
    
    
}


class TutorialScene: KVOScene {
    
    var timer: Timer?
    var menuVC: MenuViewController?
    
    lazy var objectsTileMap: SKTileMapNode = {
        guard let map = self.childNode(withName: TwelveNode.tileMap.rawValue)
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        return map
    }()
    
    
    lazy var combo: Combo = {
        return Combo(lastNumber: nil, numbers: [Int](), possiblePiles: self.gridDispatcher?.pilesForNumber(1))
    }()
    
    
    var gridDispatcher : TutorialController?
    
    var currentElement: Element? {
        willSet(obj) {
            if let number = obj {
                number.selected()
            } else {
                line.path = nil
            }
        }
    }
    
    
    lazy var line: SKShapeNode = {
        return SKShapeNode()
    }()
    
    override func didMove(to view: SKView) {
        // Do something once texture atlas has loaded
        let color: UIColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
        backgroundColor = color
        updateNodeForDarkMode()
        fillUpMap()
        prepareGame()
        showFirstTutorial()
    }
    
    
    override func willMove(from view: SKView) {
        for child in self.children {
            if child.name?.contains("Tutorial") == true {
                let scale = SKAction.scale(to: 0, duration: 0)
                child.run(scale)
            }
        }
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
            try gridDispatcher?.isTile(prevNumber, adjacentWith: element)
        }
        try addToCombo(element: element)
    }
    
    
    private func addToCombo(element: Element) throws {
        
        if let piles = combo.possiblePiles {
            try combo.addUpComboWith(number: element.value, on: piles)
        } else if let piles = gridDispatcher?.pilesForNumber(element.value) {
            try combo.addUpComboWith(number: element.value, on: piles)
        } else {
            throw TwelveError.numberIsNotFollowingPile
        }
        
        if combo.numbers.count > 1  {
            
            
            if let element = currentElement {
                gridDispatcher?.updateElement(element)
            }
            
            
            
        }
        
        currentElement = element
    }
    
    
    
    func endsCombo() {
        
        currentElement?.unselected()
        
        do {
            let comboResult = try combo.doneWithCombo()
            
            let step = gridDispatcher!.tutorialStep
            switch step {
            case .firstStep:
                if comboResult.lastNumber != 4 {
                    prepareGame()
                } else {
                    transitionToMiddleTutorial()
                    gridDispatcher?.tutorialStep = .secondStep
                }
            case .secondStep:
                transitionToThirdTutorial()
                gridDispatcher?.tutorialStep = .thirdStep
                prepareGame()
            case .thirdStep:
                if !(comboResult.lastNumber < 12 && comboResult.numberOfTwelve == 1) {
                    prepareGame()
                } else {
                    showEndsTutorial()
                }
            }
            
            if let element = currentElement {
                gridDispatcher?.updateElement(element)
            }
            currentElement = nil
        } catch  {
            currentElement = nil
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
        let delay = 0
        let finalAction = SKAction.afterDelay(TimeInterval(delay), performAction: group)
        solutionNode.run(finalAction, withKey: "showSolution")
    }
    
    
}

extension TutorialScene {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gridDispatcher != nil else {
            return
        }
        endsCombo()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gridDispatcher != nil else {
            return
        }
        guard let touch = touches.first  else {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        currentElement?.unselected()
        
        let location = touch.location(in: self)
        
        if let name = atPoint(location).name , name == "leaveNode" {
            leaveGame()
        } else if let element = (nodes(at: location).filter { $0 is Element }).first as? Element {
            analyzeElement(element)
        }
        
    }
}




extension TutorialScene {
    
    func resetPiles() {
        gridDispatcher?.resetPiles()
        try? gridDispatcher?.resetNumbers()
        try? gridDispatcher?.disposeNumbers()
    }
    
    
    func leaveGame() {
        cleanScene()
        afterDelay(0.5) {
            self.menuVC?.transitionBack(from: self.scene)
        }
    }
    
    func cleanScene() {
        
        removeAllActions()

        timer?.invalidate()
        timer = nil
        
        guard let bottomBarNode = self.childNode(withName: "bottomBar")
            as? SKSpriteNode else {
                fatalError("bottomBar node not loaded")
        }
        let moveDown = SKAction.moveTo(y: frame.minY, duration: 0.25)
        bottomBarNode.run(moveDown)
        
        scaleElements(to: 0, duration: 0.25)
        
        guard let solutionNode = self.objectsTileMap.childNode(withName: "showSolution")
            as? SKSpriteNode else {
                fatalError("showSolution node not loaded")
        }
        
        solutionNode.alpha = 0
        
        for pile in try! pilesAvailable() {
            pile.isHidden = true
            pile.updateWithLastNumber(12)
        }
        line.removeFromParent()
        try? gridDispatcher?.removeNumbers()
    }
    
    func prepareGame() {
        objectsTileMap.isHidden = true
        resetPiles()
        afterDelay(0.25) {
            self.scaleElements(to: 0, duration: 0)
            self.objectsTileMap.isHidden = false
            self.scaleElements(to: 1, duration: 0.25)
            do {
                if let solution = try self.gridDispatcher?.checkBoard() {
                    self.showSolution(solution)
                }
            } catch {
                fatalError("there should be a solution on didMove tutorial!")
            }
        }
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

extension TutorialScene  {
    
    func pilesAvailable() throws -> [Pile] {
        
        guard let bottomBar = childNode(withName: "bottomBar")
            as? SKSpriteNode else {
                fatalError("bottomBar node not loaded")
        }
        
        var piles = [Pile]()
        for child in bottomBar.children {
            if child.name == "pile" {
                if let spriteNode = child.childNode(withName: "PileSprite") {
                    spriteNode.isHidden = false
                } else {
                    let pile = Pile()
                    pile.isHidden = false
                    child.addChild(pile)
                }
                
                if let pileSprite = child.childNode(withName: "PileSprite") as? Pile {
                    pileSprite.updatePileView()
                    piles.append(pileSprite)
                }
            }
        }
        
        guard !piles.isEmpty else {
            print("piles array is empty!")
            throw TwelveError.gridHasNoPile
        }
        
        return piles
    }
    
}


extension TutorialScene {
    
    
    
    func showFirstTutorial() {
        
        guard let tutorial_Top_One = childNode(withName: "FirstTutorial_Top_One")
            as? SKSpriteNode else {
                fatalError("tutorial_Top_One node not loaded")
        }
        
        guard let tutorial_Bottom_One = childNode(withName: "FirstTutorial_Bottom_One")
            as? SKSpriteNode else {
                fatalError("tutorial_Bottom_One node not loaded")
        }
        
        let scaleUp = SKAction.scale(to: 1, duration: 0.25)
        tutorial_Top_One.run(scaleUp)
        tutorial_Bottom_One.run(scaleUp)
    }

    
    func transitionToMiddleTutorial() {
        
        guard let firstTutorial_Top_One = childNode(withName: "FirstTutorial_Top_One")
            as? SKSpriteNode else {
                fatalError("firstTutorial_Top_One node not loaded")
        }
        
        guard let firstTutorial_Bottom_One = childNode(withName: "FirstTutorial_Bottom_One")
            as? SKSpriteNode else {
                fatalError("firstTutorial_Bottom_One node not loaded")
        }
        
        let scaleDown = SKAction.scale(to: 0, duration: 0.25)
        firstTutorial_Top_One.run(scaleDown)
        firstTutorial_Bottom_One.run(scaleDown)
        
        
        self.scaleElements(to: 0, duration: 0.10)
        
        afterDelay(0.10) {
            self.objectsTileMap.isHidden = true
        }
        
        afterDelay(0.25) {
            self.showMiddleTutorial()
        }
        
    }
    
    
    
    
    
    
    func showMiddleTutorial() {
        
        
        afterDelay(0.25) {
            
            
            guard let secondTutorial_Middle_One = self.childNode(withName: "SecondTutorial_Middle_One")
                as? SKSpriteNode else {
                    fatalError("SecondTutorial_Top_One node not loaded")
            }
            
            let scaleUp = SKAction.scale(to: 1, duration: 0.25)
            
            secondTutorial_Middle_One.run(scaleUp)
            
            
            guard let bottomBarNode = self.childNode(withName: "bottomBar")
                as? SKSpriteNode else {
                    fatalError("bottomBar node not loaded")
            }
            
            let yPosition = bottomBarNode.position.y
            
            let moveUp = SKAction.moveTo(y: secondTutorial_Middle_One.position.y - 120.0, duration: 0.25)
            
            if let pile = try! self.pilesAvailable().first {
                pile.updateWithLastNumber(1)
            }
            
            bottomBarNode.run(moveUp, completion: {
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 1,
                                             repeats: true) {
                                                
                                                //"[weak self]" creates a "capture group" for timer
                                                [weak self] timer in
                                                
                                                //Add a guard statement to bail out of the timer code
                                                //if the object has been freed.
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                //Put the code that be called by the timer here.
                                                if let pile = try! strongSelf.pilesAvailable().first {
                                                    
                                                    pile.updateWithLastNumber(pile.followingNumber())
                                                    if pile.currentNumber == 4 {
                                                        timer.invalidate()
                                                    }
                                                }
                }

            })
            
            self.afterDelay(5) {
                let moveDown = SKAction.moveTo(y: yPosition, duration: 0.25)
                bottomBarNode.run(moveDown)
                self.prepareGame()
                self.transitionToSecondTutorial()
            }
            
        }
        
    }
    
    
    func transitionToSecondTutorial() {
        
        guard let secondTutorial_Middle_One = self.childNode(withName: "SecondTutorial_Middle_One")
            as? SKSpriteNode else {
                fatalError("SecondTutorial_Top_One node not loaded")
        }
        
        let scaleDown = SKAction.scale(to: 0, duration: 0.25)
        secondTutorial_Middle_One.run(scaleDown) {
            self.scaleElements(to: 1, duration: 0.25)
        }
        afterDelay(0.25) {
            self.showSecondTutorial()
        }
        
    }
    
    
    
    func showSecondTutorial() {
        
        guard let secondTutorial_Top_One = childNode(withName: "SecondTutorial_Top_One")
            as? SKSpriteNode else {
                fatalError("SecondTutorial_Top_One node not loaded")
        }
        
        guard let secondTutorial_Bottom_One = childNode(withName: "SecondTutorial_Bottom_One")
            as? SKSpriteNode else {
                fatalError("SecondTutorial_Bottom_One node not loaded")
        }
        
        let scaleUp = SKAction.scale(to: 1, duration: 0.25)
        
        secondTutorial_Top_One.run(scaleUp)
        secondTutorial_Bottom_One.run(scaleUp)
    }
    
    func transitionToThirdTutorial() {
        
        guard let secondTutorial_Top_One = childNode(withName: "SecondTutorial_Top_One")
            as? SKSpriteNode else {
                fatalError("SecondTutorial_Top_One node not loaded")
        }
        
        guard let secondTutorial_Bottom_One = childNode(withName: "SecondTutorial_Bottom_One")
            as? SKSpriteNode else {
                fatalError("SecondTutorial_Bottom_One node not loaded")
        }
        
        let scaleDown = SKAction.scale(to: 0, duration: 0.25)
        
        secondTutorial_Top_One.run(scaleDown)
        secondTutorial_Bottom_One.run(scaleDown)
        
        afterDelay(0.25) {
            self.showThirdTutorial()
        }
    }
    
    func showThirdTutorial() {
        
        guard let thirdTutorial_Top_One = childNode(withName: "ThirdTutorial_Top_One")
            as? SKSpriteNode else {
                fatalError("ThirdTutorial_Top_One node not loaded")
        }
        
        
        let scaleUp = SKAction.scale(to: 1, duration: 0.25)
        
        thirdTutorial_Top_One.run(scaleUp)
    }
    
    
    func showEndsTutorial() {
        
        guard let thirdTutorial_Top_One = childNode(withName: "ThirdTutorial_Top_One")
            as? SKSpriteNode else {
                fatalError("ThirdTutorial_Top_One node not loaded")
        }
        
        let scaleDown = SKAction.scale(to: 0, duration: 0.25)
        
        thirdTutorial_Top_One.run(scaleDown)
        
        guard let thirdTutorial_Bottom_One = self.childNode(withName: "ThirdTutorial_Bottom_One")
            as? SKSpriteNode else {
                fatalError("ThirdTutorial_Bottom_One node not loaded")
        }
        
        cleanScene()
        
        let scaleUp = SKAction.scale(to: 1, duration: 0.25)
        let delay = SKAction.afterDelay(0.25, performAction: scaleUp)
        let wait = SKAction.wait(forDuration: 2)
        let sequence = SKAction.sequence([delay, wait])
        thirdTutorial_Bottom_One.run(sequence) {
            let scaleDown = SKAction.scale(to: 0, duration: 0.25)
            thirdTutorial_Bottom_One.run(scaleDown)
            self.menuVC?.transitionBack(from: self.scene)
        }
    }
    
    
    func updateNodeForDarkMode() {
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .white : .black
        for child in children {
            if child is SKLabelNode , child.name != "number" {
                (child as! SKLabelNode).colorBlendFactor = 1
                (child as! SKLabelNode).fontColor = color
            } else if child is SKSpriteNode {
                for grandchild in child.children {
                    if grandchild is SKLabelNode , grandchild.name != "number"{
                        (grandchild as! SKLabelNode).colorBlendFactor = 1
                        (grandchild as! SKLabelNode).fontColor = color
                    }
                }
            }
        }
        
    }
    
}


