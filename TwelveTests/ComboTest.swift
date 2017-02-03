//
//  ComboTest.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import XCTest

@testable import Twelve


class ComboTest: XCTestCase {
    
    var combo:Combo!
    var gridDispatcher: GridController!
    
    let one  = NumberSpriteNode.init(gridPosition: (0,0), value: 1)
    let two  = NumberSpriteNode.init(gridPosition: (0,1), value: 2)
    let three  = NumberSpriteNode.init(gridPosition: (0,2), value: 3)
    let four  = NumberSpriteNode.init(gridPosition: (0,3), value: 4)
    let five  = NumberSpriteNode.init(gridPosition: (1,0), value: 5)
    let six  = NumberSpriteNode.init(gridPosition: (1,1), value: 6)
    let seven  = NumberSpriteNode.init(gridPosition: (1,2), value: 7)
    let eight  = NumberSpriteNode.init(gridPosition: (1,3), value: 8)
    let nine  = NumberSpriteNode.init(gridPosition: (2,0), value: 9)
    let ten  = NumberSpriteNode.init(gridPosition: (2,1), value: 10)
    let eleven  = NumberSpriteNode.init(gridPosition: (2,2), value: 11)
    let twelve  = NumberSpriteNode.init(gridPosition: (2,2), value: 12)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gridDispatcher = GridController(numberOfGrid: 2)
        combo = Combo.init(lastNumber: nil, combo: [Int](), currentPile: gridDispatcher.pileForNumber(1))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        combo = nil
    }
    
    func testValidationNumberOnPile() {

        XCTAssertNotNil(combo.currentPile)

        let pile = gridDispatcher.pileForNumber(one.value)
        
        XCTAssertNotNil(pile, "pile \(pile) should not be nil")

        XCTAssertThrowsError(try combo.addUpComboWith(number: two.value, on : pile!)) { error in
            XCTAssertEqual(error as? ComboError, ComboError.numberIsNotFollowingPile)
        }
        
        XCTAssertNil(combo.currentPile)
        
        let newPile = gridDispatcher.pileForNumber(one.value)

        do {
            try combo.addUpComboWith(number: one.value, on: newPile!)
            XCTAssertNotNil(combo.currentPile)
            XCTAssertEqual(combo.currentPile?.currentNumber, one.value)

        } catch {
            XCTFail()
        }
        
        
        do {
            try combo.addUpComboWith(number: two.value, on: combo.currentPile!)
            XCTAssertNotNil(combo.currentPile)
            XCTAssertEqual(combo.currentPile?.currentNumber, two.value)
            
        } catch {
            XCTFail()
        }

        
        XCTAssertThrowsError(try combo.addUpComboWith(number: two.value, on : combo.currentPile!)) { error in
            XCTAssertEqual(error as? ComboError, ComboError.numberIsNotFollowingPile)
        }

    }
    

    func testComboOnPile() {
        
        XCTAssertNotNil(combo.currentPile)
        
        var pile = gridDispatcher.pileForNumber(one.value)
        
        XCTAssertNotNil(pile, "pile \(pile) should not be nil")
        

        do {
            try combo.addUpComboWith(number: one.value, on: pile!)
            XCTAssertNotNil(combo.lastNumber)
            XCTAssertNotNil(combo.currentPile, "combo.currentPile \(combo.currentPile) should not be nil")
            XCTAssertEqual(combo.lastNumber, one.value)
            XCTAssertEqual(combo.currentPile!.currentNumber, combo.lastNumber)
            XCTAssertEqual(combo.currentPile!.currentNumber, one.value)
            XCTAssertEqual(combo.combo.last, combo.currentPile!.currentNumber)
            XCTAssertNotEqual(combo.combo.last, combo.currentPile!.oldNumber)
            XCTAssertTrue(combo.combo.count == 1)
        } catch {
            XCTFail()
        }
        
        
        XCTAssertThrowsError(try combo.addUpComboWith(number: four.value, on: combo.currentPile!)) { error in
            XCTAssertEqual(error as? ComboError, ComboError.numberIsNotFollowingPile)
        }
        
        XCTAssertThrowsError(try combo.doneWithCombo()) { error in
            XCTAssertEqual(error as? ComboError, ComboError.falseCombo)
            XCTAssertNil(combo.currentPile)
            XCTAssertTrue(combo.combo.count == 0)
        }
        
        
        XCTAssertNil(gridDispatcher.pileForNumber(two.value))


        pile = gridDispatcher.pileForNumber(one.value)

        XCTAssertNotNil(pile, "pile \(pile) should not be nil")

        do {
            try combo.addUpComboWith(number: one.value, on: pile!)
            XCTAssertNotNil(combo.currentPile, "combo.currentPile \(combo.currentPile) should not be nil")
            XCTAssertNotNil(combo.lastNumber)
            XCTAssertEqual(combo.lastNumber, one.value)
            XCTAssertEqual(combo.currentPile!.currentNumber, combo.lastNumber)
            XCTAssertEqual(combo.currentPile!.currentNumber, one.value)
            XCTAssertEqual(combo.combo.last, combo.currentPile!.currentNumber)
            XCTAssertNotEqual(combo.combo.last, combo.currentPile!.oldNumber)
        } catch {
            XCTFail()
        }
        
        
        XCTAssertNotNil(combo.currentPile)

        do {
            try combo.addUpComboWith(number: two.value, on: combo.currentPile!)
            XCTAssertNotNil(combo.currentPile, "combo.currentPile \(combo.currentPile) should not be nil")
            XCTAssertNotNil(combo.lastNumber)
            XCTAssertEqual(combo.lastNumber, two.value)
            XCTAssertEqual(combo.currentPile!.currentNumber, combo.lastNumber)
            XCTAssertEqual(combo.currentPile!.currentNumber, two.value)
            XCTAssertEqual(combo.combo.last, combo.currentPile!.currentNumber)
            XCTAssertNotEqual(combo.combo.last, combo.currentPile!.oldNumber)
        } catch {
            XCTFail()
        }
        
        XCTAssertNotNil(combo.currentPile)

        
        XCTAssertThrowsError(try combo.addUpComboWith(number: five.value, on: combo.currentPile!)) { error in
            XCTAssertEqual(error as? ComboError, ComboError.numberIsNotFollowingPile)
        }
        
        do {
           let points = try combo.doneWithCombo()
            XCTAssertEqual(points, 4)
            XCTAssertNil(combo.currentPile)
            XCTAssertTrue(combo.combo.count == 0)
        } catch {
            XCTFail()
        }
        
        XCTAssertNil(combo.currentPile)

        XCTAssertNil(gridDispatcher.pileForNumber(four.value))
        
        XCTAssertNil(gridDispatcher.pileForNumber(two.value))
        
        XCTAssertNotNil(gridDispatcher.pileForNumber(one.value))
        
        XCTAssertNotNil(gridDispatcher.pileForNumber(three.value))

        
        pile = gridDispatcher.pileForNumber(three.value)
        
        do {
            try combo.addUpComboWith(number: three.value, on: pile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: four.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: five.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: six.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }

        do {
            try combo.addUpComboWith(number: seven.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: eight.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: nine.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: ten.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: eleven.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: twelve.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        do {
            try combo.addUpComboWith(number: one.value, on: combo.currentPile!)
        } catch {
            XCTFail()
        }
        
        XCTAssertNotNil(gridDispatcher.pileForNumber(two.value))

        
        do {
            let expectedPoints = combo.combo.count * combo.combo.count
            let points = try combo.doneWithCombo()
            XCTAssertEqual(expectedPoints, points)
            XCTAssertEqual(combo.combo.count, 0)
        } catch {
            XCTFail()
        }
        
        XCTAssertNotNil(gridDispatcher.pileForNumber(one.value))

    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
