//
//  TeacherModel.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 19/01/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Teacher: Codable {
    var School_id: String?
    var School_Name: String?
    var FirstName: String?
    var MiddleName: String?
    var LastName: String?
    var Mobile: String?
    var Email: String?
    var DOB: String?
    var Gender: String?
    var ProfileImage: String?
    var TeacherID: String?
    var SchoolAddress: String?
    var SchoolLogo: String?
    var Language: String?
    var Academic_Year: String?
    var Start_Date: String?
    var End_Date: String?
}
