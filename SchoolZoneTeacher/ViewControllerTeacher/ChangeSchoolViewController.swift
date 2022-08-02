//
//  ChangeSchoolViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 23/02/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit
import MaterialComponents
import iOSDropDown
import SCLAlertView

class ChangeSchoolViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator()
    
    var tableView = UITableView()
    var schoolIds = [Int]()
    var schoolNames = [String]()
    var schoolLogos = [String]()
    var teacherIds = [String]()
    
    var response:Response?
    var teachers:[Teacher]?
    
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
        
        let schoolids = getSchoolIds()
        
        // Do any additional setup after loading the view.
        schoolIds.removeAll()
        schoolNames.removeAll()
        schoolLogos.removeAll()
        teacherIds.removeAll()
        
        for id in schoolids
        {
            schoolIds.append(Int(id)!)
        }
        schoolNames = getSchoolNames()
        schoolLogos = getSchoolLogos()
        teacherIds = getTeacherIds()
        
        //self.view.addSubview(scrollView)
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        self.view.addSubview(activityIndicator)
        
        self.setNavigationBar()
        self.loadSettingsView()
    }
    
    func loadSettingsView() {
        //Set wanted position and size (frame)
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + 48)
        let settingsView = UIView(frame: CGRect(x: 0, y: self.calculateTopDistance() + 49, width: self.view.frame.size.width, height: scroolHeight))
        settingsView.tag = 100
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: scroolHeight), style: UITableView.Style.plain)
        self.tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "settingsCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = true
        self.tableView.rowHeight = 95.0
        self.tableView.estimatedRowHeight = 95.0
        self.tableView.separatorStyle = .none
        settingsView.addSubview(tableView)
        
        //Add the view
        self.view.addSubview(settingsView)
    }
    
    func setNavigationBar() {
        let navigationFont = UIFont(name: "Helvetica", size: getTitleFontSize())
        let screenSize: CGRect = UIScreen.main.bounds;
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: screenSize.width, height: 44))
        self.view.addSubview(navBar);
        
        let navItem = UINavigationItem(title: self.defaultLocalizer.stringForKey(key: "navBarTitleChangeSchool"));
        let button = UIButton.init(type: .custom)
        button.setTitle(self.defaultLocalizer.stringForKey(key: "navBarButtonBack"), for: UIControl.State.normal)
        var image = UIImage.init(named: "back");
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action:#selector(back), for:.touchUpInside)
        button.addTarget(self, action:#selector(back), for:.touchUpOutside)
        button.frame = CGRect.init(x: 0, y: 0, width: 60, height: 44) //CGRectMake(0, 0, 30, 30)
        let doneItem = UIBarButtonItem.init(customView: button)
        
        //let doneItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = doneItem;
        
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
    
    @objc func back() { // remove @objc for Swift 3
        
        self.dismiss(animated: false, completion: nil)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func calculateTopDistance () -> CGFloat{
        if(self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent){
            return 0
        }else{
            let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
            let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
            return barHeight + statusBarHeight
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsTableViewCell
        
        cell.menuIcon.tintColor = colorWithHexString(hex: "#00CCFF")
        cell.menuOption.text = schoolNames[indexPath.row]
        
        if let url = URL(string: schoolLogos[indexPath.row]) {
            getImageData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return}
                
                //print(response)
                DispatchQueue.main.async() {
                    cell.menuIcon.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return schoolIds.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.loadProfile(schoolid: String(self.schoolIds[indexPath.row]), teacherid: self.teacherIds[indexPath.row])
    }
    
    func loadProfile(schoolid : String, teacherid: String)
    {
        // To make the activity indicator appear:
        self.activityIndicator.startAnimating()
        
        setFirstName(firstName: "")
        setMiddleName(middleName: "")
        setLastName(lastName: "")
        setDOB(dob: "")
        setGender(gender: "")
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "getTeacherProfile") {
            
            urlComponents.query = "schoolid=" + schoolid + "&teacherid=" + teacherid
            // 3
            guard let url = urlComponents.url else { return }
            //print(url)
            getData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
                guard let data = data else { return }
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let profileData = try JSONDecoder().decode(Result.self, from: data)
                    
                    self.response = profileData.Response
                    
                    if(self.response?.ResponseVal != 0)
                    {
                        self.teachers = profileData.Teachers
                        //dump(self.teachers)
                        var teacher: Teacher?
                        teacher = self.teachers?[0]
                        
                        //Get back to the main queue
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            
                            setSchoolId(schoolId: (teacher?.School_id)!)
                            setSchoolName(schoolName: (teacher?.School_Name)!)
                            setTeacherId(teacherId: (teacher?.TeacherID)!)
                            setFirstName(firstName: (teacher?.FirstName)!)
                            setMiddleName(middleName: (teacher?.MiddleName)!)
                            setLastName(lastName: (teacher?.LastName)!)
                            setEmail(email: (teacher?.Email)!)
                            setMobile(mobile: (teacher?.Mobile)!)
                            setDOB(dob: (teacher?.DOB)!)
                            setGender(gender: (teacher?.Gender)!)
                            //setLang(lang: (teacher?.Language)!)
                            setProfileImage(profileImage: (teacher?.ProfileImage)!)
                            setSchoolLogo(logoImage: (teacher?.SchoolLogo)!)
                            setSchoolAddress(address: (teacher?.SchoolAddress)!)
                            
                            AppLoadingStatus.appLoadingStatus.status = "Redirect"
                            
                            let vcLandingPage = self.storyboard!.instantiateViewController(withIdentifier: "vcRoot") as! RootViewController
                            
                            
                            vcLandingPage.statusBarShouldBeHidden = false
                            self.setNeedsStatusBarAppearanceUpdate()
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = vcLandingPage
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
        }
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
