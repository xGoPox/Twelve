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
        UIView.animate(withDuration: 0.25, animations: { 
            sender?.layer.backgroundColor =  UIColor.myGreen.cgColor
            sender?.setTitleColor(UIColor.white, for: .normal)
        }, completion: { done in
            self.performSegue(withIdentifier: "startClassic", sender: nil)
        })
    }
    
    
    @IBAction func selectSurvival(sender : AnyObject?) {
        UIView.animate(withDuration: 0.25, animations: {
            sender?.layer.backgroundColor =  UIColor.myBlue.cgColor
            sender?.setTitleColor(UIColor.white, for: .normal)
        }, completion: { done in
            self.performSegue(withIdentifier: "startSurvival", sender: nil)
        })
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
