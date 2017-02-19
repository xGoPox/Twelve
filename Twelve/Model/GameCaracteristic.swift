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

struct GameCaracteristic {
    
    var mode: GameMode = .classic
    var difficulty: GameDifficulty = .easy
    
}
