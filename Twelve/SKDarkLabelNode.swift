//
//  SKDarkLabelNode.swift
//  Twelve
//
//  Created by Clement Yerochewski on 07/04/2017.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import UIKit
import SpriteKit


class SKDarkLabelNode : SKLabelNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // To check it worked:
        fontColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
    }
    
}
