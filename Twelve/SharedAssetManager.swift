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

    var scene: GKScene?

    func loadTextures() {
        let atlas = SKTextureAtlas(named: "Sprites")
        atlas.preload {
            self.numberFrozenTexture = atlas.textureNamed("NumberSelectedFrozen")
            self.numberTexture = atlas.textureNamed("NumberSelected")
            self.jokerTexture = atlas.textureNamed("Joker")
        }
    }
    
    func loadScene() {
        DispatchQueue.global().async {
            
            if let scene = GKScene(fileNamed: "GameScene") {
                self.scene = scene
            }

            DispatchQueue.main.async(execute: {
                
            })
        }

    }
    
}
