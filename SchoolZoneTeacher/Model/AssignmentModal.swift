//
//  AssignmentModal.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 18/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Assignment: Codable {
    let id: Int
    let Description: String
    let Subject_name: String
    let Class_name: String
    let TeacherName: String
    let Doc_path: String
    let Doc_path2: String
    let Doc_path3: String
    let Date: String
}
