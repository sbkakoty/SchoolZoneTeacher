//
//  EventsModel.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 26/02/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

struct Event: Codable {
    let id: Int
    let EventTitle: String
    let EventURL: String
    let EventURLAgency: String
    let EventDescription: String
    let EventLocation: String
    let EventStartDate: String
    let EventEndDate: String
    let EventType: String
    let EventCurrency: String
    let EventPrice: Decimal
    let EventThumbnail: String
    let EventImage1: String
    let EventImage2: String
    let EventImage3: String
    let EventImage4: String
    let EventImage5: String
}
