//
//  ServiceClass.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 28/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation

class ServiceClass: NSObject {
    
    func getClass(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
