//
//  SettingsViewController.swift
//  Twelve
//
//  Created by Clement Yerochewski on 07/04/2017.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController {

    private var observerContext = 0
    
    
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var darkModeLabel: UIDarkLabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var versionLabel: UIDarkLabel!
    @IBOutlet weak var contactUsLabel: UIDarkLabel!
    @IBOutlet weak var reviewLabel: UIDarkLabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionNumberLabel.text = version
        }
        

        SharedGameManager.sharedInstance.settings.addObserver(self, forKeyPath: "darkMode", options: [.new], context: &observerContext)
        
        `switch`.isOn = SharedGameManager.sharedInstance.settings.darkMode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    deinit {
        SharedGameManager.sharedInstance.settings.removeObserver(self, forKeyPath: "darkMode", context: &observerContext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        
        darkModeLabel.setNeedsDisplay()
        versionNumberLabel.setNeedsDisplay()
        contactUsLabel.setNeedsDisplay()
        reviewLabel.setNeedsDisplay()
        view.backgroundColor = SharedGameManager.sharedInstance.settings.darkMode ? .black : .white
    }
    
    
    @IBAction func reviewCAT(sender: UIButton) {
        leaveReview()
    }
    
    @IBAction func contactCAT(sender: UIButton) {
        sendEmail()
    }
    
    @IBAction func switchMode(sender: UISwitch) {
        let isDark = SharedGameManager.sharedInstance.settings.darkMode
        SharedGameManager.sharedInstance.settings.darkMode = !isDark
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewCon@objc troller.
        // Pass the selected object to the new view controller.
    }
    */

}


extension SettingsViewController : MFMailComposeViewControllerDelegate {
    
    func leaveReview() {
        if let checkURL = URL(string: "http://www.itunes.com/yourAppLlink.html") {
            UIApplication.shared.open(checkURL, options: [:], completionHandler: nil)
        } else {
            print("invalid url")
        }
    }
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["yerochewski@gmail.com"])
        composeVC.setSubject("Feedback Twolf")
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
