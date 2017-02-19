//
//  DifficultyViewController.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/18/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import UIKit

class DifficultyViewController: UIViewController {



    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier ==  "easy" {
            SharedGameManager.sharedInstance.gameCaracteristic.difficulty = .easy
        } else if segue.identifier == "normal" {
            SharedGameManager.sharedInstance.gameCaracteristic.difficulty = .normal
        } else if segue.identifier == "hard" {
            SharedGameManager.sharedInstance.gameCaracteristic.difficulty = .hard
        }
    }
    
}
