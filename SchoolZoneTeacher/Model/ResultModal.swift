//
//  ResultModal.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 18/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Result: Codable {
    let ClasswList: [Classwork]?
    let HomeWorkList: [Homework]?
    let Assignments: [Assignment]?
    let ClassList: [Classsection]?
    let Students: [Student]?
    let SubjectList: [Subject]?
    let BookList: [Book]?
    let BookDetails: BookDetail?
    let BookChapetrList: [BookChapter]?
    let Announcements: [Announcement]?
    let Remarks: [Remark]?
    let RemarksReplies: [RemarksReply]?
    let AbsentReports: [AbsentReport]?
    let Directories: [ClassTimeTable]?
    let ExamExamTimeTables: [ExamTimeTable]?
    let Examinations: [Examination]?
    let News: [News]?
    let Holidays: [Holiday]?
    let Events: [Event]?
    let Teachers: [Teacher]?
    let GKList: [EduBank]?
    let topicsList: [EduForum]?
    let answerList: [Answer]?
    let WhatIsNewList: [VersionInf]?
    let BreakingNews: [BreakingNews]?
    let Slides: [Slide]?
    let Response: Response
}
