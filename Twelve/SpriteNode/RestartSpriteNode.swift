//
//  RestartSpriteNode.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/31/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

protocol RestartSpriteNodeDelegate : class {
    func restartGame()
}

class RestartSpriteNode : SKSpriteNode {
    weak var delegate:RestartSpriteNodeDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.restartGame()
    }
}
