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
    mutating func addUpComboWith(number: Int, on piles : [Pile]) throws
    mutating func doneWithCombo() throws -> ComboResult
    func points() -> Int
}


struct Combo: ComboHandler {
    
    var lastNumber: Int?
    
    
    var numbers: [Int]
    var possiblePiles: [Pile]?

   private func isNumberValidForCombo(number: Int, on piles : [Pile]) -> Bool {
    print(piles)
        return piles.first { $0.acceptFollowingNumber(number) } != nil
    }
    
    mutating func addUpComboWith(number: Int, on piles : [Pile]) throws {
        
        guard isNumberValidForCombo(number: number, on: piles) == true || number == -1 else {
            throw TwelveError.numberIsNotFollowingPile
        }
        
        if number == -1 && possiblePiles == nil {
            possiblePiles = piles
            for pile in possiblePiles! {
                pile.currentNumber = pile.currentNumber.followingNumber()
            }
            numbers.append(number)
        } else if let finalNumber = (number == -1) ? piles.first?.currentNumber.followingNumber() : number {
            possiblePiles = piles
            lastNumber = finalNumber
            if numbers.count == 1 {
                if numbers[0] == -1 && finalNumber == 1 {
                    numbers[0] = 12
                }
                while possiblePiles!.count > 1 {
                    let pile = possiblePiles!.removeLast()
                    pile.resetForFalseCombo()
                }
            }
            for pile in possiblePiles! {
                pile.currentNumber = finalNumber
            }
            numbers.append(finalNumber)
        }
    }
    
   private  func isComboValid() -> Bool {
        return numbers.count > 1
    }
    
    mutating func doneWithCombo() throws -> ComboResult {
        guard let number = lastNumber else {
            throw TwelveError.lastNumberIsNill
        }
        if isComboValid() {
            // update the pile
            print("COMBO IS VALID")
            possiblePiles?.first?.updateWithLastNumber(number)
            let total = points()
            let comboResult = ComboResult(points: total, comboOf: numbers.count, numberOfTwelve : numbers.filter{ $0 == 12}.count)
            numbers.removeAll()
            possiblePiles = nil
            return comboResult
        } else {
            print("COMBO IS NOT VALID")
           _ = possiblePiles?.map { $0.resetForFalseCombo() }
            numbers.removeAll()
            possiblePiles = nil
            throw TwelveError.falseCombo
        }
    }
    
    func points() -> Int {
        let pts = numbers.count * numbers.count
        return pts
    }
}
