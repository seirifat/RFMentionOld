//
//  CusTextView.swift
//  RFMentionTextView
//
//  Created by Rifat Firdaus on 3/26/18.
//  Copyright © 2018 Ripatto. All rights reserved.
//

import UIKit

class CusTextView: UITextView {
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        // Make the textView's borders round
        let borderColor : UIColor = UIColor(red: 0.50, green: 0.25, blue: 0.00, alpha: 1.00)
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 0.6
        self.layer.cornerRadius = 5.0
    }
    override func draw(_ rect: CGRect) {
            
    }
}
