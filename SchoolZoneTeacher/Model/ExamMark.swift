//
//  ExamMark.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 01/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

struct ExamMark: Codable {
    let examination_marks_id: String?
    let student_id: String?
    let student_name: String?
    let profile_image: String?
    let roll_number: String?
    let subject_name: String?
    let marks: String?
    let grade: String?
    let max_marks: String?
}
