//
//  Joker.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/17/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import SpriteKit

class Joker: Element {
    
    override init(gridPosition: GridPosition) {
        super.init(gridPosition: gridPosition)
        self.value = -1
        self.texture = SKTexture(imageNamed: "joker")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension Joker {
    
    override func selected() {
        let pulseUp = SKAction.scale(to: 1.3, duration: 0.20)
        let pulseDown = SKAction.scale(to: 1, duration: 0.20)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatAction = SKAction.repeatForever(pulse)
        run(SKAction.sequence([repeatAction]), withKey: "selected")
    }
    
    override func unselected() {
        let numberScaleBackAction = SKAction.scale(to: 1, duration: 0.15)
        run(numberScaleBackAction)
        removeAction(forKey: "selected")
    }

}
