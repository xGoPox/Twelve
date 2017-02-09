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
    
    
    var colorType: UIColor {
        get {
            switch currentNumber {
            case 1...3:
                return UIColor(red: 34/255, green: 181/255.0, blue: 115/255.0, alpha: 1)
            case 4...6:
                return UIColor(red: 217/255.0, green: 83/255.0, blue: 79/255.0, alpha: 1)
            case 7...9:
                return UIColor(red: 240/255.0, green: 173/255.0, blue: 78/255.0, alpha: 1)
            case 10...12:
                return UIColor(red: 66/255.0, green: 139/255.0, blue: 202/255.0, alpha: 1)
            default:
                return .clear
            }
        }
    }
    
    
    init() {
        numberLabel = SKLabelNode(fontNamed:"ChalkboardSE-Light")
        shape = SKShapeNode()
        super.init(texture: nil, color: .clear, size: CGSize(width: 100, height: 100))
        numberLabel.fontSize = 60
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.verticalAlignmentMode = .center
        numberLabel.isUserInteractionEnabled = false
        shape.isUserInteractionEnabled = false
        let corners : UIRectCorner = [UIRectCorner.allCorners]
        shape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: size).cgPath
        shape.position = CGPoint(x: frame.midX, y:    frame.midY)
        shape.strokeColor = UIColor.black
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
