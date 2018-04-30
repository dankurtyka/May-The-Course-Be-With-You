//
//  UIView+addBorder.swift
//  May The Course Be With You
//
//  Created by Daniel Kurtyka on 4/29/18.
//  Copyright © 2018 Daniel Kurtyka. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(borderWidth: CGFloat, cornerRadius: CGFloat) {
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        let borderColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1.0)
        self.layer.borderColor = borderColor.cgColor
    }
}
