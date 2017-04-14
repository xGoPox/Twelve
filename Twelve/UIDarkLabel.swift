//
//  UIDarkLabel.swift
//  Twelve
//
//  Created by Clement Yerochewski on 07/04/2017.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import UIKit

class UIDarkLabel: UILabel {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        textColor = SharedGameManager.sharedInstance.settings.darkMode ? .white : .myTextColor
        super.draw(rect)
    }
    

}
