//
//  Services.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 28/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import Foundation
import Alamofire

func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    Alamofire.request(url).responseJSON(completionHandler: {
        response in
        completion(response.data, response.response, response.result.error)
    })
}

func postData(from request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    Alamofire.request(request).responseJSON(completionHandler: {
        response in
        completion(response.data, response.response, response.result.error)
    })
    //URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
}
