//
//  MenuScene.swift
//  Twelve
//
//  Created by Clement Yerochewski on 04/04/2017.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class MenuScene: KVOScene {

    var menuVC: MenuViewController?
    
    override func updateForMode() {
        super.updateForMode()
        guard let classicButton = childNode(withName: TwelveNode.classicNode.rawValue)
            as? SKSpriteNode else {
                fatalError("\(TwelveNode.classicNode.rawValue) node not loaded")
        }
        
        
        guard let classicButtonNode = classicButton.childNode(withName: TwelveNode.classicNode.rawValue + "Button")
            as? SKSpriteNode else {
                fatalError("\(TwelveNode.classicNode.rawValue + "Button") node not loaded")
        }

        guard let classicLabelNode = classicButton.childNode(withName: TwelveNode.classicNode.rawValue)
            as? SKLabelNode else {
                fatalError("\(TwelveNode.classicNode.rawValue) node not loaded")
        }
        
        guard let survivalButton = childNode(withName: TwelveNode.survivalNode.rawValue)
            as? SKSpriteNode else {
                fatalError("\(TwelveNode.survivalNode.rawValue) node not loaded")
        }
        
        guard let survivalButtonNode = survivalButton.childNode(withName: TwelveNode.survivalNode.rawValue + "Button")
            as? SKSpriteNode else {
                fatalError("\(TwelveNode.survivalNode.rawValue + "Button") node not loaded")
        }

        guard let survivalLabelNode = survivalButton.childNode(withName: TwelveNode.survivalNode.rawValue)
            as? SKLabelNode else {
                fatalError("\(TwelveNode.classicNode.rawValue) node not loaded")
        }
        
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white

        classicButtonNode.texture = SharedAssetsManager.sharedInstance.classicButton
        survivalButtonNode.texture = SharedAssetsManager.sharedInstance.survivalButton
        
        survivalLabelNode.colorBlendFactor = 1
        classicLabelNode.colorBlendFactor = 1
        classicLabelNode.fontColor = color
        survivalLabelNode.fontColor = color

    }
    
    
    override func didMove(to view: SKView) {
        updateForMode()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        if let name = atPoint(location).name {
            switch name {
            case TwelveNode.tutorialNode.rawValue:
                showTutorial()
            case TwelveNode.settingsNode.rawValue:
                showSettings()
            case TwelveNode.classicNode.rawValue, TwelveNode.classicNode.rawValue + "Button":
                selectModeForTwelveNode(TwelveNode.classicNode)
            case TwelveNode.survivalNode.rawValue,  TwelveNode.survivalNode.rawValue + "Button":
                selectModeForTwelveNode(TwelveNode.survivalNode)
            default:
                print("nothing to care about")
            }
        }        
    }

    
    func showSettings() {
        touchMenuNode(TwelveNode.settingsNode) {
            self.menuVC?.performSegue(withIdentifier: "showSettings", sender: nil)
        }
    }
    
    
    func showTutorial() {
        touchMenuNode(TwelveNode.tutorialNode) { 
            self.menuVC?.transitionTutorial(from: self.scene)
        }
    }
    
    func touchMenuNode(_ nodeName : TwelveNode, completion: @escaping () -> Void) {
        guard let button = childNode(withName: nodeName.rawValue)
            as? SKSpriteNode else {
                fatalError("\(nodeName.rawValue) node not loaded")
        }
        
        let scaleUp = SKAction.scaleX(to: 1.25, y: 0.75, duration: 0.10, delay: 0,
                                      usingSpringWithDamping: 0.8, initialSpringVelocity: 0)
        let scaleDown = SKAction.scaleX(to: 1, y: 1, duration: 0.10, delay: 0,
                                        usingSpringWithDamping: 0.8, initialSpringVelocity: 0)
        
        button.run(SKAction.sequence([scaleUp, scaleDown])) {
            completion()
        }

    }
    
    func selectModeForTwelveNode(_ twelveNode : TwelveNode) {
        
        guard let buttonContainer = childNode(withName: twelveNode.rawValue)
            as? SKSpriteNode else {
                fatalError("testButton node not loaded")
        }
        
        buttonContainer.zPosition = 10
        
        guard let labelNode = buttonContainer.childNode(withName: twelveNode.rawValue)
            as? SKLabelNode else {
                fatalError("labelNode node not loaded")
        }

        labelNode.zPosition = 9
        guard let buttonNode = buttonContainer.childNode(withName: "button")
            as? SKSpriteNode else {
                fatalError("buttonNode node not loaded")
        }
        
        buttonNode.zPosition = 8
        
//        labelNode.fontColor = .black
        
        let centerAction = SKAction.move(to: CGPoint(x:0, y: 0), duration: 0.25)
        buttonContainer.run(centerAction) {
            let scaleUpLabel = SKAction.scale(to: 1, duration: 0.20)
            labelNode.run(scaleUpLabel)
        }
        let scaleUp = SKAction.scale(to: 20, duration: 0.5)
//        let scaleToDefault = SKAction.scale(to: 1, duration: 0.15)
        let delayAction = SKAction.afterDelay(0.10) { 
            self.menuVC?.transitionFor(gameMode: (twelveNode == .classicNode)  ? .classic : .survival, from: self.scene)
        }
        let sequence = SKAction.sequence([scaleUp, delayAction])
        buttonNode.run(sequence)
    }
    
}
