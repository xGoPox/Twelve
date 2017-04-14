//
//  ResultScene.swift
//  Twelve
//
//  Created by Clement Yerochewski on 05/04/2017.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class ResultScene: KVOScene {

    var menuVC: MenuViewController?

    override func didMove(to view: SKView) {
        prepareView()
        backgroundColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
        afterDelay(0.15) {
           print("points \(SharedGameManager.sharedInstance.gameCaracteristic.points)")
           print("seconds \(SharedGameManager.sharedInstance.gameCaracteristic.seconds)")
        }
    }
    
    func prepareView() {
        
        guard let scoreContainerNode = childNode(withName: "scoreContainerNode")
            as? SKSpriteNode else {
                fatalError("scoreContainerNode node not loaded")
        }
        
        guard let scoreTitle = scoreContainerNode.childNode(withName: "scoreTitle")
            as? SKLabelNode else {
                fatalError("scoreTitle node not loaded")
        }
        
        guard let scoreResult = scoreContainerNode.childNode(withName: "scoreResult")
            as? SKLabelNode else {
                fatalError("scoreResult node not loaded")
        }
        
        
        guard let bestScoreContainerNode = childNode(withName: "bestScoreContainerNode")
            as? SKSpriteNode else {
                fatalError("testButton node not loaded")
        }
        
        guard let bestScoreTitle = bestScoreContainerNode.childNode(withName: "bestScoreTitle")
            as? SKLabelNode else {
                fatalError("bestScoreTitle node not loaded")
        }
        
        guard let bestScoreResult = bestScoreContainerNode.childNode(withName: "bestScoreResult")
            as? SKLabelNode else {
                fatalError("bestScoreResult node not loaded")
        }
        
        
        guard let timesUp = bestScoreContainerNode.childNode(withName: "timesUp")
            as? SKLabelNode else {
                fatalError("timesUp node not loaded")
        }

        
        let title = (SharedGameManager.sharedInstance.gameCaracteristic.mode == .classic) ? "points" : "seconds"
        
        let titleBest = (SharedGameManager.sharedInstance.gameCaracteristic.mode == .classic) ? "best score" : "best time"

        timesUp.colorBlendFactor = 1
        timesUp.fontColor = SharedGameManager.sharedInstance.settings.darkMode ? .white : .black

        bestScoreTitle.colorBlendFactor = 1
        bestScoreTitle.fontColor = SharedGameManager.sharedInstance.settings.darkMode ? .white : .black
        
        
        scoreResult.colorBlendFactor = 1
        scoreResult.fontColor = SharedGameManager.sharedInstance.settings.darkMode ? .white : .black
        
        let score = (SharedGameManager.sharedInstance.gameCaracteristic.mode == .classic) ? SharedGameManager.sharedInstance.gameCaracteristic.points : SharedGameManager.sharedInstance.gameCaracteristic.seconds
        
        let bestScore = (SharedGameManager.sharedInstance.gameCaracteristic.mode == .classic) ? SharedGameManager.sharedInstance.bestPoints : SharedGameManager.sharedInstance.bestTime


        scoreTitle.text = title
        scoreResult.text = "\(score)"
        
        bestScoreTitle.text = titleBest
        bestScoreResult.text = "\(bestScore)"

        
    }
    
    func showView() {
        
        
        guard let statisticNode = childNode(withName: "statisticNode")
            as? SKSpriteNode else {
                fatalError("statisticNode node not loaded")
        }
        guard let menuNode = childNode(withName: "MenuNode")
            as? SKSpriteNode else {
                fatalError("MenuNode node not loaded")
        }
        guard let rateNode = childNode(withName: "rateNode")
            as? SKSpriteNode else {
                fatalError("rateNode node not loaded")
        }
        
        let futurPosition = self.frame.minY + (statisticNode.size.height / 1.5)

        let show_one = SKAction.moveTo(y: futurPosition, duration: 1, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)

        let show_two = SKAction.moveTo(y: futurPosition, duration: 1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)
        
        let show_three = SKAction.moveTo(y: futurPosition, duration: 1, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)
        
        
        rateNode.run(show_one)
        rateNode.run(show_two)
        menuNode.run(show_three)

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        if let name = atPoint(location).name {
            switch name {
                case "MenuNode":
                    menuVC?.transitionBack(from : self.scene)
                case "RestartNode":
                    menuVC?.transitionFor(gameMode: SharedGameManager.sharedInstance.gameCaracteristic.mode, from: self.scene)
            default:
                print("nothing to care about")
            }
        }
    }

    
}
