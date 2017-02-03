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
    
    var oldNumber: Int = 12
    var label: SKLabelNode?
    var currentNumber: Int = 12 {
        willSet(number) {
            if let lbl = label {
                lbl.text = String(number)
            }
            guard let node = childNode(withName: "deck_label")
                as? SKLabelNode else {
                    fatalError("deck_label node not loaded")
            }
            label = node
        }
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
