//
//  Exam.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 01/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Exam: Codable {
    let examination_id: String?
    let exam_name: String?
    let exam_type: String?
    let pass_marks: String?
    let max_marks: String?
    let start_date: String?
    let end_date: String?
}
