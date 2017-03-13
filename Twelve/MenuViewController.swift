//
//  MenuViewController.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/18/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import UIKit



class MenuViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        SharedAssetsManager.sharedInstance.loadTextures()
        SharedAssetsManager.sharedInstance.loadScene()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    @IBAction func selectClassic(sender : AnyObject?) {
        self.performSegue(withIdentifier: "startClassic", sender: nil)
    }
    
    
    @IBAction func selectSurvival(sender : AnyObject?) {
        self.performSegue(withIdentifier: "startSurvival", sender: nil)
    }
    
    @IBAction func unvindSegueToMainMenu(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier ==  "startSurvival" {
            SharedGameManager.sharedInstance.gameCaracteristic.mode = .survival
        } else if segue.identifier == "startClassic" {
            SharedGameManager.sharedInstance.gameCaracteristic.mode = .classic
        }
    }
    
    
}
