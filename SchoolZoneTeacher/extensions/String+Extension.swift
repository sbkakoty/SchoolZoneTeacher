//
//  String+Extension.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 09/04/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit
import Foundation

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
