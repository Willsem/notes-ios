//
//  CurrentColors.swift
//  Notes
//
//  Created by Александр Степанов on 14/07/2019.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

class CurrentColors {
    
    // White default color
    static let white: UIColor = .white
    
    // Red default color
    static let red = UIColor(red: 0.96, green: 0.24, blue: 0.29, alpha: 1)
    
    // Blue default color
    static let blue = UIColor(red: 0.25, green: 0.36, blue: 1, alpha: 1)
    
    // Create user's color or no
    static var wasCustom: Bool = false
    
    // User's color
    static var custom: UIColor = UIColor()
    
    // Current note color
    static var currentColor = white
    
    static var customPicker: ColorPicker? = nil
}
