//
//  SharedGameManager.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/19/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation

class SharedGameManager {
    
    static let sharedInstance = SharedGameManager()
    
    var gameCaracteristic = GameCaracteristic()
    
    private let preferences = UserDefaults.standard
    
    private let jokerTutorialSeenKey = "jokerTutorialSeenKey"
    private let classicTutorialSeenKey = "classicTutorialSeenKey"
    private let survivalTutorialSeenKey = "survivalTutorialSeenKey"
    private let hasAchievedAGameKey = "hasAchievedAGameKey"


    var jokerTutorialSeen : Bool {
        get {
            if preferences.bool(forKey: jokerTutorialSeenKey) == false {
                preferences.set(true, forKey: jokerTutorialSeenKey)
                preferences.synchronize()
                return false
            } else {
                return true
            }
        }
    }
    
    
    var classicTutorialSeen : Bool {
        get {
            if preferences.bool(forKey: classicTutorialSeenKey) == false {
                preferences.set(true, forKey: classicTutorialSeenKey)
                preferences.synchronize()
                return false
            } else {
                return true
            }
        }
    }

    var survivalTutorialSeen : Bool {
        get {
            if preferences.bool(forKey: survivalTutorialSeenKey) == false {
                preferences.set(true, forKey: survivalTutorialSeenKey)
                preferences.synchronize()
                return false
            } else {
                return true
            }
        }
    }

    var hasAchievedAGame : Bool {
        get {
            return preferences.bool(forKey: hasAchievedAGameKey)
        }
        set(achieved) {
            preferences.set(true, forKey: hasAchievedAGameKey)
            preferences.synchronize()
        }
    }

    
}
