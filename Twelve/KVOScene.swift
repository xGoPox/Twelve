//
//  KVOScene.swift
//  Twelve
//
//  Created by Clement Yerochewski on 07/04/2017.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class KVOScene: SKScene {

    func updateForMode() {
        backgroundColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
    }
    

}
