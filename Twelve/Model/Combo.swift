//
//  Combo.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation


protocol ComboHandler {
    var combo: [Int] { get set }
    var lastNumber: Int? { get set }
    mutating func addUpComboWith(number: Int, on pile :  Pile) throws
    mutating func doneWithCombo() throws -> Int
    func points() -> Int
}



struct Combo: ComboHandler {
    
    var lastNumber: Int?
    
    var combo: [Int]
    var currentPile: Pile?
    
   private func isNumberValidForCombo(number: Int, on pile : Pile) -> Bool {
        return pile.acceptFollowingNumber(number)
    }
    
    mutating func addUpComboWith(number: Int, on pile : Pile) throws {
        print("current number of pile : \(pile.currentNumber) - old number \(pile.oldNumber)")
        guard isNumberValidForCombo(number: number, on: pile) == true else {
            throw TwelveError.numberIsNotFollowingPile
        }
        currentPile = pile
        lastNumber = number
        currentPile?.currentNumber = number
        print("current number of pile : \(pile.currentNumber) - old number \(pile.oldNumber)")
        combo.append(number)
    }
    
   private  func isComboValid() -> Bool {
        return combo.count > 1
    }
    
    mutating func doneWithCombo() throws -> Int {
        guard let number = lastNumber else {
            throw TwelveError.lastNumberIsNill
        }
        if isComboValid() {
            // update the pile
            print("COMBO IS VALID")
            currentPile?.updateWithLastNumber(number)
            let total = points()
            combo.removeAll()
            currentPile = nil
            return total
        } else {
            print("COMBO IS NOT VALID")
            currentPile?.resetForFalseCombo()
            combo.removeAll()
            currentPile = nil
            throw TwelveError.falseCombo
        }
    }
    
    func points() -> Int {
        let pts = combo.count * combo.count
        return pts
    }
}
