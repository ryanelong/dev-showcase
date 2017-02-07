//
//  MaterialTextField.swift
//  dev-showcase
//
//  Created by ryan on 2/5/17.
//  Copyright © 2017 ryan. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).cgColor
        layer.borderWidth = 1.0
    }
    
    // For placeholder
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds.insetBy(dx: 10, dy: 0)
    }

    // For editable text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds.insetBy(dx: 10, dy: 0)
    }
}
