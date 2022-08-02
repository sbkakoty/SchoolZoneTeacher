//
//  NetworkCallAPI.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 25/03/20.
//  Copyright © 2020 ClearWin Technologies. All rights reserved.
//

import Foundation

import Alamofire

open class NetworkCallAPI: NSObject
{
    lazy var dataSession: URLSession = {
        let defatultConfigObject:URLSessionConfiguration = URLSessionConfiguration.default
        defatultConfigObject.requestCachePolicy = .reloadIgnoringCacheData
        
        let fVariable:URLSession = URLSession(configuration:defatultConfigObject, delegate:nil, delegateQueue:OperationQueue.main)
        return fVariable
    }()

    static func getRequestHeaderWithAllParams(_ parameter:NSDictionary?) -> NSMutableURLRequest
    {
        NetworkCallSDK.sharedInstance().urlString = NetworkCallSDK.sharedInstance().urlString!.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let trimmedString: String = NetworkCallSDK.sharedInstance().urlString!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        NetworkCallSDK.sharedInstance().urlString = trimmedString
        
        var request: NSMutableURLRequest
        let url:URL = URL(string: NetworkCallSDK.sharedInstance().urlString! as String)!
        request = NSMutableURLRequest(url: url as URL)
        
        if NetworkCallSDK.sharedInstance().httpMethodType == .kPOST
        {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameter!, options:[]) as Data?
            print("url post method = \(String(describing: NetworkCallSDK.sharedInstance().urlString))")
            print("json request = \(String(describing: NSString(data:(jsonData! as Data?)!, encoding: String.Encoding.utf8.rawValue)))")
            request.httpBody = jsonData!
            request.httpMethod = "POST"
        }
        else if NetworkCallSDK.sharedInstance().httpMethodType == .kGET
        {
            request.httpMethod = "GET"
            print("json request = \(String(describing: NetworkCallSDK.sharedInstance().urlString))")
        }
        else if NetworkCallSDK.sharedInstance().httpMethodType == .kDELETE
        {
            /*if parameter.allKeys.count > 0 {
             NetworkCallSDK.sharedSingleton().urlString = "\(NetworkCallSDK.sharedSingleton().urlString)?"
             NetworkCallSDK.sharedSingleton().urlString = "\(NetworkCallSDK.sharedSingleton().urlString)\(self.convertQueryStringFrom(parameter).componentsJoinedByString("&"))"
             }
             request = NSMutableURLRequest.requestWithURL(NSURL(string: NetworkCallSDK.sharedSingleton().urlString), cachePolicy: NSURLRequestReturnCacheDataElseLoad, timeoutInterval: 60)
             request.HTTPMethod = "DELETE"
             */
            
            let jsonData = try? JSONSerialization.data(withJSONObject: parameter!, options:[]) as Data?
            //print("url post method = \(String(describing: NetworkCallSDK.sharedInstance().urlString))")
            //print("json request = \(String(describing: NSString(data:(jsonData! as Data?)!, encoding: String.Encoding.utf8.rawValue)))")
            request.httpBody = jsonData!
            request.httpMethod = "DELETE"
        }
        
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 120
        return request
    }
    
    public static func callAPIWithParam (_ parameters:NSDictionary?, success:@escaping responseBlock)
    {
        
        do {
            //            request.httpBody = try! JSONSerialization.data(withJSONObject: dict, options: [])
            let request:URLRequest = self.getRequestHeaderWithAllParams(parameters) as URLRequest
            Alamofire.request(request ).responseJSON { (response:DataResponse<Any>) in
                switch(response.result) {
                case .failure(let error):
                    print(error)
                    success(nil, error as NSError?)
                case .success(let responseObject):
                    //print("Response : %@",responseObject)
                    let tresponseObject = responseObject as! NSDictionary
                    // Checking is mobile number is registered or not
                    success(tresponseObject, nil)
                    
                }
                
            }
        }
    }
}
