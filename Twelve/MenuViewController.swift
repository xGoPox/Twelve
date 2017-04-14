//
//  MenuViewController.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/18/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import UIKit
import GameKit


class MenuViewController: UIViewController {
    
    var leaderboardIdentifier: String? = nil
    var gameCenterEnabled: Bool = false
    
    var menuScene: MenuScene? {
        willSet(scene) {
            self.currentScene = scene
        }
    }
    var gameScene: GameScene? {
        willSet(scene) {
            self.currentScene = scene
        }
    }
    
    var resultScene: ResultScene?  {
        willSet(scene) {
            self.currentScene = scene
        }
    }
    
    
    var tutorialScene: TutorialScene?  {
        willSet(scene) {
            self.currentScene = scene
        }
    }
    

    
    var currentScene: KVOScene?
    
    private var observerContext = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedGameManager.sharedInstance.settings.addObserver(self, forKeyPath: "darkMode", options: [.new, .old], context: &observerContext)

        //        authenticateLocalPlayer()
        SharedAssetsManager.sharedInstance.loadTextures()
        SharedAssetsManager.sharedInstance.loadScene()
        loadScene()
        // Do any additional setup after loading the view.
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        
        if let newValue = change?[.newKey] as? Bool, let oldValue = change?[.oldKey] as? Bool, newValue != oldValue {
            currentScene?.updateForMode()
                        
        }
    }
    
    func loadScene() {
        
        if let scene = SharedAssetsManager.sharedInstance.menuScene {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! MenuScene? {
                self.menuScene = sceneNode
                sceneNode.menuVC = self
                sceneNode.scaleMode = .aspectFit
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    //                    view.ignoresSiblingOrder = true
                    //                    view.showsFPS = true
                    //                    view.showsNodeCount = true
                }
            }
        }
        
        
    }
    
    func transitionFor(gameMode: GameMode, from currentScene: SKScene?) {
        
        var reveal: SKTransition?
        if currentScene is ResultScene {
            let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
            reveal = SKTransition.fade(with: color, duration: 0.5)
        } else {
            reveal = SKTransition.fade(with: (gameMode == .classic) ? UIColor.myGreen : UIColor.myBlue, duration: 0.5)
        }
        
        reveal?.pausesOutgoingScene = false
        reveal?.pausesIncomingScene = false

        SharedGameManager.sharedInstance.gameCaracteristic.mode = gameMode
        
        if let scene = SharedAssetsManager.sharedInstance.gameScene {
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                sceneNode.scaleMode = .aspectFit
                self.gameScene = sceneNode
                self.gameScene?.menuVC = self
                // Present the scene
                currentScene?.view?.presentScene(sceneNode, transition: reveal!)
            }
        }
        
    }
    
    
    func transitionTutorial(from currentScene: SKScene?) {
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
        let reveal = SKTransition.fade(with: color, duration: 0.5)
        reveal.pausesOutgoingScene = false
        reveal.pausesIncomingScene = false

        if let scene = SharedAssetsManager.sharedInstance.tutorialScene {
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! TutorialScene? {
                sceneNode.scaleMode = .aspectFit
                self.tutorialScene = sceneNode
                self.tutorialScene?.menuVC = self
                // Present the scene
                currentScene?.view?.presentScene(sceneNode, transition: reveal)
            }
        }
        
    }

    
    
    func transitionBack(from currentScene: SKScene?) {
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white

        let reveal = SKTransition.fade(with: color, duration: 0.5)
        
        reveal.pausesOutgoingScene = false
        reveal.pausesIncomingScene = false
        // Get the SKScene from the loaded GKScene
        
        if let scene = SharedAssetsManager.sharedInstance.menuScene {
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! MenuScene? {
                self.menuScene = sceneNode
                sceneNode.menuVC = self
                sceneNode.scaleMode = .aspectFit
                // Present the scene
                //                if let view = self.view as! SKView? {
                currentScene?.view?.presentScene(sceneNode, transition: reveal)
                //                    view.ignoresSiblingOrder = true
                //                    view.showsFPS = true
                //                    view.showsNodeCount = true
            }
            //            }
        }
        
    }
    
    
    func transitionResultGame() {
        
        let color: SKColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white

        let reveal = SKTransition.fade(with: color, duration: 0.7)
        
        reveal.pausesOutgoingScene = false
        reveal.pausesIncomingScene = false
        // Get the SKScene from the loaded GKScene
        if let scene = SharedAssetsManager.sharedInstance.resultScene {
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! ResultScene? {
                resultScene = sceneNode
                sceneNode.menuVC = self
                sceneNode.scaleMode = .aspectFit
                // Present the scene
                //                if let view = self.view as! SKView? {
                self.gameScene?.view?.presentScene(sceneNode, transition: reveal)
                //                    view.ignoresSiblingOrder = true
                //                    view.showsFPS = true
                //                    view.showsNodeCount = true
                //                }
            }
            
        }
    }
    
    
    
    
    func authenticateLocalPlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if viewController != nil {
                self.view?.window?.rootViewController?.present(viewController!, animated: true, completion: nil)
            }
            else if localPlayer.isAuthenticated {
                // You can start using Game Center
            }
            else {
                // Don't use Game Center
            }
        }
        
    }
    
    
    @IBAction func unwindSegueToMainMenu(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
