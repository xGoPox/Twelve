//
//  GameCaracteristic.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/19/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation

enum GameMode {
    case survival
    case classic
}

enum GameDifficulty : Int {
    case easy = 0
    case normal = 1
    case hard = 2
}

enum TutorialStep {
    case firstStep
    case secondStep
    case thirdStep
}



struct GameCaracteristic {
    
    var mode: GameMode = .classic
    var difficulty: GameDifficulty = .normal
    
    var seconds: Int = 0 {
        willSet(newTime) {
            SharedGameManager.sharedInstance.bestTime = newTime
        }
    }
    
    var points: Int = 0 {
        willSet(newPoints) {
            SharedGameManager.sharedInstance.bestPoints = newPoints
        }
    }}
