//
//  AddTopicViewController.swift
//  vZons
//
//  Created by Apple on 13/08/19.
//

import UIKit
import CropViewController
import Alamofire
import MaterialComponents
import SCLAlertView

class AddTopicViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, CropViewControllerDelegate {
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator()
    var containerView = UIView()
    var txtTitle = UITextField()
    var txtPublishDate = UITextField()
    var txtDesc = UITextView()
    
    var imageController = UIImagePickerController()
    var imagePreviewContainer = UIView()
    var buttonSubmit = UIButton()
    var buttonAttachment = UIButton()
    var buttonCalendar = UIButton()
    var adjustY = CGFloat()
    
    var schoolid = Int()
    var teacherid = Int()
    var parentid = Int()
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!
    )
    
    func textViewShouldBeginEditing(_ txtDesc: UITextView) -> Bool {
        let globalPoints = txtDesc.superview?.convert(txtDesc.frame.origin, to: nil)
        adjustY = ((globalPoints?.y)! - self.calculateTopDistance()) + 80
        
        return true
    }
    
    func textViewDidBeginEditing(_ txtDesc: UITextView) {
        if txtDesc.textColor == UIColor.lightGray {
            txtDesc.text = nil
            txtDesc.textColor = UIColor.black
        }
        txtDesc.tintColor = UIColor.gray
    }
    
    func textViewDidEndEditing(_ txtDesc: UITextView) {
        if txtDesc.text.isEmpty {
            //txtDesc.text = "Description_Text".localized()
            txtDesc.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (txtDesc.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 200    // 10 Limit Value
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let globalPoints = textField.superview?.convert(textField.frame.origin, to: nil)
        adjustY = ((globalPoints?.y)! - self.calculateTopDistance()) + 50
        
        
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        //print("adjustY: \(adjustY)")
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if self.containerView.frame.origin.y == self.calculateTopDistance() {
            //print(adjustY)
            let bottomSpace = (self.containerView.frame.size.height - adjustY) // calculate space below the control
            if(bottomSpace < keyboardFrame.size.height) // not enogh space for keboard display
            {
                let orginY = keyboardFrame.size.height - bottomSpace
                self.containerView.frame.origin.y -= orginY
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.containerView.frame.origin.y != self.calculateTopDistance() {
            self.containerView.frame.origin.y = self.calculateTopDistance()
        }
    }
    
    func calculateTopDistance () -> CGFloat{
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 45
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
        
        self.setAddTopicView()
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
        titleLabel.text = self.defaultLocalizer.stringForKey(key: "EduForumAddTopic")
        titleLabel.textAlignment = .center
        titleLabel.font = navigationFont
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func setAddTopicView()
    {
        let tabbarHeight = getTabbarHeight()
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + tabbarHeight)
        
        containerView = UIView(frame: CGRect(x: 5, y: 5, width: self.view.frame.size.width - 10, height: scroolHeight - 10))
        
        txtTitle = UITextField(frame: CGRect(x: 10, y: 10, width: (self.containerView.frame.size.width - 20), height: 50))
        txtTitle.borderStyle = .roundedRect
        txtTitle.attributedPlaceholder = NSAttributedString(string: self.defaultLocalizer.stringForKey(key: "labelTitle"),
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        txtTitle.delegate = self
        
        txtDesc = UITextView(frame: CGRect(x: 10, y: 70, width: (containerView.frame.size.width - 20), height: 250))
        txtDesc.text = self.defaultLocalizer.stringForKey(key: "placeHolderDesc")
        txtDesc.font = UIFont(name:"Helvetica", size: 16.0)
        txtDesc.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor;
        txtDesc.layer.borderWidth = 1.0;
        txtDesc.layer.cornerRadius = 5.0;
        txtDesc.isEditable = true;
        txtDesc.textColor = UIColor.lightGray
        txtDesc.delegate = self
        
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: self.defaultLocalizer.stringForKey(key: "toolBarButtonTitleDone"), style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        txtTitle.inputAccessoryView = toolbar
        txtDesc.inputAccessoryView = toolbar
        
        buttonAttachment = UIButton(frame: CGRect(x: 10, y: 330, width: ((self.containerView.frame.size.width / 2) - 15), height: 50))
        self.setAttachmentButtonAppearence(buttonAttachment: buttonAttachment, buttonText: self.defaultLocalizer.stringForKey(key: "buttonLabelAttachment"))
        
        self.buttonSubmit = UIButton(frame: CGRect(x: ((self.containerView.frame.size.width / 2) + 5), y: 330, width: ((self.containerView.frame.size.width / 2) - 15), height: 50))
        self.setSubmitButtonAppearence(buttonSubmit: buttonSubmit, buttonText: self.defaultLocalizer.stringForKey(key: "buttonLabelSubmit"))
        buttonSubmit.addTarget(self, action: #selector(submitTopic), for:.touchUpInside)
        buttonSubmit.addTarget(self, action: #selector(submitTopic), for:.touchUpOutside)
        
        self.imagePreviewContainer = UIView(frame: CGRect(x: 10, y: 390, width: self.containerView.frame.size.width, height: (self.containerView.frame.size.width / 3) - 40))
        
        self.containerView.addSubview(txtTitle)
        self.containerView.addSubview(txtDesc)
        self.containerView.addSubview(self.imagePreviewContainer)
        self.containerView.addSubview(self.buttonSubmit)
        self.containerView.addSubview(self.buttonAttachment)
        self.view.addSubview(containerView)
        
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        self.view.addSubview(activityIndicator)
    }
    
    @objc func submitTopic(_sender: UIButton)
    {
        
        let alertView = SCLAlertView(appearance: self.appearance)
        
        if(txtDesc.text?.count == 0 || txtDesc.text == self.defaultLocalizer.stringForKey(key: "placeHolderDesc"))
        {
            alertView.showInfo("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "submitErrorEnterTopicDesc"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "buttonAlertOK"))
            
            return
        }
        self.activityIndicator.startAnimating()
        
        self.buttonSubmit.isEnabled = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        formatter.timeZone = NSTimeZone.local
        // Apply date format
        let publishdate: String = formatter.string(from: Date())
        
        let schoolid = getSchoolId()
        let teacherid = getTeacherId()
        let title = txtTitle.text!
        let desc = txtDesc.text!
        
        let queryString = "title=\(title)&description=\(desc)&publishdate=\(publishdate)&school_id=\(schoolid)&parent_id=&teacher_id=\(teacherid)"
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "AddTopic") {
            urlComponents.query = queryString
            // 3
            guard let url = urlComponents.url else { return }
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            if self.view.viewWithTag(11) != nil {
                
                let boundary = generateBoundaryString()
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = createBody(boundary: boundary)
            }
            
            Alamofire.request(request).responseJSON{response in
                
                if let httpStatus = response.response, httpStatus.statusCode != 200 {
                    //let responseMessage = String(describing: response.response)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        let alert = UIAlertController(title: "OurSchoolZone", message: self.defaultLocalizer.stringForKey(key: "submitErrorTopicNotPosted"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"), style: .default, handler: { action in
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                guard let data = response.data else { return }
                
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    
                    let responseData = try JSONDecoder().decode(Result.self, from: data)
                    
                    //dump("responseData: \(responseData.Response.ResponseVal)")
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        if(responseData.Response.ResponseVal == 1)
                        {
                            self.txtTitle.text = String()
                            self.txtDesc.text = String()
                            if let viewWithTag = self.view.viewWithTag(11) {
                                viewWithTag.removeFromSuperview()
                            }
                            if let viewWithTag = self.view.viewWithTag(1100) {
                                viewWithTag.removeFromSuperview()
                            }
                            
                            let alert = UIAlertController(title: "OurSchoolZone", message: self.defaultLocalizer.stringForKey(key: "submitSuccessTopicPosted"), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"), style: .default, handler: { action in
                                self.navigationController?.popViewController(animated: false)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else
                        {
                            let alert = UIAlertController(title: "OurSchoolZone", message: responseData.Response.Reason, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"), style: .default, handler: { action in
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                } catch {
                    //let responseMessage = String(describing: jsonError)
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc func back() {
        AppLoadingStatus.appLoadingStatus.status = "Redirect"
        self.navigationController?.popViewController(animated: false)
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
        buttonSubmit.isMultipleTouchEnabled = false
        
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        imageView.image = UIImage(named: "ok")
        
        let buttonLabel = UILabel(frame: CGRect(x: 40, y: 0, width: buttonSubmit.frame.width - 40, height: 50))
        
        buttonLabel.textColor = UIColor.white
        buttonLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        buttonLabel.textAlignment = .left
        buttonLabel.text = buttonText
        
        buttonSubmit.addSubview(imageView)
        buttonSubmit.addSubview(buttonLabel)
    }
    
    func setAttachmentButtonAppearence(buttonAttachment: UIButton, buttonText: String){
        buttonAttachment.tintColor = UIColor.gray
        buttonAttachment.backgroundColor = colorWithHexString(hex: "#FFFFFF")
        buttonAttachment.layer.masksToBounds = false
        buttonAttachment.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        buttonAttachment.backgroundColor = colorWithHexString(hex: "#00FFCC")
        buttonAttachment.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        buttonAttachment.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        buttonAttachment.layer.shadowOpacity = 1.0
        buttonAttachment.layer.shadowRadius = 5.0
        buttonAttachment.layer.masksToBounds = false
        buttonAttachment.layer.cornerRadius = 3.0
        buttonAttachment.addTarget(self, action:#selector(buttonAttachmentTap), for:.touchUpInside)
        
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        imageView.image = UIImage(named: "attachment")
        
        let buttonAttachementLabel = UILabel(frame: CGRect(x: 40, y: 0, width: buttonAttachment.frame.width - 40, height: 50))
        buttonAttachementLabel.textColor = UIColor.gray
        buttonAttachment.backgroundColor = colorWithHexString(hex: "#FFFFFF")
        buttonAttachementLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        buttonAttachementLabel.textAlignment = .left
        buttonAttachementLabel.text = buttonText
        
        buttonAttachment.addSubview(imageView)
        buttonAttachment.addSubview(buttonAttachementLabel)
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
        
        PickedImageCountShared.pickedImageCountShared.count = 1
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
