//
//  AnswersViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 22/11/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit
import CropViewController
import Lightbox
import Alamofire
import MaterialComponents
import SCLAlertView
import Alamofire

class AnswersViewController: UIViewController, UITextViewDelegate, LightboxControllerPageDelegate, LightboxControllerDismissalDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, CropViewControllerDelegate{

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var tvTopic: UITextView!
    @IBOutlet weak var answersContainer: UIScrollView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var lblViewAttachment: UILabel!
    @IBOutlet weak var textEduForumAnswer: UITextView!
    @IBOutlet weak var attachmentIcon: UIImageView!
    
    @IBOutlet weak var labelAttachment: UILabel!
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator()
    
    var dataCache = NSCache<AnyObject, AnyObject>()
    
    var yposition: CGFloat!
    
    var result:Result?
    var Answers:[Answer]?
    var response:Response?
    
    var topicId:Int!
    var imagePath: String!
    var topic:String!
    var createdBy:String!
    var isLocked:String!
    
    var imageController = UIImagePickerController()
    var imagePreviewContainer = UIView()
    
    var offsetY:CGFloat = 0
    var adjustY = CGFloat()
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!
    )
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getAnswers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChangeNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardFrameChangeNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
            let animationCurveRawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue)
            let animationCurve = UIView.AnimationOptions(rawValue: UInt(animationCurveRawValue))
            
            var navBarHeight = self.calculateTopDistance()
            if(textEduForumAnswer.isFirstResponder){
                if(UIScreen.main.nativeBounds.height >= 2436){
                    navBarHeight -= (90 + 89)
                }
                else
                {
                    navBarHeight -= (90 + 55)
                }
                if let _ = endFrame, endFrame!.intersects(self.container.frame) {
                    self.offsetY = (self.container.frame.maxY - endFrame!.minY) - navBarHeight
                    print(self.offsetY)
                    UIView.animate(withDuration: animationDuration, delay: TimeInterval(0), options: animationCurve, animations: {
                        self.container.frame.origin.y = self.container.frame.origin.y - self.offsetY
                    }, completion: nil)
                } else {
                    if self.offsetY != 0 {
                        UIView.animate(withDuration: animationDuration, delay: TimeInterval(0), options: animationCurve, animations: {
                            self.container.frame.origin.y = self.container.frame.origin.y + self.offsetY
                            self.offsetY = 0
                        }, completion: nil)
                    }
                }
            }
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
        
        let tabbarHeight = getTabbarHeight()
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + tabbarHeight)
        
        container.layer.frame = CGRect(x: 10, y: 10, width: self.view.frame.size.width - 20, height: scroolHeight - 80)
        
        container.layer.borderWidth = 0.5
        container.layer.cornerRadius = 3.0
        container.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        container.layer.shadowColor = UIColor.lightGray.cgColor
        container.layer.shadowOffset = CGSize(width: 3, height: 3)
        container.layer.shadowOpacity = 0.5
        
        
        let font = UIFont(name: "Helvetica", size: 14.0)
        let height = self.heightForView(text: topic, font: font!, width: container.frame.width - 10)
        
        for constraint in self.tvTopic.constraints {
            if constraint.identifier == "constraintsDescHeight" {
                let oldHeight = constraint.constant
                if(oldHeight < height){
                    constraint.constant = height
                }
            }
        }
        self.tvTopic.layoutIfNeeded()
        
        for constraint in self.container.constraints {
            if constraint.identifier == "containerHeight" {
                //print("scroolHeight: \(constraint.constant)")
                constraint.constant = scroolHeight - 20
                //print("\nscroolHeight: \(constraint.constant)")
            }
        }
        self.container.layoutIfNeeded()
        
        if(self.isLocked == "1")
        {
            labelAttachment.font = UIFont(name:"HelveticaNeue-Bold", size: 14.0)
            labelAttachment.textColor = UIColor.red
            labelAttachment.text = self.defaultLocalizer.stringForKey(key: "labelTopicEnded")
            btnAttachment.isHidden = true
            textEduForumAnswer.isHidden = true
            btnSend.isHidden = true
        }
        
        let data = topic.data(using: String.Encoding.unicode)! // mind "!"
        let attrStr = try? NSAttributedString( // do catch
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        // suppose we have an UILabel, but any element with NSAttributedString will do
        self.tvTopic.attributedText = attrStr
        self.tvTopic.textAlignment = .justified
        self.tvTopic.font = font
        self.tvTopic.isEditable = false
        
        textEduForumAnswer.text = self.defaultLocalizer.stringForKey(key: "placeHolderReply")
        textEduForumAnswer.font = UIFont(name:"Helvetica", size: 14.0)
        textEduForumAnswer.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor;
        textEduForumAnswer.layer.borderWidth = 1.0;
        textEduForumAnswer.layer.cornerRadius = 5.0;
        textEduForumAnswer.isEditable = true;
        textEduForumAnswer.textColor = UIColor.lightGray
        textEduForumAnswer.delegate = self
        
        btnSend.isUserInteractionEnabled = true
        btnSend.addTarget(self, action:#selector(submitReply), for:.touchUpOutside)
        btnSend.addTarget(self, action: #selector(submitReply), for:.touchUpInside)
        btnAttachment.addTarget(self, action:#selector(buttonAttachmentTap), for:.touchUpOutside)
        btnAttachment.addTarget(self, action:#selector(buttonAttachmentTap), for:.touchUpInside)
        
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: self.defaultLocalizer.stringForKey(key: "toolBarButtonTitleDone"), style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        self.textEduForumAnswer.inputAccessoryView = toolbar
        
        if(self.isLocked == "1")
        {
            textEduForumAnswer.isEditable = false
            btnAttachment.isEnabled = false
            btnSend.isEnabled = false
        }
        
        self.imagePreviewContainer = UIView(frame: CGRect(x: 10, y: self.container.frame.size.height, width: self.container.frame.size.width, height: (self.container.frame.size.width / 3) - 40))
        self.container.addSubview(self.imagePreviewContainer)
        
        self.imagePreviewContainer.isHidden = true
        attachmentIcon.isHidden = true
        lblViewAttachment.isHidden = true
        if(self.isLocked != "1")
        {
            labelAttachment.isHidden = true
        }
        
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        self.view.addSubview(activityIndicator)
    }
    
    func setNavigationBar() {
        let navigationFont = UIFont(name: "Helvetica", size: getTitleFontSize())
        
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
        self.navigationItem.leftBarButtonItem = doneItem
        
        let width = self.view.frame.width - 60
        let height = CGFloat(44)
        
        let titleLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        titleLabel.text = self.defaultLocalizer.stringForKey(key: "EduForumDiscussion")
        titleLabel.textAlignment = .center
        titleLabel.font = navigationFont
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let desiredOffset = CGPoint(x: 0, y: -self.textEduForumAnswer.contentInset.top)
        self.textEduForumAnswer.setContentOffset(desiredOffset, animated: false)
    }
    
    func calculateTopDistance () -> CGFloat{
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 45
    }
    
    private func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let globalPoints = textField.superview?.convert(textField.frame.origin, to: nil)
        adjustY = ((globalPoints?.y)! - self.calculateTopDistance()) + 50
        
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if self.container.frame.origin.y == self.calculateTopDistance() {
            //print(adjustY)
            let bottomSpace = (self.container.frame.size.height - adjustY) // calculate space below the control
            if(bottomSpace < keyboardFrame.size.height) // not enogh space for keboard display
            {
                let orginY = keyboardFrame.size.height - bottomSpace
                self.container.frame.origin.y -= orginY
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.container.frame.origin.y != self.calculateTopDistance() {
            self.container.frame.origin.y = self.calculateTopDistance()
        }
    }
    
    @objc func submitReply(_sender: UIButton)
    {
        if(textEduForumAnswer.text?.count == 0 || textEduForumAnswer.text == self.defaultLocalizer.stringForKey(key: "placeHolderReply"))
        {
            let alert = UIAlertController(title: "OurSchoolZone", message: self.defaultLocalizer.stringForKey(key: "submitErrorTypeAnswer"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: self.defaultLocalizer.stringForKey(key: "buttonAlertOK"), style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let schoolid = getSchoolId()
        let teacherid = getTeacherId()
        let reply = textEduForumAnswer.text
        
        let alertView = SCLAlertView(appearance: self.appearance)
        
        let queryString = "forum_id=\(topicId!)&answer_id=0&answer=\(reply!)&answerdate=\(formatter.string(from: currentDate))&school_id=\(schoolid)&parent_id=&teacher_id=\(teacherid)"
        
        // To make the activity indicator appear:
        self.activityIndicator.startAnimating()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "AddTopicAnswer") {
            urlComponents.query = queryString
            // 3
            guard let url = urlComponents.url else { return}
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            if self.view.viewWithTag(11) != nil || self.view.viewWithTag(12) != nil || self.view.viewWithTag(13) != nil {
                
                let boundary = generateBoundaryString()
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = createBody(boundary: boundary)
            }
            
            postData(from: request) { data, response, error in
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //let responseMessage = String(describing: response)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        
                        alertView.showError("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "submitErrorAnswerNotPosted"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                        self.btnSend.isUserInteractionEnabled = true;
                    }
                    return
                }
                else
                {
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        
                        self.textEduForumAnswer.text = String()
                        
                        alertView.showSuccess("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "submitSuccessAnswerPosted"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                    }
                }
            }
        }
    }
    
    @objc func alertViewOKTap()
    {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textReply: UITextView) {
        if textReply.textColor == UIColor.lightGray {
            textReply.text = nil
            textReply.textColor = UIColor.black
        }
        textReply.tintColor = UIColor.gray
    }
    
    func textViewDidEndEditing(_ textReply: UITextView) {
        if textReply.text.isEmpty {
            textReply.text = self.defaultLocalizer.stringForKey(key: "placeHolderReply")
            textReply.textColor = UIColor.lightGray
        }
    }
    
    func removeView(tag: Int)
    {
        if let viewWithTag = self.view.viewWithTag(tag) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x:0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        
        return label.frame.height
    }
    
    func getAnswers()
    {
        for view in self.answersContainer.subviews {
            view.removeFromSuperview()
        }
        
        self.activityIndicator.startAnimating()
        
        let alertView = SCLAlertView(appearance: self.appearance)
        self.yposition = 5
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "GetTopicAnswers") {
            urlComponents.query = "topic_id=\(topicId!)"
            // 3
            guard let url = urlComponents.url else { return }
            //print("GetTopicAnswers URL: \(url)")
            
            getData(from: url) { data, response, error in
                if error != nil {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        alertView.showInfo("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageFetchdataError"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "buttonAlertOK"))
                    }
                    print(error!.localizedDescription)
                }
                guard let data = data else { return }
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let topicData = try JSONDecoder().decode(Result.self, from: data)
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        
                        var rowIndex:Int = 0
                        
                        self.Answers = topicData.answerList
                        //dump("Answers: \(self.Answers!)")
                        self.response = topicData.Response
                        
                        if(self.response?.ResponseVal != 0)
                        {
                            for answerObj in self.Answers! {
                                
                                let profileImageView = UIImageView(frame: CGRect(x: 5, y: self.yposition, width: 35, height:35))
                                profileImageView.backgroundColor = UIColor.lightGray
                                profileImageView.layer.cornerRadius = 17.5;
                                profileImageView.layer.borderWidth = 1.0;
                                profileImageView.layer.borderColor = UIColor.lightGray.cgColor
                                profileImageView.layer.masksToBounds = true;
                                profileImageView.tag = 1111
                                var profileImageUrl: String!
                                
                                let labelUser = UILabel(frame: CGRect(x: 45, y: self.yposition, width: self.answersContainer.frame.width  - 50, height:15))
                                labelUser.font = UIFont(name: "Helvetica-Bold", size: 12.0)
                                
                                if(answerObj.parent_id.trimmingCharacters(in: .whitespacesAndNewlines).count > 0)
                                {
                                    labelUser.text = answerObj.parent_name
                                    profileImageUrl = answerObj.parent_profile_image
                                }
                                else if(answerObj.teacher_id.trimmingCharacters(in: .whitespacesAndNewlines).count > 0){
                                    labelUser.text = answerObj.teacher_name
                                    profileImageUrl = answerObj.teacher_profile_image
                                }
                                else
                                {
                                    labelUser.text = answerObj.school_name
                                    profileImageUrl = answerObj.school_logo
                                }
                                
                                labelUser.tag = 1112
                                
                                if(answerObj.attachment.count > 0){
                                    let buttonViewAttachment = UIButton(frame: CGRect(x: self.answersContainer.frame.width  - 35, y: self.yposition, width: 30, height: 30))
                                    buttonViewAttachment.backgroundColor = colorWithHexString(hex: "#FFFFFF")
                                    buttonViewAttachment.tintColor = colorWithHexString(hex: "#00CCFF")
                                    buttonViewAttachment.layer.cornerRadius = 15
                                    buttonViewAttachment.tintColor = colorWithHexString(hex: "#00CCFF")
                                    buttonViewAttachment.layer.masksToBounds = true
                                    buttonViewAttachment.tag = rowIndex
                                    buttonViewAttachment.setImage(UIImage(named: "attachment"), for: .normal)
                                    buttonViewAttachment.addTarget(self, action:#selector(self.showAttachemt), for:.touchUpInside)
                                    buttonViewAttachment.addTarget(self, action:#selector(self.showAttachemt), for:.touchUpOutside)
                                    self.answersContainer.addSubview(buttonViewAttachment)
                                }
                                
                                profileImageView.image = UIImage(named: "noimage")
                                let id = answerObj.id
                                
                                if(profileImageUrl.count > 0){
                                    if let dataFromCache = self.dataCache.object(forKey: id as AnyObject) as? Data{
                                        
                                        profileImageView.image = UIImage(data: dataFromCache)
                                    }
                                    else
                                    {
                                        Alamofire.request((profileImageUrl)!, method: .get).response { (responseData) in
                                            if let data = responseData.data {
                                                DispatchQueue.main.async {
                                                    self.dataCache.setObject(data as AnyObject, forKey: id as AnyObject)
                                                    profileImageView.image = UIImage(data: data)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                self.yposition += 20
                                let labelAnswerDate = UILabel(frame: CGRect(x: 45, y: self.yposition, width: self.answersContainer.frame.width  - 50, height:15))
                                labelAnswerDate.text = answerObj.answerdate
                                labelAnswerDate.font = UIFont.systemFont(ofSize: 10)
                                labelAnswerDate.tag = 1113
                                
                                self.yposition += 20
                                
                                let answerString = answerObj.answer.replacingOccurrences(of: "\\n", with: "<p>", options: .regularExpression, range: nil)
                                let data = answerString.data(using: String.Encoding.unicode)!
                                let attrStr = try? NSAttributedString(
                                    data: data,
                                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                    documentAttributes: nil)
                                
                                let font = UIFont(name: "Helvetica", size: 14.0)
                                let height = self.heightForView(text: answerObj.answer, font: font!, width: self.answersContainer.frame.width  - 50)
                                
                                let commentTextView = UITextView(frame: .zero)
                                commentTextView.frame = CGRect(x: 45, y: self.yposition, width: self.answersContainer.frame.width  - 50, height: height + 10)
                                commentTextView.isEditable = false
                                commentTextView.isSelectable = false
                                commentTextView.isScrollEnabled = false
                                commentTextView.attributedText = attrStr
                                commentTextView.font = UIFont(name: "Helvetica", size: 12.0)
                                commentTextView.textAlignment = NSTextAlignment.justified
                                
                                self.yposition = self.yposition + commentTextView.frame.height + 10
                                
                                var image = UIImage.init(named: "like");
                                var templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                                image = templateImage
                                
                                let buttonLike = UIButton(frame: CGRect(x: 45, y: self.yposition, width: 25, height:25))
                                buttonLike.backgroundColor = colorWithHexString(hex: "#FFFFFF")
                                buttonLike.tintColor = colorWithHexString(hex: "#3399CC")
                                buttonLike.layer.masksToBounds = true
                                buttonLike.setImage(image, for: UIControl.State.normal)
                                buttonLike.addTarget(self, action:#selector(self.addLike), for:.touchUpInside)
                                buttonLike.addTarget(self, action:#selector(self.addLike), for:.touchUpOutside)
                                buttonLike.tag = answerObj.id
                                
                                let labelLikeCount = UILabel(frame: CGRect(x: 71, y: (self.yposition + 5), width: 20, height:20))
                                labelLikeCount.layer.cornerRadius = 10
                                labelLikeCount.layer.masksToBounds = true
                                labelLikeCount.backgroundColor = colorWithHexString (hex: "#00CCFF")
                                labelLikeCount.text = String(answerObj.like_count)
                                labelLikeCount.textAlignment = .center
                                labelLikeCount.font = UIFont.boldSystemFont(ofSize: 15)
                                labelLikeCount.textColor = colorWithHexString (hex: "#FFFFFF")
                                
                                image = UIImage.init(named: "dislike");
                                templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                                image = templateImage
                                let buttonDislike = UIButton(frame: CGRect(x: 105, y: (self.yposition + 5), width: 25, height:25))
                                buttonDislike.backgroundColor = colorWithHexString(hex: "#FFFFFF")
                                buttonDislike.tintColor = colorWithHexString(hex: "#3399CC")
                                buttonDislike.layer.masksToBounds = true
                                buttonDislike.setImage(image, for: UIControl.State.normal)
                                buttonDislike.addTarget(self, action:#selector(self.addDislike), for:.touchUpInside)
                                buttonDislike.addTarget(self, action:#selector(self.addDislike), for:.touchUpOutside)
                                buttonDislike.tag = (answerObj.id + 1)
                                
                                let labelDislikeCount = UILabel(frame: CGRect(x: 131, y: (self.yposition + 5), width: 20, height:20))
                                labelDislikeCount.layer.cornerRadius = 10
                                labelDislikeCount.layer.masksToBounds = true
                                labelDislikeCount.backgroundColor = colorWithHexString (hex: "#00CCFF")
                                labelDislikeCount.text = String(answerObj.dislike_count)
                                labelDislikeCount.textAlignment = .center
                                labelDislikeCount.font = UIFont.boldSystemFont(ofSize: 15)
                                labelDislikeCount.textColor = colorWithHexString (hex: "#FFFFFF")
                                
                                self.yposition += 35
                                
                                self.answersContainer.addSubview(profileImageView)
                                self.answersContainer.addSubview(labelUser)
                                self.answersContainer.addSubview(commentTextView)
                                self.answersContainer.addSubview(labelAnswerDate)
                                self.answersContainer.addSubview(buttonLike)
                                self.answersContainer.addSubview(buttonDislike)
                                self.answersContainer.addSubview(labelLikeCount)
                                self.answersContainer.addSubview(labelDislikeCount)
                                
                                rowIndex += 1
                            }
                            
                            self.answersContainer.contentSize = CGSize(width: self.answersContainer.frame.width, height: self.yposition)
                        }
                    }
                    
                } catch let jsonError {
                    self.activityIndicator.stopAnimating()
                    print(jsonError)
                }
                
                
            }
        }
    }
    
    @objc func addLike(_ sender: UIButton)
    {
        //print("addLike: \(sender.tag)")
        
        let answerId:Int = Int(sender.tag)
        let teacherId:String = getTeacherId()
        
        let queryString = "answerid=\(answerId)&parentid=&teacherid=\(teacherId)"
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "addLike") {
            urlComponents.query = queryString
            // 3
            guard let url = urlComponents.url else { return}
            
            //print("addDislike URL: \(url)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            postData(from: request) { data, response, error in
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //let responseMessage = String(describing: response)
                    return
                }
                else
                {
                    guard let data = data else { return }
                    //Implement JSON decoding and parsing
                    do {
                        let likeData = try JSONDecoder().decode(Result.self, from: data)
                        DispatchQueue.main.async {
                            self.response = likeData.Response
                            
                            if(self.response?.ResponseVal == 1)
                            {
                                //Get back to the main queue
                                self.getAnswers()
                            }
                        }
                    }catch let jsonError {
                        print(jsonError)
                    }
                }
            }
        }
    }
    
    @objc func addDislike(_ sender: UIButton)
    {
        //print("addLike: \(Int(sender.tag) - 1)")
        let answerId:Int = Int(sender.tag) - 1
        let teacherId:String = getTeacherId()
        
        let queryString = "answerid=\(answerId)&parentid=&teacherid=\(teacherId)"
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "addDislike") {
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
                else
                {
                    guard let data = data else { return }
                    //Implement JSON decoding and parsing
                    do {
                        let likeData = try JSONDecoder().decode(Result.self, from: data)
                        DispatchQueue.main.async {
                            self.response = likeData.Response
                            
                            if(self.response?.ResponseVal == 1)
                            {
                                //Get back to the main queue
                                self.getAnswers()
                            }
                        }
                    }catch let jsonError {
                        print(jsonError)
                    }
                }
            }
        }
    
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @objc func zoomImage(_ sender: UITapGestureRecognizer)
    {
        if(imagePath != nil){
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
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    @objc func buttonAttachmentTap(_ sender: UIButton) {
        imageController.delegate = self;
        
        //here I want to execute the UIActionSheet
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: self.defaultLocalizer.stringForKey(key: "actionSheetTitleCamera"), style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.openCamera()
        }))
        
        actionsheet.addAction(UIAlertAction(title: self.defaultLocalizer.stringForKey(key: "actionSheetTitleGallery"), style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.openGallary()
        }))
        actionsheet.addAction(UIAlertAction(title: self.defaultLocalizer.stringForKey(key: "actionSheetTitleCancel"), style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
            
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
        
        // Restyle the view of the Alert
        actionsheet.view.tintColor = colorWithHexString (hex: "#333333")  // change text color of the buttons
        actionsheet.view.backgroundColor = colorWithHexString (hex: "#00CCFF")  // change background color
        actionsheet.view.layer.cornerRadius = 25
        
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        let cropViewController = CropViewController(image: (info[.originalImage] as? UIImage)!)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        
        if let viewWithTag = self.view.viewWithTag(11) {
            print("viewWithTag.removeFromSuperview()")
            viewWithTag.removeFromSuperview()
        }
        
        PickedImageCountShared.pickedImageCountShared.count = 1
        attachmentIcon.isHidden = false
        labelAttachment.isHidden = false
        lblViewAttachment.isHidden = false
        lblViewAttachment.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self , action: #selector(self.showNewAttachemt))
        lblViewAttachment.addGestureRecognizer(tapgesture)
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "View", attributes: underlineAttribute)
        lblViewAttachment.attributedText = underlineAttributedString
        
        let imagePreview = UIImageView(frame: CGRect(x: 0, y: 0, width: (imagePreviewContainer.frame.size.width / 3) - 20, height: (imagePreviewContainer.frame.size.width / 3) - 20))
        imagePreview.contentMode = .scaleAspectFit // OR .scaleAspectFill
        imagePreview.clipsToBounds = true
        imagePreview.layer.borderWidth = 0.5
        imagePreview.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        imagePreview.layer.cornerRadius = 5
        imagePreview.image = image
        imagePreview.tag = 11
        
        var image = UIImage.init(named: "close");
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        
        let removeButton = UIButton(frame: CGRect(x: imagePreview.frame.size.width - 30, y: 0, width: 30, height: 30))
        removeButton.backgroundColor = colorWithHexString(hex: "#FFFFFF")
        removeButton.tintColor = colorWithHexString(hex: "#00CCFF")
        removeButton.layer.cornerRadius = 15
        removeButton.tintColor = colorWithHexString(hex: "#00CCFF")
        removeButton.layer.masksToBounds = true
        
        removeButton.tag = 1100
        removeButton.setImage(image, for: UIControl.State.normal)
        removeButton.addTarget(self, action:#selector(removeImage), for:.touchUpInside)
        removeButton.addTarget(self, action:#selector(removeImage), for:.touchUpOutside)
        
        imagePreviewContainer.addSubview(imagePreview)
        imagePreviewContainer.addSubview(removeButton)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func removeImage(sender: UIButton)
    {
        PickedImageCountShared.pickedImageCountShared.count = 0
        
        let tag = sender.tag / 100
        if let viewWithTag = self.imagePreviewContainer.viewWithTag(tag) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.imagePreviewContainer.viewWithTag(sender.tag) {
            viewWithTag.removeFromSuperview()
        }
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
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBody(boundary: String) -> Data {
        var body = Data();
        
        var imageView = UIImageView()
        if self.view.viewWithTag(11) != nil {
            imageView = self.view.viewWithTag(11) as! UIImageView
            
            let imageData = imageView.image!.jpegData(compressionQuality: 0.75)
            
            if(imageData != nil){
                let filePathKey = "file1"
                let filename = "Classwork_Image1.jpg"
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
    
    @objc func showAttachemt(sender: UIButton)
    {
        var answerModel:Answer?
        answerModel = self.Answers?[sender.tag]
        let imagePath = answerModel?.attachment
        
        if(imagePath != nil){
            let images = [LightboxImage(imageURL: URL(string: imagePath!)!)]
            
            // Create an instance of LightboxController.
            let controller = LightboxController(images: images)
            
            // Set delegates.
            controller.pageDelegate = self
            controller.dismissalDelegate = self
            
            // Use dynamic background.
            controller.dynamicBackground = true
            controller.modalPresentationStyle = .fullScreen
            // Present your controller.
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func showNewAttachemt()
    {
        print("showNewAttachemt")
        let viewWithTag = self.view.viewWithTag(11) as! UIImageView
        
        let imagePath = viewWithTag.image
        
        if(imagePath != nil){
            let images = [LightboxImage(image: imagePath!)]
            
            // Create an instance of LightboxController.
            let controller = LightboxController(images: images)
            
            // Set delegates.
            controller.pageDelegate = self
            controller.dismissalDelegate = self
            
            // Use dynamic background.
            controller.dynamicBackground = true
            controller.modalPresentationStyle = .fullScreen
            // Present your controller.
            self.present(controller, animated: true, completion: nil)
        }
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

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
