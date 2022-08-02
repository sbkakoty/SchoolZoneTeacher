//
//  NetworkCallSDK.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 25/03/20.
//  Copyright © 2020 ClearWin Technologies. All rights reserved.
//

import Foundation

let kHostName = "https://indiaapi.ourschoolzone.org/api/"

public typealias responseBlock = (_ result:NSDictionary? , _ error:NSError?) -> Void

public enum HTTPMethod : uint
{
    case kGET = 0
    case kPOST
    case kput
    case kPATCH
    case kDELETE
}

@objc class NetworkCallSDK: NSObject
{
    open var urlString:String?
    open var httpMethodType: HTTPMethod
    static let singletonSharedInstance = NetworkCallSDK()
    
    @objc class func sharedInstance() -> NetworkCallSDK
    {
        return NetworkCallSDK.singletonSharedInstance
    }
    
    private override init()
    {
        urlString = kHostName
        httpMethodType = HTTPMethod.kPOST
    }
    
    @objc open func getSlidesApi(success:@escaping responseBlock ) -> Void
    {
        self.httpMethodType = HTTPMethod.kGET
        self.urlString =  kHostName + "GetSlides"
        
        let paramsDict =  ["":""]
        let queue = DispatchQueue(label: "Slider Queue")
        queue.async {
            NetworkCallAPI.callAPIWithParam((paramsDict as NSDictionary?), success: { (result, error) in
                success(result, error)
            })
        }
    }
}
