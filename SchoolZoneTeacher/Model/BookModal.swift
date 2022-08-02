//
//  BookModal.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 22/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Book: Codable {
    let id: Int
    let Bookname: String
}

struct BookChapter: Codable {
    let id: Int
    let BookChaptername: String
    let BookChapterIndex: String
}

struct BookDetail: Codable {
    let BookID: Int
    let BookName: String
}

