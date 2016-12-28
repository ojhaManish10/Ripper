//
//  MaterialButton.swift
//  Ripper
//
//  Created by Manish Ojha on 12/28/16.
//  Copyright © 2016 Manish Ojha. All rights reserved.
//

class MaterialButton: UIButton{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        imageView?.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 5
    }
}
