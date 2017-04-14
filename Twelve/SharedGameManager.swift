//
//  SharedGameManager.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/19/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import Foundation

class Settings : NSObject {
    
    private let preferences = UserDefaults.standard
    private let darkModeKey = "darkModeKey"
    
   dynamic var darkMode : Bool {
        get {
            return preferences.bool(forKey: darkModeKey)
        }
        set(enable) {
            preferences.set(enable, forKey: darkModeKey)
            preferences.synchronize()
        }
    }
}

class SharedGameManager {
    
    static let sharedInstance = SharedGameManager()
    
    var gameCaracteristic = GameCaracteristic()
    
    var settings = Settings()

    
    private let preferences = UserDefaults.standard
    
    private let jokerTutorialSeenKey = "jokerTutorialSeenKey"
    private let classicTutorialSeenKey = "classicTutorialSeenKey"
    private let survivalTutorialSeenKey = "survivalTutorialSeenKey"
    private let hasAchievedAGameKey = "hasAchievedAGameKey"
    private let bestPointsKey = "bestPointsKey"
    private let bestTimeKey = "bestTimeKey"



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
    
    
    var bestPoints : Int {
        set(newPoints) {
            if newPoints > preferences.integer(forKey: bestPointsKey) {
                preferences.set(newPoints, forKey: bestPointsKey)
                preferences.synchronize()
            }
        }
        get {
            return preferences.integer(forKey: bestPointsKey)
        }
    }
    
    
    var bestTime : Int {
        set(newTime) {
            if newTime > preferences.integer(forKey: bestTimeKey) {
                preferences.set(newTime, forKey: bestTimeKey)
                preferences.synchronize()
            }
        }
        get {
            return preferences.integer(forKey: bestTimeKey)
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
