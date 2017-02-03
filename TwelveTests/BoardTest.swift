//
//  BoardTest.swift
//  Twelve
//
//  Created by Clement Yerochewski on 1/28/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import XCTest
import GameplayKit

@testable import Twelve

class BoardTest: XCTestCase {
    
    let one  = NumberSpriteNode.init(gridPosition: (0,0), value: 1)
    let two  = NumberSpriteNode.init(gridPosition: (0,1), value: 2)
    let three  = NumberSpriteNode.init(gridPosition: (2,2), value: 3)
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
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
   
    
    func testDetectPossible() {
        
        if let scene = GKScene(fileNamed: "GameScene") {
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                
                sceneNode.grid = Grid(blockSize: CGFloat(10), rows:4, cols:4)
                
                
                var rowOne = [NumberSpriteNode]()
                
                rowOne.append(NumberSpriteNode.init(gridPosition: (0,0), value: 3))
                rowOne.append(NumberSpriteNode.init(gridPosition: (0,1), value: 3))
                rowOne.append(NumberSpriteNode.init(gridPosition: (0,2), value: 3))
                rowOne.append(NumberSpriteNode.init(gridPosition: (0,3), value: 4))
                
                var rowTwo = [NumberSpriteNode]()
                
                rowTwo.append(NumberSpriteNode.init(gridPosition: (1,0), value: 1))
                rowTwo.append(NumberSpriteNode.init(gridPosition: (1,1), value: 2))
                rowTwo.append(NumberSpriteNode.init(gridPosition: (1,2), value: 3))
                rowTwo.append(NumberSpriteNode.init(gridPosition: (1,3), value: 8))
                
                var rowThree = [NumberSpriteNode]()
                
                rowThree.append(NumberSpriteNode.init(gridPosition: (2,0), value: 9))
                rowThree.append(NumberSpriteNode.init(gridPosition: (2,1), value: 3))
                rowThree.append(NumberSpriteNode.init(gridPosition: (2,2), value: 3))
                rowThree.append(NumberSpriteNode.init(gridPosition: (2,3), value: 12))
                
                var rowFour = [NumberSpriteNode]()
                
                rowFour.append(NumberSpriteNode.init(gridPosition: (3,0), value: 12))
                rowFour.append(NumberSpriteNode.init(gridPosition: (3,1), value: 12))
                rowFour.append(NumberSpriteNode.init(gridPosition: (3,2), value: 12))
                rowFour.append(NumberSpriteNode.init(gridPosition: (3,3), value: 12))
                
                sceneNode.gridDispatcher.matrix.append(rowOne)
                sceneNode.gridDispatcher.matrix.append(rowTwo)
                sceneNode.gridDispatcher.matrix.append(rowThree)
                sceneNode.gridDispatcher.matrix.append(rowFour)
                
                
                
                do {
                    let possibility = try sceneNode.gridDispatcher.possibility(grid: sceneNode.grid)
                    XCTAssertNotNil(possibility)
                } catch {
                    XCTFail()
                }
                
                
            }
        }
    }
    
    
    func testDetectNotPossible() {
        
        if let scene = GKScene(fileNamed: "GameScene") {
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                
                sceneNode.grid = Grid(blockSize: CGFloat(10), rows:4, cols:4)
                
                
                var rowOne = [NumberSpriteNode]()
                
                rowOne.append(NumberSpriteNode.init(gridPosition: (0,0), value: 3))
                rowOne.append(NumberSpriteNode.init(gridPosition: (0,1), value: 3))
                rowOne.append(NumberSpriteNode.init(gridPosition: (0,2), value: 3))
                rowOne.append(NumberSpriteNode.init(gridPosition: (0,3), value: 4))
                
                var rowTwo = [NumberSpriteNode]()
                
                rowTwo.append(NumberSpriteNode.init(gridPosition: (1,0), value: 1))
                rowTwo.append(NumberSpriteNode.init(gridPosition: (1,1), value: 3))
                rowTwo.append(NumberSpriteNode.init(gridPosition: (1,2), value: 3))
                rowTwo.append(NumberSpriteNode.init(gridPosition: (1,3), value: 8))
                
                var rowThree = [NumberSpriteNode]()
                
                rowThree.append(NumberSpriteNode.init(gridPosition: (2,0), value: 9))
                rowThree.append(NumberSpriteNode.init(gridPosition: (2,1), value: 3))
                rowThree.append(NumberSpriteNode.init(gridPosition: (2,2), value: 3))
                rowThree.append(NumberSpriteNode.init(gridPosition: (2,3), value: 12))
                
                var rowFour = [NumberSpriteNode]()
                
                rowFour.append(NumberSpriteNode.init(gridPosition: (3,0), value: 12))
                rowFour.append(NumberSpriteNode.init(gridPosition: (3,1), value: 12))
                rowFour.append(NumberSpriteNode.init(gridPosition: (3,2), value: 12))
                rowFour.append(NumberSpriteNode.init(gridPosition: (3,3), value: 12))
                
                sceneNode.gridDispatcher.matrix.append(rowOne)
                sceneNode.gridDispatcher.matrix.append(rowTwo)
                sceneNode.gridDispatcher.matrix.append(rowThree)
                sceneNode.gridDispatcher.matrix.append(rowFour)
                
                
                XCTAssertThrowsError(try sceneNode.gridDispatcher.possibility(grid: sceneNode.grid)) { error in
                    XCTAssertEqual(error as? ComboError, ComboError.noMorePossibilities)
                }
                
                sceneNode.gridDispatcher.piles[0].updateWithLastNumber(2)

                do {
                    let possibility = try sceneNode.gridDispatcher.possibility(grid: sceneNode.grid)
                    XCTAssertNotNil(possibility)
                } catch {
                    XCTFail()
                }

                
            }
        }
    }
    

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            
            if let scene = GKScene(fileNamed: "GameScene") {
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! GameScene? {
                    sceneNode.grid = Grid(blockSize: CGFloat(10), rows:4, cols:4)
                    
                    
                    var rowOne = [NumberSpriteNode]()
                    
                    rowOne.append(NumberSpriteNode.init(gridPosition: (0,0), value: 5))
                    rowOne.append(NumberSpriteNode.init(gridPosition: (0,1), value: 3))
                    rowOne.append(NumberSpriteNode.init(gridPosition: (0,2), value: 3))
                    rowOne.append(NumberSpriteNode.init(gridPosition: (0,3), value: 4))
                    
                    var rowTwo = [NumberSpriteNode]()
                    
                    rowTwo.append(NumberSpriteNode.init(gridPosition: (1,0), value: 1))
                    rowTwo.append(NumberSpriteNode.init(gridPosition: (1,1), value: 3))
                    rowTwo.append(NumberSpriteNode.init(gridPosition: (1,2), value: 3))
                    rowTwo.append(NumberSpriteNode.init(gridPosition: (1,3), value: 8))
                    
                    var rowThree = [NumberSpriteNode]()
                    
                    rowThree.append(NumberSpriteNode.init(gridPosition: (2,0), value: 9))
                    rowThree.append(NumberSpriteNode.init(gridPosition: (2,1), value: 3))
                    rowThree.append(NumberSpriteNode.init(gridPosition: (2,2), value: 3))
                    rowThree.append(NumberSpriteNode.init(gridPosition: (2,3), value: 12))
                    
                    var rowFour = [NumberSpriteNode]()
                    
                    rowFour.append(NumberSpriteNode.init(gridPosition: (3,0), value: 12))
                    rowFour.append(NumberSpriteNode.init(gridPosition: (3,1), value: 12))
                    rowFour.append(NumberSpriteNode.init(gridPosition: (3,2), value: 12))
                    rowFour.append(NumberSpriteNode.init(gridPosition: (3,3), value: 12))
                    
                    sceneNode.gridDispatcher.matrix.append(rowOne)
                    sceneNode.gridDispatcher.matrix.append(rowTwo)
                    sceneNode.gridDispatcher.matrix.append(rowThree)
                    sceneNode.gridDispatcher.matrix.append(rowFour)
                    
                 
                    do {
                        let posibility = try sceneNode.gridDispatcher.possibility(grid: sceneNode.grid)
                    } catch {
                        sceneNode.gridDispatcher.resetNumbers(on: sceneNode.grid)
                        try? sceneNode.gridDispatcher.disposeNumbers(on: sceneNode.grid)
                    }

                }
            }
        }
        
    }
}
