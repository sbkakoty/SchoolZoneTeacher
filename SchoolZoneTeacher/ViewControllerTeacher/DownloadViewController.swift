//
//  DownloadViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 30/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import UIKit
import SCLAlertView
import WebKit
import MaterialComponents

class DownloadViewController: UIViewController, WKNavigationDelegate {
    
    let activityIndicator = MDCActivityIndicator()
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if(getLanguage().count > 0)
        {
            defaultLocalizer.setSelectedLanguage(lang: getLanguage())
        }
        else
        {
            defaultLocalizer.setSelectedLanguage(lang: "en")
        }
        
        self.setNavigationBar()
        
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + 48)
        //let webview = UIWebView(frame: CGRect(x: 0, y: self.calculateTopDistance(), width: self.view.frame.size.width, height: scroolHeight))
        let webview = WKWebView(frame: CGRect(x: 0, y: self.calculateTopDistance(), width: self.view.frame.size.width, height: scroolHeight))
        webview.tag = 100
        //webview.delegate = self
        webview.navigationDelegate = self
        
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        webview.addSubview(activityIndicator)
        
        if let urlComponents = URLComponents(string: URLShared.urlshared.url!.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!) {
            //urlComponents.query = "schoolid=" + schoolid
            // 3
            guard let url = urlComponents.url else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                let httpStatus = response as? HTTPURLResponse
                //print(httpStatus?.statusCode)
                
                if httpStatus?.statusCode != 404 {
                    DispatchQueue.main.async {
                        let urlString =  URLShared.urlshared.url!.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
                        if let webViewURL = URL(string: urlString) {
                            let webViewURLRequest = URLRequest(url: webViewURL)
                            //webview.loadRequest(webViewURLRequest)
                            webview.load(webViewURLRequest)
                            if(webview.isLoading)
                            {
                                self.activityIndicator.startAnimating()
                            }
                            
                            self.view.addSubview(webview)
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        let alertView = SCLAlertView(appearance: self.appearance)
                        alertView.showError("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageNoResourceFound"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                    }
                }
            }.resume()
        }
    }
    
    /*func webViewDidStartLoad(_ webView: UIWebView) // show indicator
    {
        self.activityIndicator.startAnimating()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) // hide indicator
    {
        self.activityIndicator.stopAnimating()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) // hide indicator
    {
        self.activityIndicator.stopAnimating()
    }*/
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
    
    func calculateTopDistance () -> CGFloat{
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 45
    }
    
    func setNavigationBar() {
        let navigationFont = UIFont(name: "Helvetica", size: getTitleFontSize())
        let screenSize: CGRect = UIScreen.main.bounds;
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: screenSize.width, height: 44))
        self.view.addSubview(navBar);
        
        let navItem = UINavigationItem(title: self.defaultLocalizer.stringForKey(key: "navBarTitleDownload"));
        let button = UIButton.init(type: .custom)
        button.setTitle(self.defaultLocalizer.stringForKey(key: "navBarButtonBack"), for: UIControl.State.normal)
        var image = UIImage.init(named: "back");
        var templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action:#selector(back), for:.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20) //CGRectMake(0, 0, 30, 30)
        var doneItem = UIBarButtonItem.init(customView: button)
        
        //let doneItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = doneItem;
        
        let buttonShare = UIButton.init(type: .custom)
        image = UIImage.init(named: "share");
        templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        buttonShare.setImage(image, for: UIControl.State.normal)
        buttonShare.addTarget(self, action:#selector(buttonShareTap), for:.touchUpInside)
        buttonShare.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20) //CGRectMake(0, 0, 30, 30)
        doneItem = UIBarButtonItem.init(customView: buttonShare)
        navItem.rightBarButtonItem = doneItem;
        
        navBar.setItems([navItem], animated: false);
        navBar.backgroundColor = colorWithHexString(hex: "#00CCFF");
        navBar.isTranslucent = false;
        navBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: navigationFont!, NSAttributedString.Key.shadow: setNavBarTitleShadow()
        ]
        
        if #available(iOS 11, *){
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: navigationFont!, NSAttributedString.Key.shadow: setNavBarTitleShadow()]
        }
    }
    
    @objc func buttonShareTap()
    {
        let someText:String = "OurSchoolZone"
        let urlString = URLShared.urlshared.url!.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let objectsToShare = URL(string: urlString)
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func back() { // remove @objc for Swift 3
        self.dismiss(animated: false, completion: nil);
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
