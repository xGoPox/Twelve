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

    let effectNode = SKEffectNode()
    let shape: SKShapeNode!
    let roundShape: SKShapeNode!
    var possibility: Element?

    var oldNumber: Int = 12
    let numberLabel: SKLabelNode!
    
    var currentNumber: Int = 12 {
        willSet(number) {
            if number != currentNumber {
                let fadeIn = SKAction.fadeIn(withDuration: 0.1)
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                numberLabel.run(fadeOut) {
                    self.numberLabel.text = String(number)
                    self.numberLabel.run(fadeIn)
                }
            }
        }
        didSet(number) {
            if number != currentNumber {
                shape?.strokeColor = colorType
                shape.removeAction(forKey: "selected")
                shape.setScale(1)
                if currentNumber == number.followingNumber() {
                    
                    let pulseUp = SKAction.scale(to: 1.3, duration: 0.20)
                    let pulseDown = SKAction.scale(to: 1, duration: 0.20)
                    let pulse = SKAction.sequence([pulseUp, pulseDown])
                    let repeatAction = SKAction.repeatForever(pulse)
                    shape.run(repeatAction , withKey: "selected")
                }


                let color = getColorFadeAction(startColor: roundShape.fillColor, endColor: colorType, duration: 0.75)
                roundShape.run(color)
            }
        }
    }
    
    
    var colorType: UIColor {
        get {
            switch currentNumber {
            case 1...3:
                return .myGreen
            case 4...6:
                return .myRed
            case 7...9:
                return .myYellow
            case 10...12:
                return .myBlue
            default:
                return .clear
            }
        }
    }
    
    
    init() {
        numberLabel = SKLabelNode(fontNamed:"Exo2-Medium")
        shape = SKShapeNode()
        roundShape = SKShapeNode()
        super.init(texture: nil, color: .clear, size: CGSize(width: 70, height: 70))
        name = "PileSprite"
        numberLabel.fontSize = 40
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.verticalAlignmentMode = .center
        numberLabel.isUserInteractionEnabled = false
        numberLabel.fontColor = .white
        numberLabel.text = String(currentNumber)
        shape.isUserInteractionEnabled = false
        let corners : UIRectCorner = [UIRectCorner.allCorners]
        shape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: size).cgPath
        shape.position = CGPoint(x: frame.midX, y:    frame.midY)
        shape.lineWidth = 2
        shape.fillColor = .white
        shape.setScale(1.05)
        roundShape.isUserInteractionEnabled = false
        roundShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: size).cgPath
        roundShape.position = CGPoint(x: frame.midX, y:    frame.midY)
        roundShape.lineWidth = 1
        roundShape.setScale(0.9)
        shape.strokeColor = colorType
        roundShape.fillColor = colorType
        roundShape.strokeColor = colorType
        addChild(shape)
        addChild(roundShape)
        addChild(numberLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        possibility = nil
        updateWithLastNumber(12)
    }
    
    func updateWithLastNumber(_ number: Int) {
        shape.removeAction(forKey: "selected")
        shape.setScale(1)
        oldNumber = number
        currentNumber = number
        print("UPDATE pile from old number \(oldNumber) with new number \(number) : currentNumber:  \(currentNumber)")
    }
    
    func resetForFalseCombo() {
        shape.removeAction(forKey: "selected")
        shape.setScale(1)
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
    
    func previousNumber() -> Int {
        return currentNumber.previousNumber()
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


private func getColorFadeAction(startColor: UIColor, endColor: UIColor, duration: TimeInterval) -> SKAction {
    // Create a custom action for color fade
    let action = SKAction.customAction(withDuration: duration) {(node, elapsedTime) in
        if let node = node as? SKShapeNode {
            var color = endColor
            // Calculate the changing color during the elapsed time.
            let fraction = elapsedTime / CGFloat(duration)
            if let startColorRGB = startColor.rgb(), let endColorRGB = endColor.rgb(){
                let red = CGFloat().lerp(start: startColorRGB.red, end: endColorRGB.red, t: fraction)
                let green = CGFloat().lerp(start: startColorRGB.green, end: endColorRGB.green, t: fraction)
                let blue = CGFloat().lerp(start: startColorRGB.blue, end: endColorRGB.blue, t: fraction)
                let alpha = CGFloat().lerp(start: startColorRGB.alpha, end: endColorRGB.alpha, t: fraction)
                
                color = UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
            }
            // Node properties to change.
            node.strokeColor = color
            node.fillColor = color
        }
    }
    return action
}



