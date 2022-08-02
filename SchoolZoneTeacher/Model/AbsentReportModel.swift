//
//  AbsentReportModel.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 29/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import Foundation

struct AbsentReport: Codable {
    let id: Int?
    let StudentName: String?
    let AbsentDate: String?
    let AbsentEndDate: String?
    let Reason: String?
    let ClassName: String?
}
