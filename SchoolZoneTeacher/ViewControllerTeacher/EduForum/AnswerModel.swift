//
//  AnswerModel.swift
//  vZons
//
//  Created by Apple on 14/08/19.
//

import Foundation

struct Answer: Codable {
    let id: Int
    let edu_forum_id: Int
    let edu_forum_answer_id: Int
    let answer: String
    let attachment: String
    let answerdate: String
    let school_id: String!
    let school_name: String
    let school_address: String
    let school_logo: String
    let parent_id: String!
    let parent_name: String
    let parent_profile_image: String
    let teacher_id: String!
    let teacher_name: String
    let teacher_profile_image: String
    let like_count: Int
    let dislike_count: Int
}
