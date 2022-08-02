//
//  HolidayModel.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 26/05/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Holiday: Codable {
    let id: Int
    let EventTitle: String
    let EventType: String
    let AcademicYear: String
    let EventDate: String
}
