//
//  ExamMarksheetViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 01/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit
import MaterialComponents
import iOSDropDown
import SCLAlertView

class ExamMarksheetViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator()
    var exams:[Exam]?
    var classsections:[ExamClass]?
    var ExamMarks:[ExamMark]?
    var response:Response?
    var nomarksrecord:Nomarksrecord?
    var examname: String?
    var type: String?
    var examIds = [Int]()
    var examNames = [String]()
    var classIds = [Int]()
    var classNames = [String]()
    
    var tableView = UITableView()
    var headerView: UIView?
    let HEADERHEIGHT : CGFloat = 30
    var searchBar = UISearchBar()
    var searchActive : Bool = false
    var filtered:[ExamMark] = []
    var ExamMarksIds:[Int] = []
    
    var dropDownExam = DropDown()
    var dropDownClass = DropDown()
    var schoolid = Int()
    var teacherid = Int()
    var examId = Int()
    var classId = Int()
    var className = String()
    var toolbar:UIToolbar = UIToolbar()
    
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
        
        self.setExamMarksView()
        self.loadExam()
        
        dropDownClassShared.dropdownClassShared.isShown = 0
        dropDownSubjectShared.dropdownSubjectShared.isShown = 0
    }
    
    func loadExam() {
        self.activityIndicator.startAnimating()
        let schoolid = getSchoolId()
        let teacherid = getTeacherId()
        if var urlComponents = URLComponents(string: Constants.baseUrl + "GetExams") {
            urlComponents.query = "schoolid=" + schoolid + "&teacherid=" + teacherid
            // 3
            guard let url = urlComponents.url else { return}
            
            getData(from: url) { data, response, error in
                if error != nil {
                    self.activityIndicator.stopAnimating()
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return}
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let examData = try JSONDecoder().decode(ExamResponse.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.exams = examData.ExamList
                        self.response = examData.Response
                        if(self.response?.ResponseVal == 1){
                            for exam in self.exams!
                            {
                                self.examIds.append(Int(exam.examination_id!)!)
                                self.examNames.append("   " + exam.exam_name!)
                            }
                            
                            if(self.examIds.count > 0 && self.examNames.count > 0){
                                // The list of array to display. Can be changed dynamically
                                self.dropDownExam.optionArray = self.examNames
                                // Its Id Values and its optional
                                self.dropDownExam.optionIds = self.examIds
                            }
                        }
                    }
                } catch let jsonError {
                    self.activityIndicator.stopAnimating()
                    print(jsonError)
                }
            }
        }
    }
    
    func loadExamClass(examId: Int) {
        self.activityIndicator.startAnimating()
        let schoolid = getSchoolId()
        let teacherid = getTeacherId()
        let paramExamId = String(examId)
        if var urlComponents = URLComponents(string: Constants.baseUrl + "GetExamClass") {
            urlComponents.query = "schoolid=" + "\(schoolid)" + "&examid=" + "\(paramExamId)" + "&teacherid=" + "\(teacherid)"
            // 3
            guard let url = urlComponents.url else { return}
            
            getData(from: url) { data, response, error in
                if error != nil {
                    self.activityIndicator.stopAnimating()
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return}
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let classData = try JSONDecoder().decode(ExamResponse.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.classsections = classData.ClassList
                        self.response = classData.Response
                        if(self.response?.ResponseVal == 1){
                            for classsection in self.classsections!
                            {
                                self.classIds.append(Int(classsection.class_id!)!)
                                self.classNames.append("   " + classsection.class_section!)
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
                    print(jsonError)
                }
            }
        }
    }
    
    func getStudentMarks(examId: String, classid: Int)
    {
        let alertView = SCLAlertView(appearance: self.appearance)
        
        // To make the activity indicator appear:
        self.activityIndicator.startAnimating()
        
        let schoolid = getSchoolId()
        let teacherid = getTeacherId()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "GetStudentsMarks") {
            urlComponents.query = "schoolid=" + schoolid + "&examid=" + examId + "&classid=" + String(classid) + "&teacherid=" + teacherid + "&subjectid="
            // 3
            guard let url = urlComponents.url else { return }
            
            getData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                    alertView.showError("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageFetchdataError"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                }
                guard let data = data else { return }
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let studentData = try JSONDecoder().decode(ExamResponse.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.ExamMarks = studentData.StudentMarksList
                        self.response = studentData.Response
                        self.activityIndicator.stopAnimating()
                        
                        if(self.response?.ResponseVal == 1)
                        {
                            self.tableView.reloadData()
                        }
                        else
                        {
                            alertView.showError("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageNoMarksheetFound"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                        }
                    }
                    
                } catch let jsonError {
                    self.activityIndicator.stopAnimating()
                    print(jsonError)
                }
                
                
            }
        }
    }
    
    func calculateTopDistance () -> CGFloat{
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 45
    }
    
    func setDropdown(height: CGFloat, dropDown: DropDown, text: String, optionNames: [String], optionIds: [Int])
    {
        dropDown.placeholder = text
        dropDown.textColor = UIColor.lightGray
        dropDown.backgroundColor = UIColor.white
        dropDown.rowBackgroundColor = UIColor.white
        dropDown.borderWidth = 0.5
        dropDown.borderColor = colorWithHexString(hex: "#DDDDDD")
        dropDown.cornerRadius = 3
        dropDown.selectedRowColor = colorWithHexString(hex: "#DDDDDD")
        dropDown.arrowSize = 10
        dropDown.isSearchEnable = false
        // The list of array to display. Can be changed dynamically
        dropDown.optionArray = optionNames
        // Its Id Values and its optional
        dropDown.optionIds = optionIds
        dropDown.rowHeight = CGFloat(50)
        dropDown.listHeight = height
    }
    
    func setNavigationBar() {
        let navigationFont = UIFont(name: "Helvetica", size: getTitleFontSize())
        let screenSize: CGRect = UIScreen.main.bounds
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: screenSize.width, height: 44))
        self.view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: self.defaultLocalizer.stringForKey(key: "navBarTitleExamMarksheet"))
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
        
        //let doneItem = UIBarButtonItem(title: self.defaultLocalizer.stringForKey(key: "navBarButtonBack"), style: .plain, target: self, action: #selector(back))
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
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func setExamMarksView()
    {
        //let modelName = UIDevice.modelName
        
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + 48)
        let containerView = UIView(frame: CGRect(x: 0, y: self.calculateTopDistance(), width: self.view.frame.size.width, height: scroolHeight))
        
        self.dropDownExam = DropDown(frame: CGRect(x: 10, y: 10, width: containerView.frame.size.width - 20, height: 50))
        self.setDropdown(height: scroolHeight, dropDown: self.dropDownExam, text: self.defaultLocalizer.stringForKey(key: "dropDownLabelExam"), optionNames: examNames, optionIds: examIds)
        
        self.dropDownExam.listWillAppear {
            //You can Do anything when iOS DropDown listDidAppear
            dropDownExamhared.dropdownExamShared.isShown = 1
        }
        
        // The the Closure returns Selected Index and String
        self.dropDownExam.didSelect{(selectedText , index ,id) in
            self.dropDownExam.textColor = UIColor.black
            self.examId = id
            
            self.dropDownClass.text = String()
            self.dropDownClass.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelClass")
            
            self.loadExamClass(examId: self.examId)
        }
        
        self.dropDownClass = DropDown(frame: CGRect(x: 10, y: 70, width: containerView.frame.size.width - 20, height: 50))
        self.setDropdown(height: scroolHeight, dropDown: self.dropDownClass, text: self.defaultLocalizer.stringForKey(key: "dropDownLabelClass"), optionNames: classNames, optionIds: classIds)
        
        // The the Closure returns Selected Index and String
        self.dropDownClass.didSelect{(selectedText , index ,id) in
            self.dropDownClass.textColor = UIColor.black
            self.classId = id
            self.className = selectedText
            self.getStudentMarks(examId: String(self.examId), classid: self.classId)
        }
        
        let searchBarContainer = UIView(frame: CGRect(x: 0, y: 130, width: self.view.bounds.width, height: 40))
        
        self.searchBar = UISearchBar(frame: CGRect(x: 10, y: 0, width: searchBarContainer.frame.size.width - 20, height: 40))
        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.placeholder = self.defaultLocalizer.stringForKey(key: "placeHolderSearchStudent")
        self.searchBar.barTintColor = UIColor.white
        self.searchBar.delegate = self
        self.searchBar.layer.borderWidth = 1
        self.searchBar.layer.borderColor = UIColor.white.cgColor
        searchBarContainer.addSubview(searchBar)
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 165, width: self.view.frame.size.width, height: self.view.frame.size.height - 165), style: UITableView.Style.plain)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "ExamMarksheetTableViewCell", bundle: nil), forCellReuseIdentifier: "ExamMraksheetCell")
        self.tableView.rowHeight = 65.0// UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 65.0
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.white
        
        //init toolbar
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: self.defaultLocalizer.stringForKey(key: "toolBarButtonTitleDone"), style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        self.searchBar.inputAccessoryView = toolbar
        
        containerView.insertSubview(tableView, at: 5)
        containerView.insertSubview(searchBarContainer, at: 4)
        containerView.insertSubview(self.dropDownClass, at: 6)
        containerView.insertSubview(self.dropDownExam, at: 8)
        self.view.addSubview(containerView)
        
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        self.view.addSubview(activityIndicator)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = ExamMarks!.filter({
            return $0.student_name?.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        if(filtered.count == 0){
            self.searchActive = false
        } else {
            self.searchActive = true
        }
        
        self.tableView.reloadData()
    }
    
    func resetInputFileds()
    {
        self.dropDownClass.text = String()
        self.dropDownClass.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelClass")
        self.dropDownClass.isSelected = false
    }
    
    func removeSubView()
    {
        if let viewWithTag = self.view.viewWithTag(7575) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func setButtonSearchMarksheetAppearence(buttonSearchMarksheet: UIButton, buttonText: String){
        buttonSearchMarksheet.tintColor = UIColor.gray
        buttonSearchMarksheet.backgroundColor = colorWithHexString(hex: "#FFFFFF")
        buttonSearchMarksheet.layer.masksToBounds = false
        buttonSearchMarksheet.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        buttonSearchMarksheet.backgroundColor = colorWithHexString(hex: "#00FFCC")
        buttonSearchMarksheet.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        buttonSearchMarksheet.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        buttonSearchMarksheet.layer.shadowOpacity = 1.0
        buttonSearchMarksheet.layer.shadowRadius = 3.0
        buttonSearchMarksheet.layer.masksToBounds = false
        buttonSearchMarksheet.layer.cornerRadius = 3.0
        buttonSearchMarksheet.addTarget(self, action:#selector(buttonSearchMarksheetTap), for:.touchUpInside)
        buttonSearchMarksheet.addTarget(self, action:#selector(buttonSearchMarksheetTap), for:.touchUpOutside)
        
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        var image = UIImage.init(named: "search");
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        imageView.image = image
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonSearchMarksheetTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let buttonSearchMarksheetLabel = UILabel(frame: CGRect(x: 25, y: 0, width: buttonSearchMarksheet.frame.width - 20, height: 30))
        buttonSearchMarksheetLabel.textColor = UIColor.gray
        buttonSearchMarksheet.backgroundColor = colorWithHexString(hex: "#FFFFFF")
        buttonSearchMarksheetLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
        buttonSearchMarksheetLabel.textAlignment = .left
        buttonSearchMarksheetLabel.text = buttonText
        buttonSearchMarksheetLabel.addGestureRecognizer(tapGestureRecognizer)
        
        buttonSearchMarksheet.addSubview(imageView)
        buttonSearchMarksheet.addSubview(buttonSearchMarksheetLabel)
    }
    
    @objc func buttonSearchMarksheetTap(sender: UIButton)
    {
        let alertView = SCLAlertView(appearance: self.appearance)
        
        // To make the activity indicator appear:
        self.activityIndicator.startAnimating()
        
        let schoolid = getSchoolId()
        let selectedStudentId = String(sender.tag)
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "GetStudentsScore") {
            urlComponents.query = "schoolid=" + schoolid + "&examid=" + String(examId) + "&classid=" + String(self.classId) + "&subjectid=&studentid=" + selectedStudentId
            // 3
            guard let url = urlComponents.url else { return }
            
            print("GetStudentsScore: \(url)")
            getData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                guard let data = data else { return }
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let studentData = try JSONDecoder().decode(ExamResponse.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.ExamMarks = studentData.StudentMarksList
                        //dump(self.ExamMarks)
                        self.examname = studentData.examname
                        self.type = studentData.type
                        self.response = studentData.Response
                        self.activityIndicator.stopAnimating()
                        
                        if(self.response?.ResponseVal == 1)
                        {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "vcExamReportCard") as! ExamReportCardViewController
                            vc.modalPresentationStyle = .fullScreen
                            let examMarksModel: ExamMark?
                            examMarksModel = self.ExamMarks![0]
                            vc.imagePath = (examMarksModel?.profile_image)!
                            vc.studentName = (examMarksModel?.student_name)!
                            vc.className = self.className
                            vc.rollNumber = (examMarksModel?.roll_number)!
                            vc.examName = self.examname!
                            vc.examType = self.type!
                            vc.ExamMarks = self.ExamMarks
                            
                            self.present(vc, animated: false, completion: nil)
                            CFRunLoopWakeUp(CFRunLoopGetCurrent())
                        }
                        else
                        {
                            alertView.showError("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageNoMarksheetFound"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                        }
                    }
                    
                } catch let jsonError {
                    self.activityIndicator.stopAnimating()
                    print(jsonError)
                }
                
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamMraksheetCell") as! ExamMarksheetTableViewCell
        
        var filteredExamMarks:ExamMark?
        
        if(searchActive == true && filtered.count > 0){
            filteredExamMarks = filtered[indexPath.row]
        } else {
            filteredExamMarks = ExamMarks?[indexPath.row]
        }
        
        cell.textStudentName?.text = filteredExamMarks?.student_name
        cell.buttonSearch.tag = Int((filteredExamMarks?.student_id)!)!
        cell.buttonSearch.isUserInteractionEnabled = true
        self.setButtonSearchMarksheetAppearence(buttonSearchMarksheet: cell.buttonSearch, buttonText: self.defaultLocalizer.stringForKey(key: "buttonLabelMarksheet"))
        cell.buttonSearch.addTarget(self, action: #selector(buttonSearchMarksheetTap), for:.touchUpInside)
        cell.buttonSearch.addTarget(self, action: #selector(buttonSearchMarksheetTap), for:.touchUpOutside)
        
        if let url = URL(string: (filteredExamMarks?.profile_image)!) {
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    cell.profileImageView.image = UIImage(data: data)
                }
            }
        }
        let count = ExamMarks?.count ?? 0
        if(count > 0){
            self.searchBar.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        if(searchActive) {
            return filtered.count
        }
        count = ExamMarks?.count ?? 0
        
        return count
    }
}
