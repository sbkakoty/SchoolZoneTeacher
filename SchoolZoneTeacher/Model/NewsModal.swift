//
//  NewsModal.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 16/01/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

struct News: Codable {
    let id: Int
    let NewsTitle: String
    let NewsDescription: String
    let NewsStartDate: String
    let NewsEndDate: String
    let NewsThumbnail: String
}
