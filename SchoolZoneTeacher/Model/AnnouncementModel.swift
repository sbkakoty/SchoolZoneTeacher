//
//  AnnouncementModel.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 29/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Announcement: Codable {
    let ID: String?
    let subject: String?
    let announcement: String?
    let date: String?
    let image_path1: String?
    let image_path2: String?
    let image_path3: String?
    let ClassName: String?
    let TeacherName: String?
}

