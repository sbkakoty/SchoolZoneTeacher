//
//  ExamResponseModel.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 01/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

struct ExamResponse: Codable {
    let ExamList: [Exam]?
    let GradeList: [ExamGrade]?
    let ClassList: [ExamClass]?
    let StudentMarksList: [ExamMark]?
    let Response: Response
    let examname: String!
    let type: String!
    let Nomarksrecord: Nomarksrecord!
}
