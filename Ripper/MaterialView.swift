//
//  MaterialView.swift
//  Ripper
//
//  Created by Manish Ojha on 12/28/16.
//  Copyright © 2016 Manish Ojha. All rights reserved.
//

import UIKit

class MaterialView: UIView{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
}
