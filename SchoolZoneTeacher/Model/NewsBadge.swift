//
//  NewsBadge.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 08/04/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

class NewsBadge: NSObject, NSCoding{
    var schoolId: String!
    var badgeCheckDate: String!
    
    init(schoolId: String, badgeCheckDate:String) {
        self.schoolId = schoolId
        self.badgeCheckDate = badgeCheckDate
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.schoolId = aDecoder.decodeObject(forKey: "schoolId") as? String ?? ""
        self.badgeCheckDate = aDecoder.decodeObject(forKey: "badgeCheckDate") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(schoolId, forKey: "schoolId")
        aCoder.encode(badgeCheckDate, forKey: "badgeCheckDate")
    }
}
