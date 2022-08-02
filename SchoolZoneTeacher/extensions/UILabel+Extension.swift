//
//  UILabel+Extension.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 09/04/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//
import UIKit
import Foundation

public extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
    
    static func createCustomLabel() -> UILabel {
        let label = UILabel()
        label.textDropShadow()
        return label
    }
}
