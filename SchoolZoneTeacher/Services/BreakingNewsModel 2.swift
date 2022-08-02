//
//  BreakingNewsModel.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 05/12/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

struct BreakingNews: Codable {
    let newsid: String
    let news_title: String
    let description: String
    let author: String
    let newsimage: String
    let publishdate: String
}
