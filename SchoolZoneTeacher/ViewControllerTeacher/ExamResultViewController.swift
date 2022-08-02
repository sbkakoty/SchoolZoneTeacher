//
//  ExamResultViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 01/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit
import SCLAlertView
import MaterialComponents
import iOSDropDown

class ExamResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var popoverVC: UIViewController!
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator()
    var classsections:[Classsection]?
    var result:Result?
    var examTimeTables:[ExamTimeTable]?
    var examinations:[Examination]?
    var response:Response?
    
    var dropDownClass = DropDown()
    var classIds = [Int]()
    var classNames = [String]()
    
    var buttonSubmit = UIButton()
    
    var schoolid = Int()
    var classId = Int()
    
    var tableView = UITableView()
    var refreshControl = UIRefreshControl()
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!
    )
    
    override func viewDidAppear(_ animated: Bool) {

        if #available(iOS 13, *)
        {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = colorWithHexString(hex: "#00CCFF")
            UIApplication.shared.keyWindow?.addSubview(statusBar)
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
        
        self.setNavigationBar()
        self.loadExaminationView()
        self.loadClass()
    }
    
    func loadClass() {
        
        self.activityIndicator.startAnimating()
        let alertView = SCLAlertView(appearance: self.appearance)
        let schoolid = getSchoolId();
        let teacherid = getTeacherId()
        if var urlComponents = URLComponents(string: Constants.baseUrl + "ClassV2") {
            urlComponents.query = "schoolid=" + schoolid + "&teacherid=" + teacherid
            // 3
            guard let url = urlComponents.url else { return}
            
            getData(from: url) { data, response, error in
                if error != nil {
                    self.activityIndicator.stopAnimating()
                    
                    DispatchQueue.main.async {
                        alertView.showInfo("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageFetchdataError"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "buttonAlertOK"))
                    }
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return}
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let classData = try JSONDecoder().decode(Result.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.classsections = classData.ClassList
                        
                        self.response = classData.Response
                        if(self.response?.ResponseVal == 1){
                            for classsection in self.classsections!
                            {
                                self.classIds.append(classsection.id)
                                self.classNames.append("   " + classsection.Classsecname)
                            }
                            
                            if(self.classIds.count > 0 && self.classNames.count > 0){
                                // The list of array to display. Can be changed dynamically
                                self.dropDownClass.optionArray = self.classNames
                                // Its Id Values and its optional
                                self.dropDownClass.optionIds = self.classIds
                            }
                        }
                    }
                } catch let jsonError {
                    self.activityIndicator.stopAnimating()
                    
                    DispatchQueue.main.async {
                        alertView.showInfo("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageFetchdataError"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "buttonAlertOK"))
                    }
                    print(jsonError)
                }
            }
        }
    }
    
    func setNavigationBar() {
        let navigationFont = UIFont(name: "Helvetica", size: getTitleFontSize())
        let screenSize: CGRect = UIScreen.main.bounds
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: screenSize.width, height: 44))
        self.view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: self.defaultLocalizer.stringForKey(key: "navBarTitleExamResults"))
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
    
    @objc func back() { // remove @objc for Swift 3
        self.dismiss(animated: false, completion: nil)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func calculateTopDistance () -> CGFloat{
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 45
    }
    
    func loadExaminationView() {
        //Set wanted position and size (frame)
        
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + 48)
        let containerView = UIView(frame: CGRect(x: 0, y: self.calculateTopDistance(), width: self.view.frame.size.width, height: scroolHeight))
        
        self.dropDownClass = DropDown(frame: CGRect(x: 10, y: 10, width: (containerView.frame.size.width - 20), height: 50))
        self.setDropdown(height: scroolHeight - 28, dropDown: self.dropDownClass, text: self.defaultLocalizer.stringForKey(key: "dropDownLabelClass"), optionNames: classNames, optionIds: classIds)
        
        self.dropDownClass.listWillAppear {
            //You can Do anything when iOS DropDown listDidAppear
            dropDownClassShared.dropdownClassShared.isShown = 1;
        }
        
        // The the Closure returns Selected Index and String
        self.dropDownClass.didSelect{(selectedText , index ,id) in
            self.dropDownClass.textColor = UIColor.black
            self.classId = id
        }
        
        self.buttonSubmit = UIButton(frame: CGRect(x: 10, y: 70, width: containerView.frame.size.width - 20, height: 50))
        self.setSubmitButtonAppearence(buttonSubmit: buttonSubmit, buttonText: self.defaultLocalizer.stringForKey(key: "buttonLabelSubmitPlain"))
        buttonSubmit.addTarget(self, action: #selector(buttonSubmitTap), for:.touchUpInside)
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 130, width: self.view.frame.size.width, height: scroolHeight), style: UITableView.Style.plain)
        self.tableView.register(UINib(nibName: "ExamTableViewCell", bundle: nil), forCellReuseIdentifier: "ExamCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = true
        self.tableView.rowHeight = 95.0
        self.tableView.estimatedRowHeight = 95.0
        self.tableView.separatorStyle = .none
        
        self.refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        //Setup pull to refresh
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            self.tableView.addSubview(refreshControl)
        }
        
        containerView.insertSubview(tableView, at: 0)
        containerView.insertSubview(buttonSubmit, at: 1)
        containerView.insertSubview(self.dropDownClass, at: 3)
        self.view.addSubview(containerView)
        
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        self.view.addSubview(activityIndicator)
    }
    
    @objc func buttonSubmitTap()
    {
        self.tableView.register(UINib(nibName: "ExamResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ExamResultCell")
        self.tableView.rowHeight = 82.0
        self.tableView.estimatedRowHeight = 82.0
        self.getExamResults()
    }
    
    func setSubmitButtonAppearence(buttonSubmit: UIButton, buttonText: String){
        
        buttonSubmit.tintColor = UIColor.white
        buttonSubmit.backgroundColor = colorWithHexString(hex: "#00FFCC")
        buttonSubmit.layer.masksToBounds = false
        buttonSubmit.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        buttonSubmit.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        buttonSubmit.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        buttonSubmit.layer.shadowOpacity = 1.0
        buttonSubmit.layer.shadowRadius = 5.0
        buttonSubmit.layer.masksToBounds = false
        buttonSubmit.layer.cornerRadius = 3.0
        
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        imageView.image = UIImage(named: "ok")
        
        let buttonLabel = UILabel(frame: CGRect(x: 0, y: 0, width: buttonSubmit.frame.width, height: 50))
        buttonLabel.textColor = UIColor.white
        buttonLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        buttonLabel.textAlignment = .center
        buttonLabel.text = buttonText
        
        //buttonSubmit.addSubview(imageView)
        buttonSubmit.addSubview(buttonLabel)
    }
    
    func setDropdown(height: CGFloat, dropDown: DropDown, text: String, optionNames: [String], optionIds: [Int])
    {
        dropDown.placeholder = text;
        //dropDown.font = UIFont.systemFont(ofSize: 14.00)
        dropDown.textColor = UIColor.lightGray
        dropDown.backgroundColor = UIColor.white
        dropDown.rowBackgroundColor = UIColor.white;
        dropDown.borderWidth = 0.5
        dropDown.borderColor = colorWithHexString(hex: "#DDDDDD")
        dropDown.cornerRadius = 3
        dropDown.selectedRowColor = colorWithHexString(hex: "#DDDDDD");
        dropDown.arrowSize = 10;
        dropDown.isSearchEnable = false;
        // The list of array to display. Can be changed dynamically
        dropDown.optionArray = optionNames
        // Its Id Values and its optional
        dropDown.optionIds = optionIds
        dropDown.rowHeight = CGFloat(50)
        dropDown.listHeight = height
    }
    
    @objc func getExamResults()
    {
        let alertView = SCLAlertView(appearance: self.appearance)
        
        if(self.classId == 0)
        {
            alertView.showInfo("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageSelectClass"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
            return
        }
        // To make the activity indicator appear:
        self.activityIndicator.startAnimating()
        
        if let viewWithTag = self.view.viewWithTag(7575) {
            viewWithTag.removeFromSuperview()
        }
        
        let schoolid = getSchoolId()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "GetExaminationResultV2") {
            urlComponents.query = "schoolid=" + schoolid + "&classid=" + String(self.classId)
            // 3
            guard let url = urlComponents.url else { return }
            
            getData(from: url) { data, response, error in
                if error != nil {
                    
                    DispatchQueue.main.async {
                        alertView.showInfo("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageFetchdataError"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "buttonAlertOK"))
                    }
                    //print(error!.localizedDescription)
                }
                guard let data = data else { return }
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let examinationsData = try JSONDecoder().decode(Result.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.examinations = examinationsData.Examinations
                        dump(self.examinations)
                        self.response = examinationsData.Response
                        
                        self.activityIndicator.stopAnimating()
                        
                        if(self.response?.ResponseVal == 0)
                        {
                            self.displayAlertMessage()
                        }else{
                            if let viewWithTag = self.view.viewWithTag(7575) {
                                viewWithTag.removeFromSuperview()
                            }
                            self.tableView.reloadData()
                        }
                    }
                    
                } catch let jsonError {
                    self.activityIndicator.stopAnimating()
                    print(jsonError)
                }
                
                
            }
        }
    }
    
    @objc func refreshTable()
    {
        refreshControl.endRefreshing()
        self.getExamResults()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            
            var cell: AnyObject?
            
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "ExamResultCell") as! ExamResultTableViewCell
            
            cell2.buttonDownload?.setTitle(self.defaultLocalizer.stringForKey(key: "buttonDownloadExamResult"), for: UIControl.State.normal)
            
            var examination:Examination?
            examination = examinations?[indexPath.row]
            cell2.buttonDownload.tag = Int(examination!.id!)!
            cell2.textExamName.text = examination!.ExamName
            if(examination!.ResultDoc!.count > 0){
                cell2.buttonDownload.isHidden = false
                cell2.buttonDownload.addTarget(self, action:#selector(buttonDownloadExamResultTap), for:.touchUpInside)
            }
            else
            {
                cell2.buttonDownload.isHidden = true
            }
            cell = cell2
            
            return cell as! UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return examinations?.count ?? 0
    }
    
    @objc func buttonDownloadTimeTableTap(sender: UIButton)
    {
        let filtered = examTimeTables!.filter({
            return Int($0.ID!) == sender.tag
        })
        
        let vcDownload = self.storyboard?.instantiateViewController(withIdentifier: "vcDownload") as! DownloadViewController;()
        
        URLShared.urlshared.url = filtered[0].Timetable_Path;
        present(vcDownload, animated: false, completion: nil)
    }
    
    @objc func buttonDownloadExamResultTap(sender: UIButton)
    {
        let filtered = examinations!.filter({
            return Int($0.id!) == Int(sender.tag)
        })
        
        let vcDownload = self.storyboard?.instantiateViewController(withIdentifier: "vcDownload") as! DownloadViewController;()
        URLShared.urlshared.url = filtered[0].ResultDoc;
        
        present(vcDownload, animated: false, completion: nil)
    }
    
    func removeSubView()
    {
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(7575) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func displayAlertMessage()
    {
        let imageview = UIImageView(frame: CGRect(x: ((self.view.frame.size.width / 2) - 50), y: ((self.view.frame.size.height / 2) - 40), width: 100, height: 100))
        imageview.image = UIImage(named: "norecordfound")
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
        imageview.layer.masksToBounds = true
        imageview.tag = 7575
        self.removeSubView()
        self.view.addSubview(imageview)
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
