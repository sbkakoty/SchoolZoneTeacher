//
//  EduForumModel.swift
//  vZons
//
//  Created by Apple on 11/08/19.
//

import Foundation

struct EduForum: Codable {
    let id: Int
    let title: String
    let description: String
    let image: String
    let publishdate: String
    let school_id: String
    let school_name: String
    let school_address: String
    let parent_id: String
    let parent_name: String
    let teacher_id: String
    let teacher_name: String
    let profile_image: String
    let islocked: String
}

