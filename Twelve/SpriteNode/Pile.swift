//
//  Pile.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation
import SpriteKit

protocol PileHandler {
    var currentNumber: Int { get set }
    var oldNumber: Int { get set }
    mutating func updateWithLastNumber(_ number: Int)
    mutating func resetForFalseCombo()
}


class Pile : SKSpriteNode, PileHandler {

    let shape: SKShapeNode!
    var oldNumber: Int = 12
    let numberLabel: SKLabelNode!
    var currentNumber: Int = 12 {
        willSet(number) {
            numberLabel.text = String(number)
        }
        didSet(number) {
            shape?.fillColor = colorType
        }
    }
    
    var colorType: SKColor {
        get {
            switch currentNumber {
            case 1...4:
                return UIColor(red: 81/255, green: 77/255, blue: 152/255, alpha: 1.0)
            case 5...8:
                return UIColor(red: 183/255, green: 77/255, blue: 127/255, alpha: 1.0)
            case 9...12:
                return UIColor(red: 63/255, green: 149/255, blue: 114/255, alpha: 1.0)
            default:
                return UIColor(red: 63/255, green: 149/255, blue: 114/255, alpha: 1.0)
            }
        }
    }
    
    init() {
        numberLabel = SKLabelNode(fontNamed:"MarkerFelt-Thin")
        shape = SKShapeNode()
        super.init(texture: nil, color: .clear, size: CGSize(width: 60, height: 60))
        numberLabel.fontSize = 30
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.verticalAlignmentMode = .center
        numberLabel.isUserInteractionEnabled = false
        shape.isUserInteractionEnabled = false
        let corners : UIRectCorner = [UIRectCorner.allCorners]
        shape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: size).cgPath
        shape.position = CGPoint(x: frame.midX, y:    frame.midY)
        shape.lineWidth = 1
        addChild(numberLabel)
        addChild(shape)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWithLastNumber(_ number: Int) {
    
        oldNumber = number
        currentNumber = number
        print("UPDATE pile from old number \(oldNumber) with new number \(number) : currentNumber:  \(currentNumber)")
    }
    
    func resetForFalseCombo() {
        currentNumber = oldNumber
        print("RESET pile currentNumber \(oldNumber) with old number \(oldNumber)")
    }
    
    
    
    
    
}
protocol PileValidator {
    func followingNumber() -> Int
    func acceptFollowingNumber(_ number: Int) -> Bool
}

extension Pile : PileValidator {
    
    func followingNumber() -> Int {
        return currentNumber.followingNumber()
    }
    
    func acceptFollowingNumber(_ number: Int) -> Bool {
        if currentNumber == 12 , number == 1 {
            return true
        } else if currentNumber + 1 == number {
            return true
        }
        return false
    }
}
