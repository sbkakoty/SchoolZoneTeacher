//
//  ClassworkModal.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 17/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Classwork: Codable {
    let id: Int
    let Subject_name: String
    let Book: String
    let Chapter_Name: String
    let Chapter_index: String
    let Class_name: String
    let Remarks: String
    let TeacherName: String
    let Doc_path: String?
    let Doc_path2: String?
    let Doc_path3: String?
    let Date: String
}
