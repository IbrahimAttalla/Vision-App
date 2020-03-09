//
//  RoundedShadowImage.swift
//  VisionApp
//
//  Created by it thinkers on 2/12/19.
//  Copyright © 2019 it-thinkers. All rights reserved.
//

import UIKit
@IBDesignable

class RoundedShadowImage: UIImageView {


    @IBInspectable var cornerRadius: Float = 6.0 {
        didSet{
            setView()
        }
    }
    
    
    @IBInspectable var shadowOpacity: Float = 39.5 {
        didSet{
            setView()
        }
    }
    
    
    @IBInspectable var shadowRadius: Float = 4.0 {
        didSet{
            setView()
        }
    }
    
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 1.0, height: 1.0) {
        didSet{
            setView()
        }
    }
    
    
    @IBInspectable var shadowColor:CGColor = UIColor(red: 188.0/255.0, green:
        128.0/255.0, blue: 47.0/255.0, alpha: 7.0).cgColor {
        didSet{
            setView()
        }
    }
    
    
    
    
    func setView() {
        layer.cornerRadius = CGFloat(cornerRadius)
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = CGFloat(shadowRadius)
        clipsToBounds = true
    }
    

}
