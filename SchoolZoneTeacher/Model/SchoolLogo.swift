//
//  SchoolLogo.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 09/04/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

class SchoolLogo: NSObject, NSCoding{
    var schoolId: String!
    var schoolLogo: NSData!
    var schoolLogoSize: Int!
    
    init(schoolId: String, schoolLogo:NSData, schoolLogoSize: Int) {
        self.schoolId = schoolId
        self.schoolLogo = schoolLogo
        self.schoolLogoSize = schoolLogoSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.schoolId = aDecoder.decodeObject(forKey: "schoolId") as? String ?? ""
        self.schoolLogo = aDecoder.decodeObject(forKey: "schoolLogo") as? NSData
        self.schoolLogoSize = aDecoder.decodeObject(forKey: "schoolLogoSize") as? Int ?? 0
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(schoolId, forKey: "schoolId")
        aCoder.encode(schoolLogo, forKey: "schoolLogo")
        aCoder.encode(schoolLogoSize, forKey: "schoolLogoSize")
    }
}
