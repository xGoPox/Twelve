//
//  EndScoreNode.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/31/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit


class EndScoreNode : SKSpriteNode {
    
    var label: SKLabelNode?
    var score: Int = 12 {
        willSet(number) {
            if let lbl = label {
                lbl.text = String(number)
            }
            guard let node = childNode(withName: "scoreValue")
                as? SKLabelNode else {
                    fatalError("scoreValue node not loaded")
            }
            label = node
            label?.text = String(number)
        }
    }
}
