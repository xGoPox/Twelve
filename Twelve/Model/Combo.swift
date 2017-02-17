//
//  Combo.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation


typealias ComboResult = (points: Int , comboOf: Int, numberOfTwelve: Int)


protocol ComboHandler {
    var numbers: [Int] { get set }
    var lastNumber: Int? { get set }
    mutating func addUpComboWith(number: Int, on pile :  Pile) throws
    mutating func doneWithCombo(frozenMode: Bool) throws -> ComboResult
    func points() -> Int
}


struct Combo: ComboHandler {
    
    var lastNumber: Int?
    
    
    var numbers: [Int]
    var currentPile: Pile?
    
   private func isNumberValidForCombo(number: Int, on pile : Pile) -> Bool {
        return pile.acceptFollowingNumber(number)
    }
    
    mutating func addUpComboWith(number: Int, on pile : Pile) throws {
        print("current number of pile : \(pile.currentNumber) - old number \(pile.oldNumber)")
        guard isNumberValidForCombo(number: number, on: pile) == true else {
            throw TwelveError.numberIsNotFollowingPile
        }
        let finalNumber = number == -1 ? pile.currentNumber.followingNumber() : number
        currentPile = pile
        lastNumber = finalNumber
        currentPile?.currentNumber = finalNumber
        print("current number of pile : \(pile.currentNumber) - old number \(pile.oldNumber)")
        numbers.append(finalNumber)
    }
    
   private  func isComboValid() -> Bool {
        return numbers.count > 1
    }
    
    mutating func doneWithCombo(frozenMode: Bool) throws -> ComboResult {
        guard let number = lastNumber else {
            throw TwelveError.lastNumberIsNill
        }
        if isComboValid() || frozenMode {
            // update the pile
            print("COMBO IS VALID")
            currentPile?.updateWithLastNumber(number)
            let total = points()
            let comboResult = ComboResult(points: total, comboOf: numbers.count, numberOfTwelve : numbers.filter{$0 == 12}.count)
            numbers.removeAll()
            currentPile = nil
            return comboResult
        } else {
            print("COMBO IS NOT VALID")
            currentPile?.resetForFalseCombo()
            numbers.removeAll()
            currentPile = nil
            throw TwelveError.falseCombo
        }
    }
    
    func points() -> Int {
        let pts = numbers.count * numbers.count
        return pts
    }
}
