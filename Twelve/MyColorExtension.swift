//
//  MyColorExtension.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/18/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static var myGreen: UIColor  { return UIColor(red: 34/255, green: 181/255.0, blue: 115/255.0, alpha: 1) }
    static var myRed: UIColor { return UIColor(red: 217/255.0, green: 83/255.0, blue: 79/255.0, alpha: 1) }
    static var myBlue: UIColor { return UIColor(red: 66/255.0, green: 139/255.0, blue: 202/255.0, alpha: 1) }
    static var myYellow: UIColor { return UIColor(red: 240/255.0, green: 173/255.0, blue: 78/255.0, alpha: 1) }
    
    static var myRandomColor: UIColor {
        let value = 1 + Int(arc4random_uniform(UInt32(4 - 1 + 1)))
        switch value {
        case 1:
            return .myGreen
        case 2:
            return .myRed
        case 3:
            return .myYellow
        default:
            return .myBlue
        }
        
    }
    
    
    
    // Function used to get the red, green, and blue values of a UIColor object.
    
    
    
    func rgb() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            // Could extract RGBA components
            return (red:fRed, green:fGreen, blue:fBlue, alpha:fAlpha)
        } else {
            // Could not extract RGBA components
            return nil
        }
    }
    
    
}
