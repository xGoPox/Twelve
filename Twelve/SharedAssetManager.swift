//
//  SharedAssetManager.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/19/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class SharedAssetsManager {
    
    static let sharedInstance = SharedAssetsManager()
    
    //Keep these private for safety.
    var numberTexture: SKTexture?
    var jokerTexture: SKTexture?
    
    var numberFrozenTexture: SKTexture?
    var menuButtonClassicDark: SKTexture?
    var menuButtonClassic: SKTexture?
    
    var menuButtonSurvivalDark: SKTexture?
    var menuButtonSurvival: SKTexture?

 
    var redHand: SKTexture?
    var yellowHand: SKTexture?
    var greenHand: SKTexture?
    var blueHand: SKTexture?
    var gameScene: GKScene?
    var resultScene: GKScene?

    var menuScene: GKScene? {
        get {
            if let scene = GKScene(fileNamed: "MenuScene") {
                return scene
            } else {
                return nil
            }
        }
    }
    var tutorialScene: GKScene?


    var classicButton: SKTexture? {
        get {
            if SharedGameManager.sharedInstance.settings.darkMode {
                return self.menuButtonClassicDark
            } else {
                return self.menuButtonClassic
            }
        }
    }
    
    var survivalButton: SKTexture? {
        get {
            if SharedGameManager.sharedInstance.settings.darkMode {
                return self.menuButtonSurvivalDark
            } else {
                return self.menuButtonSurvival
            }
        }
    }

    func loadTextures() {
        let atlas = SKTextureAtlas(named: "Sprites")
        atlas.preload {
            self.numberFrozenTexture = atlas.textureNamed("NumberSelectedFrozen")
            self.numberTexture = atlas.textureNamed("NumberSelected")
            self.jokerTexture = atlas.textureNamed("Joker")
            self.redHand = atlas.textureNamed("Hand-Red")
            self.blueHand = atlas.textureNamed("Hand-Blue")
            self.yellowHand = atlas.textureNamed("Hand-Yellow")
            self.greenHand = atlas.textureNamed("Hand-Green")
            self.menuButtonClassic = atlas.textureNamed("classic_button")
            self.menuButtonClassicDark = atlas.textureNamed("classic_button_dark")
            self.menuButtonSurvival = atlas.textureNamed("survival_button")
            self.menuButtonSurvivalDark = atlas.textureNamed("survival_button_dark")
        }
    }
    
    func loadScene() {
        DispatchQueue.global().async {
            
            if let scene = GKScene(fileNamed: "GameScene") {
                self.gameScene = scene
            }
            
            if let scene = GKScene(fileNamed: "ResultScene") {
                self.resultScene = scene
            }
            
            
            if let scene = GKScene(fileNamed: "TutorialScene") {
                self.tutorialScene = scene
            }

        }

    }
    
}
