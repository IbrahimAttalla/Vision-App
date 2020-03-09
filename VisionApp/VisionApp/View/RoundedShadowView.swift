//
//  RoundedShadowView.swift
//  VisionApp
//
//  Created by it thinkers on 2/12/19.
//  Copyright © 2019 it-thinkers. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {
    
    // three  properties to make shadow    and two to make corner radius
    
    override func awakeFromNib() {
         // three  properties to make shadow
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        // two to make corner radius
        self.layer.cornerRadius = (self.frame.size.height / 2) - 15
        self.clipsToBounds = true
        
    }
    
}
