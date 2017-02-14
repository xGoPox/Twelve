//
//  ComboBar.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/11/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation
import SpriteKit

class ComboBar : SKSpriteNode {
    
    let denomiator = 3.73 / 60.0
    let total = 60.0

    var value : Double = 0 {
        willSet(newValue) {
            let scaleValue = denomiator * newValue
            let scale = SKAction.scaleX(to: CGFloat(scaleValue), duration: TimeInterval(1))
            if color != colorType {
                let colorize = SKAction.colorize(with: colorType, colorBlendFactor: 1, duration: 1)
                let group = SKAction.group([scale, colorize])
                run(group)
            } else {
                run(scale)
            }
        }
    }
    
    
    var colorType: UIColor {
        get {
            switch value {
            case 0...16:
                return UIColor(red: 66/255.0, green: 139/255.0, blue: 202/255.0, alpha: 1)
            case 17...31:
                return UIColor(red: 240/255.0, green: 173/255.0, blue: 78/255.0, alpha: 1)
            case 32...46:
                return UIColor(red: 217/255.0, green: 83/255.0, blue: 79/255.0, alpha: 1)
            default:
                return UIColor(red: 34/255, green: 181/255.0, blue: 115/255.0, alpha: 1)

            }
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // To check it worked:
    }


}
