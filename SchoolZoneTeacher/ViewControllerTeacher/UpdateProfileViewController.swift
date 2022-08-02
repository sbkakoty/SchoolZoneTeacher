//
//  UpdateProfileViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 23/01/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit
import MaterialComponents
import iOSDropDown
import SCLAlertView
import CropViewController

class UpdateProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, CropViewControllerDelegate {
    
    var opQueue = OperationQueue()
    @IBOutlet weak var containerView: UIView!
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator()
    var headerView = UIView()
    var contentView = UIView()
    var profileImageButton = UIButton()
    var textTeacherName = UILabel()
    var textUserType = UILabel()
    var labelName = UILabel()
    var textName = UITextField()
    var labelGender = UILabel()
    var dropDownGender = DropDown()
    var labelDOB = UILabel()
    var txtDOB = UITextField()
    var labelEMail = UILabel()
    var textEMail = UITextField()
    var labelMobile = UILabel()
    var textMobile = UITextField()
    
    var response:Response?
    var teachers:[Teacher]?
    
    var viewProfileVC: UIViewController!
    var imagePath: String!
    var teacherName: String!
    var dob: String!
    var gender: String!
    var email: String!
    var mobile: String!
    var genderNames = ["  Male", "  Female"]
    var genderIds = [1, 2]
    var selectedGender: String!
    
    var imageController = UIImagePickerController()
    var buttonSubmit = UIButton()
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
        showCloseButton: false
    )
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag == 4444)
        {
            if string.rangeOfCharacter(from: NSCharacterSet.letters) != nil
            {
                return true
            }
            else {
                return false
            }
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        //print(textField.tag)
        if(textField.tag == 5555)
        {
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
            textField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        }
        textField.tintColor = UIColor.gray
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        txtDOB.text = dateFormatter.string(from: sender.date)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //print("TextField did end editing method called\(String(describing: textField.text))")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //print("TextField should begin editing method called")
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        //print("TextField should clear method called")
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //print("TextField should end editing method called")
        return true
    }
    
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
        
        if(viewProfileVC != nil)
        {
            viewProfileVC.dismiss(animated: false, completion: nil)
        }
        
        PickedImageCountShared.pickedImageCountShared.count = 0
        
        if(getLanguage().count > 0)
        {
            defaultLocalizer.setSelectedLanguage(lang: getLanguage())
        }
        else
        {
            defaultLocalizer.setSelectedLanguage(lang: "en")
        }
        
        self.setNavigationBar()
        self.setUpdateProfileView()
    }
    
    func setUpdateProfileView(){
        
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + 48)
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: defaultLocalizer.stringForKey(key: "toolBarButtonTitleDone"), style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        self.headerView = UIView(frame: CGRect(x: 0, y: self.calculateTopDistance() - 1, width: self.view.frame.size.width, height: 130))
        self.headerView.backgroundColor = colorWithHexString(hex: "#00CCFF")
        
        self.profileImageButton = UIButton(frame: CGRect(x: (self.headerView.frame.size.width / 2) - 40, y: 0, width: 80, height: 80))
        self.profileImageButton.backgroundColor = UIColor.white
        self.profileImageButton.layer.cornerRadius = 40
        self.profileImageButton.tintColor = colorWithHexString(hex: "#00CCFF")
        self.profileImageButton.clipsToBounds = true
        
        if let url = URL(string: self.imagePath!) {
            getImageData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return}
                
                DispatchQueue.main.async() {
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
                    imageView.image = UIImage(data: data)
                    imageView.tag = 5
                    self.profileImageButton.addSubview(imageView)
                }
            }
        }
        self.profileImageButton.addTarget(self, action:#selector(self.selectImage), for:.touchUpInside)
        self.profileImageButton.addTarget(self, action:#selector(self.selectImage), for:.touchUpOutside)
        
        self.textTeacherName = UILabel(frame: CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: 23))
        self.textUserType = UILabel(frame: CGRect(x: 0, y: 103, width: self.view.frame.size.width, height: 23))
        self.textTeacherName.textColor = UIColor.white
        self.textUserType.textColor = UIColor.white
        self.textTeacherName.textAlignment = .center
        self.textUserType.textAlignment = .center
        
        self.headerView.addSubview(self.profileImageButton)
        self.headerView.addSubview(self.textTeacherName)
        self.headerView.addSubview(self.textUserType)
        self.containerView.addSubview(self.headerView)
        
        self.contentView = UIView(frame: CGRect(x: 10, y: self.calculateTopDistance() + 130, width: self.view.frame.size.width - 20, height: self.view.bounds.maxY))
        self.labelName = UILabel(frame: CGRect(x: 0, y: 5, width: self.contentView.frame.size.width, height: 20))
        self.labelName.text = defaultLocalizer.stringForKey(key: "labelTeacherName")
        self.labelName.textColor = UIColor.gray
        self.textName = UITextField(frame: CGRect(x: 0, y: 25, width: self.contentView.frame.size.width, height: 50))
        self.textName.borderStyle = .roundedRect
        self.textName.attributedPlaceholder = NSAttributedString(string: defaultLocalizer.stringForKey(key: "labelTeacherName"),
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.textName.tintColor = UIColor.gray
        
        let separatorOne = UIView(frame: CGRect(x: 0, y: 86, width: self.contentView.frame.size.width, height: 1))
        separatorOne.backgroundColor = UIColor.groupTableViewBackground
        
        self.labelGender = UILabel(frame: CGRect(x: 0, y: 90, width: (self.contentView.frame.size.width / 2) - 40, height: 20))
        self.labelGender.text = defaultLocalizer.stringForKey(key: "labelGender")
        self.labelGender.textColor = UIColor.gray
        
        self.dropDownGender = DropDown(frame: CGRect(x: 0, y: 110, width: (self.contentView.frame.size.width / 2) - 30, height: 50))
        self.setDropdown(height: scroolHeight, dropDown: self.dropDownGender, text: defaultLocalizer.stringForKey(key: "dropDownLabelGender"), optionNames: genderNames, optionIds: genderIds)
        // The the Closure returns Selected Index and String
        self.dropDownGender.didSelect{(selectedText , index ,id) in
            self.dropDownGender.textColor = UIColor.black
            self.selectedGender = selectedText.trimmingCharacters(in: .whitespaces)
        }
        
        self.labelDOB = UILabel(frame: CGRect(x: (self.contentView.frame.size.width / 2) - 10, y: 90, width: (self.contentView.frame.size.width / 2) - 30, height: 20))
        self.labelDOB.text = defaultLocalizer.stringForKey(key: "labelDOB")
        self.labelDOB.textColor = UIColor.gray
        txtDOB = UITextField(frame: CGRect(x: (self.contentView.frame.size.width / 2) - 10, y: 110, width: (self.contentView.frame.size.width / 2) + 10, height: 50))
        txtDOB.borderStyle = .roundedRect
        self.txtDOB.tag = 5555
        txtDOB.delegate = self
        txtDOB.attributedPlaceholder = NSAttributedString(string: defaultLocalizer.stringForKey(key: "labelDOB"),
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        /*self.buttonCalendar = UIButton(frame: CGRect(x: (self.contentView.frame.width - 40), y: 72, width: 50, height: 50))
        self.buttonCalendar.addTarget(self, action: #selector(buttonCalendarTap), for:.touchUpInside)
        
        self.setbuttonCalendarAppearence(buttonCalendar: self.buttonCalendar)*/
        
        let separatorTwo = UIView(frame: CGRect(x: 0, y: 170, width: self.contentView.frame.size.width, height: 1))
        separatorTwo.backgroundColor = UIColor.groupTableViewBackground
        let separatorThree = UIView(frame: CGRect(x: (self.contentView.frame.size.width / 2) - 20, y: 110, width: 1, height: 50))
        separatorThree.backgroundColor = UIColor.groupTableViewBackground
        
        self.labelEMail = UILabel(frame: CGRect(x: 0, y: 174, width: self.contentView.frame.size.width, height: 20))
        self.labelEMail.text = defaultLocalizer.stringForKey(key: "labelEmail")
        self.labelEMail.textColor = UIColor.gray
        self.textEMail = UITextField(frame: CGRect(x: 0, y: 194, width: self.contentView.frame.size.width, height: 30))
        self.textEMail.borderStyle = .roundedRect
        self.textEMail.attributedPlaceholder = NSAttributedString(string: defaultLocalizer.stringForKey(key: "labelEmail"),
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.textEMail.isEnabled = false
        
        let separatorFour = UIView(frame: CGRect(x: 0, y: 234, width: self.contentView.frame.size.width, height: 1))
        separatorFour.backgroundColor = UIColor.groupTableViewBackground
        
        self.labelMobile = UILabel(frame: CGRect(x: 0, y: 238, width: self.contentView.frame.size.width, height: 20))
        self.labelMobile.text = defaultLocalizer.stringForKey(key: "labelMobile")
        self.labelMobile.textColor = UIColor.gray
        self.textMobile = UITextField(frame: CGRect(x: 0, y: 258, width: self.contentView.frame.size.width, height: 30))
        self.textMobile.borderStyle = .roundedRect
        self.textMobile.attributedPlaceholder = NSAttributedString(string: defaultLocalizer.stringForKey(key: "labelMobile"),
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.textMobile.isEnabled = false
        
        self.buttonSubmit = UIButton(frame: CGRect(x: 0, y: 298, width: self.contentView.frame.size.width, height: 50))
        self.setSubmitButtonAppearence(buttonSubmit: buttonSubmit, buttonText: defaultLocalizer.stringForKey(key: "buttonLabelUpdate"))
        self.buttonSubmit.addTarget(self, action: #selector(updateProfile), for:.touchUpInside)
        self.buttonSubmit.addTarget(self, action: #selector(updateProfile), for:.touchUpOutside)
        
        self.textUserType.text = defaultLocalizer.stringForKey(key: "labelUserType")
        self.textTeacherName.text = teacherName
        self.textName.text = teacherName
        self.textName.keyboardType = .alphabet
        //self.textName.delegate = self
        self.textName.tag = 4444
        self.txtDOB.text = dob
        self.textEMail.text = email
        self.textMobile.text = mobile
        self.selectedGender = gender
        
        self.textName.inputAccessoryView = toolbar
        self.txtDOB.inputAccessoryView = toolbar
        self.textEMail.inputAccessoryView = toolbar
        self.textMobile.inputAccessoryView = toolbar
        self.textMobile.keyboardType = .phonePad
        self.textEMail.keyboardType = .emailAddress
        
        self.contentView.insertSubview(self.buttonSubmit, at: 17)
        self.contentView.insertSubview(self.textMobile, at: 1)
        self.contentView.insertSubview(self.labelMobile, at: 2)
        self.contentView.insertSubview(separatorFour, at: 3)
        self.contentView.insertSubview(self.textEMail, at: 3)
        self.contentView.insertSubview(self.labelEMail, at: 5)
        self.contentView.insertSubview(separatorOne, at: 6)
        self.contentView.insertSubview(separatorTwo, at: 6)
        self.contentView.insertSubview(self.txtDOB, at: 9)
        self.contentView.insertSubview(self.labelDOB, at: 10)
        self.contentView.insertSubview(separatorThree, at: 11)
        self.contentView.insertSubview(self.dropDownGender, at: 12)
        self.contentView.insertSubview(self.labelGender, at: 13)
        self.contentView.insertSubview(separatorOne, at: 14)
        self.contentView.insertSubview(self.textName, at: 15)
        self.contentView.insertSubview(self.labelName, at: 16)
        
        self.containerView.addSubview(self.contentView)
        
        self.contentView.isUserInteractionEnabled = true
        self.containerView.isUserInteractionEnabled = true
        
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        self.view.addSubview(activityIndicator)
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @objc func selectImage(_ sender: UIButton) {
        imageController.isEditing = false
        imageController.delegate = self
        
        //here I want to execute the UIActionSheet
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: defaultLocalizer.stringForKey(key: "actionSheetTitleCamera"), style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.openCamera()
        }))
        
        actionsheet.addAction(UIAlertAction(title: defaultLocalizer.stringForKey(key: "actionSheetTitleGallery"), style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.openGallary()
        }))
        actionsheet.addAction(UIAlertAction(title: defaultLocalizer.stringForKey(key: "actionSheetTitleCancel"), style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
            
        }))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            actionsheet.popoverPresentationController?.sourceView = sender
            actionsheet.popoverPresentationController?.sourceRect = sender.bounds
            actionsheet.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    func setSubmitButtonAppearence(buttonSubmit: UIButton, buttonText: String){
        
        buttonSubmit.tintColor = UIColor.white
        buttonSubmit.backgroundColor = colorWithHexString(hex: "#00FFCC")
        buttonSubmit.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        buttonSubmit.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        buttonSubmit.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        buttonSubmit.layer.shadowOpacity = 1.0
        buttonSubmit.layer.shadowRadius = 5.0
        buttonSubmit.layer.masksToBounds = false
        buttonSubmit.layer.cornerRadius = 3.0
        buttonSubmit.isUserInteractionEnabled = true
        let buttonLabel = UILabel(frame: CGRect(x: 0, y: 0, width: buttonSubmit.frame.width, height: 50))
        buttonLabel.textColor = UIColor.white
        buttonLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        buttonLabel.textAlignment = .center
        buttonLabel.text = buttonText
        
        buttonSubmit.addSubview(buttonLabel)
    }
    
    @objc func updateProfile()
    {
        
        let alertView = SCLAlertView(appearance: self.appearance)
        
        if(self.textName.text!.count == 0)
        {
            alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK")) {
                alertView.dismiss(animated: true, completion: nil)
            }
            alertView.showInfo("OurSchoolZone", subTitle: defaultLocalizer.stringForKey(key: "allertMessageEnterName"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
            return
        }
        
        if(self.txtDOB.text!.count == 0)
        {
            alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK")) {
                alertView.dismiss(animated: true, completion: nil)
            }
            alertView.showInfo("OurSchoolZone", subTitle: defaultLocalizer.stringForKey(key: "allertMessageEnterDOB"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
            return
        }
        
        if(self.textMobile.text!.count == 0)
        {
            alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK")) {
                alertView.dismiss(animated: true, completion: nil)
            }
            alertView.showInfo("OurSchoolZone", subTitle: defaultLocalizer.stringForKey(key: "allertMessageEnterMobile"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
            return
        }
        
        if(self.selectedGender.count > 0)
        {
            self.gender = self.selectedGender
        }
        
        self.buttonSubmit.isUserInteractionEnabled = false
        
        var fullNameArr = self.textName.text!.split{$0 == " "}.map(String.init)
        
        if(PickedImageCountShared.pickedImageCountShared.count == 1) {
            let queryString = "Mobile=" + "\(self.textMobile.text!)"
            
            if var urlComponents = URLComponents(string: Constants.baseUrl + "UpdateProfileImage") {
                urlComponents.query = queryString
                // 3
                guard let url = urlComponents.url else { return}
                
                //print(url)
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                let boundary = generateBoundaryString()
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = createBody(boundary: boundary)
                
                postData(from: request) { data, response, error in
                    
                    let responseMessage = response!
                    print(responseMessage.description)
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print(httpStatus.statusCode)
                        //Get back to the main queue
                        DispatchQueue.main.async {
                            self.buttonSubmit.isUserInteractionEnabled = true
                            alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK")) {
                                alertView.dismiss(animated: true, completion: nil)
                            }
                            alertView.showError("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageProfileImageSubmitError"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                        }
                        return
                    }
                    else
                    {
                        //Get back to the main queue
                        DispatchQueue.main.async {
                            self.buttonSubmit.isUserInteractionEnabled = true
                        }
                    }
                }
            }
        }
        
        if(fullNameArr.count == 1)
        {
            fullNameArr.append("")
        }
        
        let queryString = "FirstName=" + "\(fullNameArr[0])" + "&LastName=" + "\(fullNameArr[1])" + "&Mobile=" + "\(self.textMobile.text!)" + "&DOB=" + "\(self.txtDOB.text!)" + "&Gender=" + "\(self.gender!)"
        
        // To make the activity indicator appear:
        self.activityIndicator.startAnimating()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "UpdateProfile") {
            urlComponents.query = queryString
            // 3
            guard let url = urlComponents.url else { return}
            
            //print(url)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            postData(from: request) { data, response, error in
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //let responseMessage = String(describing: response)
                    //print(responseMessage)
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.buttonSubmit.isUserInteractionEnabled = true
                        self.activityIndicator.stopAnimating()
                        
                        alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK")) {
                            alertView.dismiss(animated: true, completion: nil)
                        }
                        alertView.showError("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageProfileSubmitError"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                    }
                    return
                }
                else
                {
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.buttonSubmit.isUserInteractionEnabled = true
                        self.activityIndicator.stopAnimating()
                        
                        alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"), target:self, selector: #selector(self.alertViewOKTap))
                        
                        alertView.showSuccess("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageProfileSubmitSuccess"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                    }
                }
            }
        }
    }
    
    @objc func alertViewOKTap()
    {
        self.loadProfile()
    }
    
    func loadProfile()
    {
        let schoolid = getSchoolId()
        let teacherid = getTeacherId()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "getTeacherProfile") {
            
            urlComponents.query = "schoolid=" + schoolid + "&teacherid=" + teacherid
            // 3
            guard let url = urlComponents.url else { return }
            
            getData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                guard let data = data else { return }
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let profileData = try JSONDecoder().decode(Result.self, from: data)
                    
                    self.response = profileData.Response
                    
                    self.activityIndicator.stopAnimating()
                    
                    if(self.response?.ResponseVal != 0)
                    {
                        self.teachers = profileData.Teachers
                        //dump(self.teachers)
                        var teacher: Teacher?
                        teacher = self.teachers?[0]
                        
                        //Get back to the main queue
                        DispatchQueue.main.async {
                            //print("\nNew: " + (teacher?.ProfileImage)!)
                            setFirstName(firstName: (teacher?.FirstName)!)
                            setMiddleName(middleName: (teacher?.MiddleName)!)
                            setLastName(lastName: (teacher?.LastName)!)
                            setDOB(dob: (teacher?.DOB)!)
                            setGender(gender: (teacher?.Gender)!)
                            setProfileImage(profileImage: (teacher?.ProfileImage)!)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "vcProfileView") as! ProfileViewController
                            vc.modalPresentationStyle = .fullScreen
                            vc.schoolName = getSchoolName()
                            let fname = getFirstName() + " "
                            let mname = getMiddleName().count > 0 ? getMiddleName() + " " : ""
                            let lname = getLastName()
                            let fullname = fname + mname + lname
                            vc.teacherName = fullname
                            vc.email = getEmail()
                            vc.mobile = getMobile()
                            vc.dob = getDOB()
                            vc.gender = getGender()
                            vc.imagePath = (teacher?.ProfileImage)!
                            vc.editprofileVC = self
                            self.present(vc, animated: false, completion: nil)
                        }
                    }
                    
                } catch let jsonError {
                    self.activityIndicator.stopAnimating()
                    print(jsonError)
                }
            }
        }
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBody(boundary: String) -> Data {
        var body = Data();
        
        var imageView = UIImageView()
        if self.view.viewWithTag(2) != nil {
            imageView = self.view.viewWithTag(2) as! UIImageView
            
            let imageData = imageView.image!.jpegData(compressionQuality: 0.75)
            
            if(imageData != nil){
                let filePathKey = "file1"
                let filename = "Profile_Image1.jpg"
                let mimetype = "image/jpg"
                
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(imageData!)
                //body.appendData(imageDataKey)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body
    }
    
    func setNavigationBar() {
        let navigationFont = UIFont(name: "Helvetica", size: getTitleFontSize())
        let screenSize: CGRect = UIScreen.main.bounds
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: screenSize.width, height: 44))
        self.view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: self.defaultLocalizer.stringForKey(key: "navBarTitleUpdateProfile"))
        let button = UIButton.init(type: .custom)
        button.setTitle(self.defaultLocalizer.stringForKey(key: "navBarButtonBack"), for: UIControl.State.normal)
        var image = UIImage.init(named: "back")
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action:#selector(back), for:.touchUpInside)
        button.addTarget(self, action:#selector(back), for:.touchUpOutside)
        button.frame = CGRect.init(x: 0, y: 0, width: 60, height: 44) //CGRectMake(0, 0, 30, 30)
        let doneItem = UIBarButtonItem.init(customView: button)
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
        
        if(self.gender == "Male"){
            self.dropDownGender.textColor = UIColor.black
            dropDown.selectedIndex = 0
            dropDown.text = optionNames[0]
        }
        
        if(self.gender == "Female"){
            self.dropDownGender.textColor = UIColor.black
            dropDown.selectedIndex = 1
            dropDown.text = optionNames[1]
        }
    }
    
    func calculateTopDistance () -> CGFloat{
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 45
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        /*var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            PickedImageCountShared.pickedImageCountShared.count = 1
            let imagePreview = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            imagePreview.contentMode = .scaleAspectFit // OR .scaleAspectFill
            imagePreview.clipsToBounds = true
            imagePreview.layer.cornerRadius = 40
            imagePreview.image = selectedImage
            imagePreview.tag = 2
            profileImageButton.addSubview(imagePreview)
        }*/
        
        dismiss(animated: true, completion: nil)
        
        let cropViewController = CropViewController(image: (info[.originalImage] as? UIImage)!)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        PickedImageCountShared.pickedImageCountShared.count = 1
        let imagePreview = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imagePreview.contentMode = .scaleAspectFit // OR .scaleAspectFill
        imagePreview.clipsToBounds = true
        imagePreview.layer.cornerRadius = 40
        imagePreview.image = image
        imagePreview.tag = 2
        
        if let viewWithTag = self.view.viewWithTag(5) {
            viewWithTag.removeFromSuperview()
        }
        
        profileImageButton.addSubview(imagePreview)
        
        dismiss(animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            self.imageController = UIImagePickerController.init()
            self.imageController.sourceType = UIImagePickerController.SourceType.camera
            self.imageController.delegate = self
            self.imageController.allowsEditing = false
            self.imageController.modalPresentationStyle = .overCurrentContext
            self.present(imageController, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: self.defaultLocalizer.stringForKey(key: "actionSheetTitleWarning"), message: self.defaultLocalizer.stringForKey(key: "actionSheetMessageNoCamera"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        self.imageController = UIImagePickerController.init()
        self.imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.imageController.delegate = self
        self.imageController.allowsEditing = false
        self.imageController.modalPresentationStyle = .overCurrentContext
        self.present(imageController, animated: true, completion: nil)
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
