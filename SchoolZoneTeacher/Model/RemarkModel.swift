//
//  RemarkModel.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 29/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Remark: Codable {
    let id: Int?
    let StudentName: String?
    let Class_name: String?
    let Subject_name: String?
    let TeacherName: String?
    let Date: String?
    let Remark: String?
    let Read: String?
}
