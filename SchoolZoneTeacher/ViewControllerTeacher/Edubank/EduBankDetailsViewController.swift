//
//  EduBankDetailsViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 22/11/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit
import Lightbox
import WebKit

class EduBankDetailsViewController: UIViewController, LightboxControllerPageDelegate, LightboxControllerDismissalDelegate, WKNavigationDelegate {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var edubankTitle: UILabel!
    @IBOutlet weak var labelEdubankAuthor: UILabel!
    @IBOutlet weak var txtEdubankAuthor: UILabel!
    
    @IBOutlet var wkWeViewDesc: WKWebView!
    @IBOutlet var ltxtPublishDate: UILabel!
    @IBOutlet var labelDesc: UILabel!
    @IBOutlet var labelPublishDate: UILabel!
    @IBOutlet var labelURL: UILabel!
    @IBOutlet var txtURL: UILabel!
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    var activityView: UIActivityIndicatorView!
    
    var ID:Int!
    var imagePath:String!
    var Title:String!
    var Author:String!
    var Desc:String!
    var PublishDate:String!
    var eduBankURL:String!
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func calculateTopDistance () -> CGFloat{
        if(self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent){
            return 0
        }else{
            
            let barHeight = self.navigationController?.navigationBar.frame.height ?? 0
            var statusBarHeight:CGFloat = 0
            
            if #available(iOS 13.0, *) {
                
                let sharedApplication = UIApplication.shared
                statusBarHeight = (sharedApplication.delegate?.window??.windowScene?.statusBarManager?.statusBarFrame)!.height

            } else {
                
                statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                
                if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                    statusBar.backgroundColor = colorWithHexString(hex: "#00CCFF")
                }
            }
            
            return barHeight + statusBarHeight
        }
    }
    
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
        
        container.layer.borderWidth = 0.5
        container.layer.cornerRadius = 3.0
        container.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        container.layer.shadowColor = UIColor.lightGray.cgColor
        container.layer.shadowOffset = CGSize(width: 3, height: 3)
        container.layer.shadowOpacity = 0.5
        
        //container.layer.frame = CGRect(x: 0, y: self.calculateTopDistance(), width: self.view.frame.size.width, height: scroolHeight)
        cardImage.layer.borderWidth = 0.5
        cardImage.layer.cornerRadius = 0.0
        cardImage.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        cardImage.layer.shadowColor = UIColor.lightGray.cgColor
        cardImage.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardImage.layer.shadowOpacity = 0.5
        self.cardImage.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self , action: #selector(self.zoomImage))
        self.cardImage.addGestureRecognizer(tapgesture)
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy"
        
        self.labelEdubankAuthor.text = defaultLocalizer.stringForKey(key: "labelAuthor")
        self.labelDesc.text = self.defaultLocalizer.stringForKey(key: "labelDesc")
        self.labelPublishDate.text = self.defaultLocalizer.stringForKey(key: "labelPublishDate")
        self.labelURL.text = self.defaultLocalizer.stringForKey(key: "labelURL")
        
        self.edubankTitle.text = Title
        self.txtEdubankAuthor.text = Author
        self.ltxtPublishDate.text = PublishDate
        if(eduBankURL.count > 0){
            self.txtURL.text = eduBankURL
        }else{
            //self.labelURL.isHidden = true
            self.txtURL.text = "NA"
        }
        
        if let url = URL(string: imagePath!) {
            getImageData(from: url) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async() {
                    self.cardImage.image = UIImage(data: data)
                }
            }
        }
        
        print("Desc: \(Desc!)")
        //let htmlString:String! = "<p style=\"text-align:justify\">\(newsDesc!)</p>"
        var headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
        headerString.append(Desc!)
        wkWeViewDesc.loadHTMLString(updateDataWithFont(data:headerString), baseURL: nil)
        wkWeViewDesc.navigationDelegate = self
        // add activity
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.center = self.wkWeViewDesc.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        activityView.hidesWhenStopped = true
        
        self.setNavigationBar()
        
        self.addReadEduBank()
    }
    
    func addReadEduBank(){
        
        let teacherid = getTeacherId()
        let schoolid = getSchoolId()
        
        let queryString = "edu_bank_id=\(self.ID!)&school_id=\(schoolid)&parent_id=&teacher_id=\(teacherid)"
        
        //print("addReadEvents URL: \(queryString)")
        
        if var urlComponents = URLComponents(string: "https://indiaapi.ourschoolzone.org/api/AddEduBankRead") {
            urlComponents.query = queryString
            // 3
            guard let url = urlComponents.url else { return}
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            postData(from: request) { data, response, error in
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //let responseMessage = String(describing: response)
                    
                    return
                }
                
                let responseMessage = String(describing: response)
                
                print("AddEduBankRead Response: \(responseMessage)")
            }
        }
    }
    
    func setNavigationBar() {
        let navigationFont = UIFont(name: "Helvetica", size: getTitleFontSize())
        let screenSize: CGRect = UIScreen.main.bounds
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: screenSize.width, height: 44))
        self.view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: self.defaultLocalizer.stringForKey(key: "EduBankDetails"))
        let button = UIButton.init(type: .custom)
        button.setTitle(self.defaultLocalizer.stringForKey(key: "navBarButtonBack"), for: UIControl.State.normal)
        var image = UIImage.init(named: "back")
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action:#selector(back), for:.touchUpInside)
        button.addTarget(self, action:#selector(back), for:.touchUpOutside)
        button.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20) //CGRectMake(0, 0, 30, 30)
        let doneItem = UIBarButtonItem.init(customView: button)
        
        //let doneItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = doneItem
        
        navBar.setItems([navItem], animated: false)
        navBar.backgroundColor = colorWithHexString(hex: "#00CCFF")
        navBar.isTranslucent = false
        navBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: navigationFont!, NSAttributedString.Key.shadow: setNavBarTitleShadow()
        ]
        
        if #available(iOS 11, *){
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: navigationFont!, NSAttributedString.Key.shadow: setNavBarTitleShadow()]
        }
    }
    
    @objc func back() {
        self.dismiss(animated: false, completion: nil);
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func webView(_ webView: WKWebView, didFinish navigation:
        WKNavigation!) {
        self.activityView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation
        navigation: WKNavigation!) {
        self.activityView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation:
        WKNavigation!, withError error: Error) {
        self.activityView.stopAnimating()
    }
    
    func updateDataWithFont(data:String)->String{
        return String(format: "<html><body><span style=\"font-family:%@;font-family:%@;text-align:justify\">%@</span></body></html>","Helvetica","11px",data)
    }
    
    func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @objc func zoomImage(_ sender: UITapGestureRecognizer)
    {
        //print("zoomImageTap")
        let images = [LightboxImage(imageURL: URL(string: imagePath)!)]
        
        // Create an instance of LightboxController.
        let controller = LightboxController(images: images)
        
        // Set delegates.
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        
        // Use dynamic background.
        controller.dynamicBackground = true
        controller.modalPresentationStyle = .fullScreen
        // Present your controller.
        present(controller, animated: true, completion: nil)
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
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
