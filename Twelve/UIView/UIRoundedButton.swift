//
//  UIRoundedButton.swift
//  Twelve
//
//  Created by Clement Yerochewski on 2/18/17.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import UIKit

protocol Rounded {
    var radiusMultiplier: CGFloat { get set }
    var borderWidth: CGFloat { get set }
    var borderColor: UIColor? { get set }
}

extension Rounded where Self: UIView {
    
    // Default values
    static var defaultRadiusMultiplier: CGFloat {
        return 0
    }
    
    static var defaultBorderWidth: CGFloat {
        return 0
    }
    
    // Helper functions for updating the layer
    func updateBorderWidth() {
        layer.borderWidth = borderWidth
    }
    
    func updateBoderColor() {
        layer.borderColor = borderColor?.cgColor
    }
    
    func updateCorderRadius() {
        guard radiusMultiplier != 0 else {
            layer.cornerRadius = 0
            return
        }
        let shortestDimmension = min(bounds.size.width, bounds.size.height)
        layer.cornerRadius = shortestDimmension / radiusMultiplier
    }
}

@IBDesignable public class RoundedButton: UIButton, Rounded {
    @IBInspectable public var radiusMultiplier: CGFloat = defaultRadiusMultiplier {
        didSet {
            updateCorderRadius()
        }
    }
    @IBInspectable public var borderWidth: CGFloat = defaultBorderWidth {
        didSet {
            updateBorderWidth()
        }
    }
    @IBInspectable public var borderColor: UIColor? {
        didSet {
            updateBoderColor()
        }
    }
    override public var bounds: CGRect {
        didSet {
            updateCorderRadius()
        }
    }
}
