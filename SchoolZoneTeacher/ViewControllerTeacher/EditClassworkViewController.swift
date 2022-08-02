//
//  ClassworkViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 13/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import UIKit
import SCLAlertView
import iOSDropDown
import MaterialComponents
import CropViewController
import Speech

class EditClassworkViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, CropViewControllerDelegate, SFSpeechRecognizerDelegate {
    
    var classworkId: Int!
    var className: String!
    var subjectName: String!
    var bookName: String!
    var chapterName: String!
    var chapterIndex: String!
    var date: String!
    var remarks: String!
    var Doc_path: String!
    var Doc_path2: String!
    var Doc_path3: String!
    
    var editClassId: Int!
    var editSubjectId: Int!
    var editBookId: Int!
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator();
    var classsections:[Classsection]?
    var subjects:[Subject]?
    var books:[Book]?
    var bookChapters:[BookChapter]?
    var response:Response?
    var bookDetails:BookDetail?
    var classIds = [Int]()
    var classNames = [String]()
    var subjectIds = [Int]()
    var subjectNames = [String]()
    var bookIds = [Int]()
    var bookNames = [String]()
    var bookChapterIds = [Int]()
    var bookChapterNames = [String]()
    var bookChapterIndex = [String]()
    var chapterIds = [Int]()
    var chapterNames = [String]()
    
    var footerView: UIView?
    let FOOTERHEIGHT : CGFloat = 50;
    
    var containerView = UIView()
    var imageButtonMic = UIButton()
    var labelMic = UILabel()
    var dropDownClass = DropDown()
    var dropDownSubject = DropDown()
    var dropDownBook = DropDown()
    var dropDownBookChapter = DropDown()
    var txtBookName = UITextField()
    var txtBookChapterName = UITextField()
    var txtChapterIndex = UITextField()
    var txtRemark = UITextView()
    var schoolid = Int()
    var teacherid = Int()
    var classId = Int()
    var subjectId = Int()
    var bookId = Int()
    var bookChapterId = Int()
    
    var imageController = UIImagePickerController()
    var imagePreviewContainer = UIView()
    var buttonSubmit = UIButton()
    var buttonAttachment = UIButton()
    
    var adjustY = CGFloat()
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
        showCloseButton: false
    )
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch is NSException
        {
            print("audioSession properties weren't set because of an error.")
            DispatchQueue.main.async {
                self.labelMic.text = "Couldn't start audio because of an error."
                self.imageButtonMic.isUserInteractionEnabled = false
            }
        }
        catch {
            print("audioSession properties weren't set because of an error.")
            DispatchQueue.main.async {
                self.labelMic.text = "Couldn't start audio because of an error."
                self.imageButtonMic.isUserInteractionEnabled = false
            }
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.txtRemark.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                
                self.audioEngine.stop()
                //inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        self.audioEngine.prepare()
        
        do {
            try self.audioEngine.start()
            DispatchQueue.main.async {
                self.labelMic.text = "Listening..."
                self.imageButtonMic.isUserInteractionEnabled = true
            }
        }
        catch is NSException
        {
            print("audioSession properties weren't set because of an error.")
            DispatchQueue.main.async {
                self.labelMic.text = "Couldn't start audio because of an error."
                self.imageButtonMic.isUserInteractionEnabled = false
            }
        }
        catch {
            print("audioEngine couldn't start because of an error.")
            DispatchQueue.main.async {
                self.labelMic.text = "Couldn't start audio because of an error."
                self.imageButtonMic.isUserInteractionEnabled = false
            }
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("available")
        } else {
            print("not available")
        }
    }
    
    func textViewShouldBeginEditing(_ txtRemark: UITextView) -> Bool {
        
        /*if audioEngine.isRunning {
         audioEngine.stop()
         recognitionRequest?.endAudio()
         } else {
         startRecording()
         }*/
        
        let globalPoints = txtRemark.superview?.convert(txtRemark.frame.origin, to: nil)
        adjustY = ((globalPoints?.y)! - self.calculateTopDistance()) + 100
        
        return true
    }
    
    func textViewDidBeginEditing(_ txtRemark: UITextView) {
        if txtRemark.textColor == UIColor.lightGray {
            txtRemark.text = nil
            txtRemark.textColor = UIColor.black
        }
        txtRemark.tintColor = UIColor.gray
    }
    
    func textViewDidEndEditing(_ txtRemark: UITextView) {
        if txtRemark.text.isEmpty {
            txtRemark.text = self.defaultLocalizer.stringForKey(key: "placeHolderDesc")
            txtRemark.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (txtRemark.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 200    // 10 Limit Value
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        textField.tintColor = UIColor.gray
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let globalPoints = textField.superview?.convert(textField.frame.origin, to: nil)
        adjustY = ((globalPoints?.y)! - self.calculateTopDistance()) + 50
        
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        dropDownClassShared.dropdownClassShared.isShown = 0
        dropDownSubjectShared.dropdownSubjectShared.isShown = 0
        dropDownBookShared.dropdownBookShared.isShown = 0
        dropDownBookChapterShared.dropdownBookChapterShared.isShown = 0
        
        if(getLanguage().count > 0)
        {
            defaultLocalizer.setSelectedLanguage(lang: getLanguage())
        }
        else
        {
            defaultLocalizer.setSelectedLanguage(lang: "en")
        }
        
        PickedImageCountShared.pickedImageCountShared.count = 0
        self.setNavigationBar()
        self.setClassworkSubmissionView()
        self.loadClass()
    }
    
    func setClassworkSubmissionView()
    {
        let scroolHeight = self.view.frame.size.height - self.calculateTopDistance()
        
        containerView = UIView(frame: CGRect(x: 0, y: self.calculateTopDistance(), width: self.view.frame.size.width, height: scroolHeight))
        
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: self.defaultLocalizer.stringForKey(key: "toolBarButtonTitleDone"), style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        self.dropDownClass = DropDown(frame: CGRect(x: 10, y: 10, width: ((self.containerView.frame.size.width / 2) - 15), height: 50))
        self.setDropdown(height: scroolHeight - 108, dropDown: self.dropDownClass, text: defaultLocalizer.stringForKey(key: "dropDownLabelClass"), optionNames: classNames, optionIds: classIds)
        
        self.dropDownClass.listWillAppear {
            //You can Do anything when iOS DropDown listDidAppear
            dropDownClassShared.dropdownClassShared.isShown = 1;
        }
        
        // The the Closure returns Selected Index and String
        self.dropDownClass.didSelect{(selectedText , index ,id) in
            self.dropDownClass.textColor = UIColor.black
            self.classId = id
            self.subjectId = 0
            self.bookId = 0
            self.dropDownSubject.text = String()
            self.dropDownBook.text = String()
            self.dropDownBookChapter.text = String()
            self.dropDownSubject.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelSubject")
            self.dropDownBook.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelBook")
            self.dropDownBookChapter.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelChapter")
            
            self.loadSubjects(classId: self.classId)
        }
        
        self.dropDownSubject = DropDown(frame: CGRect(x: ((self.containerView.frame.size.width / 2) + 5), y: 10, width: ((self.containerView.frame.size.width / 2) - 15), height: 50))
        self.setDropdown(height: scroolHeight - 108, dropDown: self.dropDownSubject, text: self.defaultLocalizer.stringForKey(key: "dropDownLabelSubject"), optionNames: subjectNames, optionIds: subjectIds)
        // The the Closure returns Selected Index and String
        self.dropDownSubject.didSelect{(selectedText , index ,id) in
            self.dropDownSubject.textColor = UIColor.black
            self.subjectId = id
            if(self.bookId == 0)
            {
                if let viewWithTag = self.view.viewWithTag(4) {
                    viewWithTag.removeFromSuperview()
                }
                self.containerView.insertSubview(self.dropDownBookChapter, at: 7)
                
                if let viewWithTag = self.view.viewWithTag(5) {
                    viewWithTag.removeFromSuperview()
                }
                self.containerView.insertSubview(self.dropDownBook, at: 8)
            }
            
            self.dropDownBook.text = String()
            self.dropDownBookChapter.text = String()
            self.dropDownBook.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelBook")
            self.dropDownBookChapter.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelChapter")
            
            self.loadBooks(classId: self.classId, subjectId: self.subjectId)
        }
        
        self.dropDownSubject.listWillAppear {
            //You can Do anything when iOS DropDown listDidAppear
            dropDownSubjectShared.dropdownSubjectShared.isShown = 1;
        }
        
        self.dropDownBook = DropDown(frame: CGRect(x: 10, y: 70, width: (self.containerView.frame.size.width - 20), height: 50))
        self.setDropdown(height: scroolHeight - 168, dropDown: self.dropDownBook, text: self.defaultLocalizer.stringForKey(key: "dropDownLabelBook"), optionNames: bookNames, optionIds: bookIds)
        self.dropDownBook.tag = 2
        
        self.dropDownBook.listWillAppear {
            //You can Do anything when iOS DropDown listDidAppear
            dropDownBookShared.dropdownBookShared.isShown = 1;
        }
        
        // The the Closure returns Selected Index and String
        self.dropDownBook.didSelect{(selectedText , index ,id) in
            self.dropDownBook.textColor = UIColor.black
            self.bookId = id
            
            self.dropDownBookChapter.text = String()
            self.dropDownBookChapter.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelChapter")
            
            if(id != 0)
            {
                self.loadBookChapters(classId: self.classId, subjectId: self.subjectId, bookId: id)
            }
        }
        
        self.dropDownBookChapter = DropDown(frame: CGRect(x: 10, y: 130, width: (self.containerView.frame.size.width - 20), height: 50))
        self.setDropdown(height: scroolHeight - 228, dropDown: self.dropDownBookChapter, text: self.defaultLocalizer.stringForKey(key: "dropDownLabelChapter"), optionNames: chapterNames, optionIds: chapterIds)
        
        self.dropDownBookChapter.tag = 3
        
        self.dropDownBookChapter.listWillAppear {
            //You can Do anything when iOS DropDown listDidAppear
            dropDownBookChapterShared.dropdownBookChapterShared.isShown = 1;
        }
        
        txtChapterIndex = UITextField(frame: CGRect(x: 10, y: 190, width: (self.containerView.frame.size.width - 20), height: 50))
        txtChapterIndex.borderStyle = .roundedRect
        txtChapterIndex.attributedPlaceholder = NSAttributedString(string: self.defaultLocalizer.stringForKey(key: "placeHolderChapterIndex"),
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        txtChapterIndex.delegate = self
        txtChapterIndex.isUserInteractionEnabled = true
        
        // The the Closure returns Selected Index and String
        self.dropDownBookChapter.didSelect{(selectedText , index ,id) in
            self.dropDownBookChapter.textColor = UIColor.black
            self.bookChapterId = id
            self.txtChapterIndex.text = self.bookChapterIndex[index]
        }
        
        labelMic = UILabel(frame: CGRect(x: 10, y: 240, width: self.containerView.frame.size.width - 50, height: 40))
        labelMic.numberOfLines = 2
        labelMic.textColor = UIColor.red
        labelMic.font = UIFont(name:"Helvetica", size: 13.0)
        labelMic.text = "Please tap Microphone button, tap description, speak and watch your words become text."
        labelMic.textAlignment = .justified
        
        imageButtonMic = UIButton(frame: CGRect(x: self.containerView.frame.size.width - 40, y: 245, width: 30, height: 30))
        imageButtonMic.backgroundColor = UIColor.white
        imageButtonMic.layer.cornerRadius = 0
        imageButtonMic.clipsToBounds = false
        imageButtonMic.isUserInteractionEnabled = true
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = UIImage(named: "mic")
        imageButtonMic.addSubview(imageView)
        
        imageButtonMic.addTarget(self, action:#selector(micButtonTap), for:.touchUpInside)
        imageButtonMic.addTarget(self, action:#selector(micButtonTap), for:.touchUpOutside)
        
        txtRemark = UITextView(frame: CGRect(x: 10, y: 280, width: (self.containerView.frame.size.width - 20), height: 100))
        txtRemark.text = self.defaultLocalizer.stringForKey(key: "placeHolderDesc")
        txtRemark.font = UIFont(name:"Helvetica", size: 16.0)
        txtRemark.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor;
        txtRemark.layer.borderWidth = 1.0;
        txtRemark.layer.cornerRadius = 5.0;
        txtRemark.isEditable = true;
        txtRemark.textColor = UIColor.lightGray
        txtRemark.delegate = self
        //setting toolbar as inputAccessoryView
        self.txtChapterIndex.inputAccessoryView = toolbar
        self.txtRemark.inputAccessoryView = toolbar
        
        buttonAttachment = UIButton(frame: CGRect(x: 10, y: 390, width: ((self.containerView.frame.size.width / 2) - 15), height: 50))
        self.setAttachmentButtonAppearence(buttonAttachment: buttonAttachment, buttonText: self.defaultLocalizer.stringForKey(key: "buttonLabelAttachment"))
        
        self.buttonSubmit = UIButton(frame: CGRect(x: ((self.containerView.frame.size.width / 2) + 5), y: 390, width: ((self.containerView.frame.size.width / 2) - 15), height: 50))
        self.setSubmitButtonAppearence(buttonSubmit: buttonSubmit, buttonText: "  " + self.defaultLocalizer.stringForKey(key: "buttonLabelUpdate"))
        buttonSubmit.addTarget(self, action: #selector(updateClasswork), for:.touchUpInside)
        buttonSubmit.addTarget(self, action: #selector(updateClasswork), for:.touchUpOutside)
        
        self.imagePreviewContainer = UIView(frame: CGRect(x: 10, y: 450, width: self.containerView.frame.size.width, height: (self.containerView.frame.size.width / 3) - 40))
        
        self.containerView.insertSubview(self.imagePreviewContainer, at: 0)
        self.containerView.insertSubview(self.buttonSubmit, at: 1)
        self.containerView.insertSubview(self.buttonAttachment, at: 2)
        self.containerView.insertSubview(self.txtRemark, at: 3)
        self.containerView.insertSubview(self.labelMic, at: 4)
        self.containerView.insertSubview(self.imageButtonMic, at: 5)
        self.containerView.insertSubview(self.txtChapterIndex, at: 6)
        self.containerView.insertSubview(self.dropDownBookChapter, at: 7)
        self.containerView.insertSubview(self.dropDownBook, at: 8)
        self.containerView.insertSubview(self.dropDownSubject, at: 9)
        self.containerView.insertSubview(self.dropDownClass, at: 10)
        self.view.insertSubview(self.containerView, at: 0)
        
        self.dropDownClass.text = "   " + className
        self.dropDownSubject.text = "   " + subjectName
        self.dropDownBook.text = "   " + bookName
        self.dropDownBookChapter.text = "   " + chapterName
        self.txtChapterIndex.text = chapterIndex
        self.txtRemark.text = remarks
        self.previewAttachments();
        
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        
        self.view.addSubview(activityIndicator)
    }
    
    func previewAttachments()
    {
        var imagePreviewXCord = CGFloat()
        
        if(Doc_path.count > 0)
        {
            imagePreviewXCord = 0
            
            let imagePreview = UIImageView(frame: CGRect(x: imagePreviewXCord, y: 0, width: (imagePreviewContainer.frame.size.width / 3) - 20, height: (imagePreviewContainer.frame.size.width / 3) - 20))
            imagePreview.contentMode = .scaleAspectFit // OR .scaleAspectFill
            imagePreview.clipsToBounds = true
            imagePreview.layer.borderWidth = 0.5
            imagePreview.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
            imagePreview.layer.cornerRadius = 5
            self.imagePreviewContainer.addSubview(imagePreview)
            
            if let url = URL(string: (Doc_path)!) {
                getImageData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(response)
                    DispatchQueue.main.async() {
                        imagePreview.image = UIImage(data: data)
                    }
                }
            }
        }
        if(Doc_path2.count > 0)
        {
            imagePreviewXCord = CGFloat((imagePreviewContainer.frame.size.width / 3))
            
            let imagePreview = UIImageView(frame: CGRect(x: imagePreviewXCord, y: 0, width: (imagePreviewContainer.frame.size.width / 3) - 20, height: (imagePreviewContainer.frame.size.width / 3) - 20))
            imagePreview.contentMode = .scaleAspectFit // OR .scaleAspectFill
            imagePreview.clipsToBounds = true
            imagePreview.layer.borderWidth = 0.5
            imagePreview.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
            imagePreview.layer.cornerRadius = 5
            self.imagePreviewContainer.addSubview(imagePreview)
            
            if let url = URL(string: (Doc_path2)!) {
                getImageData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(response)
                    DispatchQueue.main.async() {
                        imagePreview.image = UIImage(data: data)
                    }
                }
            }
        }
        if(Doc_path3.count > 0)
        {
            imagePreviewXCord = CGFloat((imagePreviewContainer.frame.size.width / 3) + ((imagePreviewContainer.frame.size.width / 3)))
            
            let imagePreview = UIImageView(frame: CGRect(x: imagePreviewXCord, y: 0, width: (imagePreviewContainer.frame.size.width / 3) - 20, height: (imagePreviewContainer.frame.size.width / 3) - 20))
            imagePreview.contentMode = .scaleAspectFit // OR .scaleAspectFill
            imagePreview.clipsToBounds = true
            imagePreview.layer.borderWidth = 0.5
            imagePreview.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
            imagePreview.layer.cornerRadius = 5
            self.imagePreviewContainer.addSubview(imagePreview)
            
            if let url = URL(string: (Doc_path3)!) {
                getImageData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(response)
                    DispatchQueue.main.async() {
                        imagePreview.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    func loadClass() {
        self.activityIndicator.startAnimating()
        let schoolid = getSchoolId()
        let teacherid = getTeacherId()
        self.dropDownSubject.delegate = self
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "ClassV2") {
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
                                self.classNames.append("   " + classsection.Classsecname.components(separatedBy: .whitespacesAndNewlines).joined())
                            }
                            
                            let indexOfArray = self.classNames.firstIndex(of: "   " + self.className!.components(separatedBy: .whitespacesAndNewlines).joined())
                            
                            if(self.classIds.count > 0 && self.classNames.count > 0){
                                // The list of array to display. Can be changed dynamically
                                self.dropDownClass.optionArray = self.classNames
                                // Its Id Values and its optional
                                self.dropDownClass.optionIds = self.classIds
                                
                                self.dropDownClass.selectedIndex = indexOfArray!
                                
                                self.classId = self.classIds[indexOfArray!]
                                self.editClassId = self.classIds[indexOfArray!]
                                self.loadSubjects(classId: self.editClassId)
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
    
    func loadSubjects(classId: Int) {
        
        if(dropDownSubjectShared.dropdownSubjectShared.isShown == 1)
        {
            dropDownSubjectShared.dropdownSubjectShared.isShown = 0
            self.dropDownSubject.hideList()
        }
        if(dropDownBookShared.dropdownBookShared.isShown == 1)
        {
            dropDownBookShared.dropdownBookShared.isShown = 0
            self.dropDownBook.hideList()
        }
        if(dropDownBookChapterShared.dropdownBookChapterShared.isShown == 1)
        {
            dropDownBookChapterShared.dropdownBookChapterShared.isShown = 0
            self.dropDownBookChapter.hideList()
        }
        
        self.subjectIds.removeAll()
        self.subjectNames.removeAll()
        self.bookIds.removeAll()
        self.bookNames.removeAll()
        self.bookChapterIds.removeAll()
        self.bookChapterNames.removeAll()
        self.books?.removeAll()
        self.bookChapters?.removeAll()
        
        // The list of array to display. Can be changed dynamically
        self.dropDownSubject.optionArray = self.subjectNames
        // Its Id Values and its optional
        self.dropDownSubject.optionIds = self.subjectIds
        
        // The list of array to display. Can be changed dynamically
        self.dropDownBook.optionArray = self.bookNames
        // Its Id Values and its optional
        self.dropDownBook.optionIds = self.bookIds
        // The list of array to display. Can be changed dynamically
        self.dropDownBookChapter.optionArray = self.bookChapterNames
        // Its Id Values and its optional
        self.dropDownBookChapter.optionIds = self.bookChapterIds
        
        let schoolid = getSchoolId();
        let teacherid = getTeacherId()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "SubjectV2") {
            urlComponents.query = "schoolid=" + schoolid + "&classid=" + "\(classId)" + "&teacherid=" + teacherid
            // 3
            guard let url = urlComponents.url else { return}
            //print(url)
            getData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return}
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let subjectData = try JSONDecoder().decode(Result.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.subjects = subjectData.SubjectList
                        //dump(subjectData.SubjectList)
                        self.response = subjectData.Response
                        if(self.response?.ResponseVal == 1){
                            for subject in self.subjects!
                            {
                                self.subjectIds.append(subject.id)
                                self.subjectNames.append("   " + subject.Subjectname)
                            }
                            
                            if(self.subjectIds.count > 0 && self.subjectNames.count > 0){
                                // The list of array to display. Can be changed dynamically
                                self.dropDownSubject.optionArray = self.subjectNames
                                // Its Id Values and its optional
                                self.dropDownSubject.optionIds = self.subjectIds
                            }
                        }
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }
        }
    }
    
    func loadBooks(classId: Int, subjectId: Int) {
        
        if(dropDownSubjectShared.dropdownSubjectShared.isShown == 1)
        {
            dropDownSubjectShared.dropdownSubjectShared.isShown = 0
            self.dropDownSubject.hideList()
        }
        if(dropDownBookShared.dropdownBookShared.isShown == 1)
        {
            dropDownBookShared.dropdownBookShared.isShown = 0
            self.dropDownBook.hideList()
        }
        if(dropDownBookChapterShared.dropdownBookChapterShared.isShown == 1)
        {
            dropDownBookChapterShared.dropdownBookChapterShared.isShown = 0
            self.dropDownBookChapter.hideList()
        }
        
        self.bookIds.removeAll()
        self.bookNames.removeAll()
        self.bookChapterIds.removeAll()
        self.bookChapterNames.removeAll()
        self.bookChapters?.removeAll()
        
        // The list of array to display. Can be changed dynamically
        self.dropDownBook.optionArray = self.bookNames
        // Its Id Values and its optional
        self.dropDownBook.optionIds = self.bookIds
        // The list of array to display. Can be changed dynamically
        self.dropDownBookChapter.optionArray = self.bookChapterNames
        // Its Id Values and its optional
        self.dropDownBookChapter.optionIds = self.bookChapterIds
        let schoolid = getSchoolId()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "Book") {
            urlComponents.query = "schoolid=" + schoolid + "&classid=" + "\(classId)" + "&subjectid=" + "\(subjectId)"
            // 3
            guard let url = urlComponents.url else { return}
            
            getData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return}
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let bookData = try JSONDecoder().decode(Result.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.books = bookData.BookList
                        self.response = bookData.Response
                        if(self.response?.ResponseVal == 1){
                            for book in self.books!
                            {
                                self.bookIds.append(book.id)
                                self.bookNames.append("   " + book.Bookname)
                            }
                        }
                        
                        self.bookIds.append(0)
                        self.bookNames.append("   Others")
                        
                        if(self.bookIds.count > 0 && self.bookNames.count > 0){
                            // The list of array to display. Can be changed dynamically
                            self.dropDownBook.optionArray = self.bookNames
                            // Its Id Values and its optional
                            self.dropDownBook.optionIds = self.bookIds
                        }
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }
        }
    }
    
    func loadBookChapters(classId: Int, subjectId: Int, bookId: Int) {
        
        if(dropDownSubjectShared.dropdownSubjectShared.isShown == 1)
        {
            dropDownSubjectShared.dropdownSubjectShared.isShown = 0
            self.dropDownSubject.hideList()
        }
        if(dropDownBookShared.dropdownBookShared.isShown == 1)
        {
            dropDownBookShared.dropdownBookShared.isShown = 0
            self.dropDownBook.hideList()
        }
        if(dropDownBookChapterShared.dropdownBookChapterShared.isShown == 1)
        {
            dropDownBookChapterShared.dropdownBookChapterShared.isShown = 0
            self.dropDownBookChapter.hideList()
        }
        
        self.bookChapterIds.removeAll()
        self.bookChapterNames.removeAll()
        // The list of array to display. Can be changed dynamically
        self.dropDownBookChapter.optionArray = self.bookChapterNames
        // Its Id Values and its optional
        self.dropDownBookChapter.optionIds = self.bookChapterIds
        let schoolid = getSchoolId()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "BookChapterV2") {
            urlComponents.query = "schoolid=" + schoolid + "&classid=" + "\(classId)" + "&subjectid=" + "\(subjectId)" + "&bookid=" + "\(bookId)"
            // 3
            guard let url = urlComponents.url else { return}
            
            //print(url)
            getData(from: url) { data, response, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return}
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let bookChapterData = try JSONDecoder().decode(Result.self, from: data)
                    
                    print(bookChapterData)
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.bookChapters = bookChapterData.BookChapetrList
                        self.response = bookChapterData.Response
                        if(self.response?.ResponseVal == 1){
                            for bookChapter in self.bookChapters!
                            {
                                self.bookChapterIds.append(bookChapter.id)
                                self.bookChapterNames.append("   " + bookChapter.BookChaptername)
                                self.bookChapterIndex.append(bookChapter.BookChapterIndex)
                            }
                            
                            if(self.bookChapterIds.count > 0 && self.bookChapterNames.count > 0){
                                // The list of array to display. Can be changed dynamically
                                self.dropDownBookChapter.optionArray = self.bookChapterNames
                                // Its Id Values and its optional
                                self.dropDownBookChapter.optionIds = self.bookChapterIds
                            }
                        }
                    }
                } catch let jsonError {
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
    
    func setNavigationBar() {
        let navigationFont = UIFont(name: "Helvetica", size: getTitleFontSize())
        let screenSize: CGRect = UIScreen.main.bounds;
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: screenSize.width, height: 44))
        self.view.insertSubview(navBar, at: 50);
        
        let navItem = UINavigationItem(title: defaultLocalizer.stringForKey(key: "navBarTitleEditClasswork"));
        let button = UIButton.init(type: .custom)
        button.setTitle(defaultLocalizer.stringForKey(key: "navBarButtonBack"), for: UIControl.State.normal)
        var image = UIImage.init(named: "back");
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action:#selector(back), for:.touchUpInside)
        button.addTarget(self, action:#selector(back), for:.touchUpOutside)
        button.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20) //CGRectMake(0, 0, 30, 30)
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
        self.dismiss(animated: false, completion: nil);
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    @objc func dropDownClassTap(){
        dropDownSubject.delegate = self
        // The list of array to display. Can be changed dynamically
        self.dropDownSubject.optionArray = [String]()
        // Its Id Values and its optional
        self.dropDownSubject.optionIds = [Int]()
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @objc func micButtonTap()
    {
        imageButtonMic.isUserInteractionEnabled = false
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            labelMic.text = "Please tap Microphone button, tap description, speak and watch your words become text."
            imageButtonMic.isUserInteractionEnabled = true
        } else {
            startRecording()
        }
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
        
        imageView = UIImageView()
        if self.view.viewWithTag(12) != nil {
            imageView = self.view.viewWithTag(12) as! UIImageView
            
            let imageData = imageView.image!.jpegData(compressionQuality: 0.75)
            
            if(imageData != nil){
                let filePathKey = "file2"
                let filename = "Classwork_Image2.jpg"
                let mimetype = "image/jpg"
                
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(imageData!)
                //body.appendData(imageDataKey)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        imageView = UIImageView()
        if self.view.viewWithTag(13) != nil {
            imageView = self.view.viewWithTag(13) as! UIImageView
            
            let imageData = imageView.image!.jpegData(compressionQuality: 0.75)
            
            if(imageData != nil){
                let filePathKey = "file3"
                let filename = "Classwork_Image3.jpg"
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
    
    func resetInputFileds()
    {
        self.dropDownClass.text = String()
        self.dropDownSubject.text = String()
        self.dropDownBook.text = String()
        self.dropDownBookChapter.text = String()
        self.dropDownClass.placeholder = defaultLocalizer.stringForKey(key: "dropDownLabelClass")
        self.dropDownSubject.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelSubject")
        self.dropDownBook.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelBook")
        self.dropDownBookChapter.placeholder = self.defaultLocalizer.stringForKey(key: "dropDownLabelChapter")
        self.dropDownClass.isSelected = false
        self.dropDownSubject.isSelected = false
        self.dropDownBook.isSelected = false
        self.dropDownBookChapter.isSelected = false
        self.txtBookName.text = String();
        self.txtBookChapterName.text = String();
        self.txtChapterIndex.text = String();
        self.txtRemark.text = self.defaultLocalizer.stringForKey(key: "placeHolderDesc");
        if let viewWithTag = self.view.viewWithTag(11) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(12) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(13) {
            viewWithTag.removeFromSuperview()
        }
        
        self.buttonSubmit.isUserInteractionEnabled = true;
    }
    
    @objc func alertViewOKTap()
    {
        SharedSelectedTabIndex.sharedSelectedTabIndex.index = 0
        
        AppLoadingStatus.appLoadingStatus.status = "Redirect"
        
        self.navigationController?.popViewController(animated: false)
    }
    
    func updateClassworkDo(schoolId: Int, classworkid: Int, classId: Int, subjectId: Int,
                         bookId: String, bookName: String, chapterId: String, chapterName: String, chapterIndex: String, Remarks: String, Date: String)
    {
        let alertView = SCLAlertView(appearance: self.appearance)
        alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK")) {
            alertView.dismiss(animated: true, completion: nil)
        }
        
        let queryString = "schoolid=" + "\(schoolId)" + "&classworkid=" + "\(classworkid)" + "&classid=" + "\(classId)" + "&subjectid=" + "\(subjectId)" + "&bookid=" + "\(bookId)" + "&bookname=" + "\(bookName)" + "&chapterid=" + "\(chapterId)" + "&chaptername=" + "\(chapterName)" + "&chapterindex=" + "\(chapterIndex)" + "&remarks=" + "\(Remarks)"
        
        // To make the activity indicator appear:
        self.activityIndicator.startAnimating()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "UpdateClasswork") {
            urlComponents.query = queryString
            // 3
            guard let url = urlComponents.url else { return}
            
            print("updateClassworkDo--> \(url)")
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
                        
                        alertView.showError("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageClassworkSubmitError"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                        self.buttonSubmit.isUserInteractionEnabled = true;
                    }
                    return
                }
                else
                {
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        
                        self.resetInputFileds();
                        
                        alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"), target:self, selector: #selector(self.alertViewOKTap))
                        
                        alertView.showSuccess("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageClassworkSubmitSuccess"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
                    }
                }
            }
        }
    }
    
    @objc func updateClasswork()
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        // Set date format
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        // change to a readable time format and change to local time zone
        //dateFormatter.dateStyle = .short
        dateFormatter.timeZone = NSTimeZone.local
        // Apply date format
        let classworkDate: String = dateFormatter.string(from: Date())
        
        schoolid = Int(getSchoolId())!;
        
        let alertView = SCLAlertView(appearance: self.appearance)
        alertView.addButton(self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK")) {
            alertView.dismiss(animated: true, completion: nil)
        }
        
        var paramBookId = String()
        var paramBookChapterId = String()
        
        if(self.classId == 0 || self.subjectId == 0 || (self.bookId == 0 && txtBookName.text?.count == 0) || (self.bookChapterId == 0 && txtBookChapterName.text?.count == 0) || txtChapterIndex.text!.count == 0 || txtRemark.text == self.defaultLocalizer.stringForKey(key: "placeHolderDesc"))
        {
            alertView.showInfo("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageSelectAllFields"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
            return
        }
        
        if(txtRemark.text.count > 200)
        {
            alertView.showInfo("OurSchoolZone", subTitle: self.defaultLocalizer.stringForKey(key: "allertMessageDescriptionLength"), closeButtonTitle: self.defaultLocalizer.stringForKey(key: "actionSheetTitleOK"))
            return
        }
        
        if(self.bookId != 0)
        {
            paramBookId = String(self.bookId)
        }
        
        if(self.bookChapterId != 0)
        {
            paramBookChapterId = String(self.bookChapterId)
        }
        
        buttonSubmit.isUserInteractionEnabled = false
        self.updateClassworkDo(schoolId: Int(self.schoolid), classworkid: Int(self.classworkId), classId: self.classId, subjectId: self.subjectId,
                             bookId: paramBookId, bookName: txtBookName.text!, chapterId: paramBookChapterId, chapterName: txtBookChapterName.text!, chapterIndex: txtChapterIndex.text!, Remarks: txtRemark.text, Date: classworkDate)
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
        
        /*let pickedImageCount = PickedImageCountShared.pickedImageCountShared.count
         var imagePreviewXCord = CGFloat()
         var imagePreviewTag = Int(0)
         
         if(pickedImageCount == 0)
         {
         imagePreviewXCord = 0
         PickedImageCountShared.pickedImageCountShared.count = 1
         imagePreviewTag = 11
         }
         if(pickedImageCount == 1)
         {
         imagePreviewXCord = CGFloat((imagePreviewContainer.frame.size.width / 3))
         PickedImageCountShared.pickedImageCountShared.count = 2
         imagePreviewTag = 12
         }
         if(pickedImageCount == 2)
         {
         imagePreviewXCord = CGFloat((imagePreviewContainer.frame.size.width / 3) + ((imagePreviewContainer.frame.size.width / 3)))
         PickedImageCountShared.pickedImageCountShared.count = 3
         imagePreviewTag = 13
         }
         if(pickedImageCount! > 2)
         {
         imagePreviewXCord = 0
         }
         
         var selectedImageFromPicker: UIImage?
         if let editedImage = info[.editedImage] as? UIImage {
         selectedImageFromPicker = editedImage
         } else if let originalImage = info[.originalImage] as? UIImage {
         selectedImageFromPicker = originalImage
         }
         
         if let selectedImage = selectedImageFromPicker {
         let imagePreview = UIImageView(frame: CGRect(x: imagePreviewXCord, y: 0, width: (imagePreviewContainer.frame.size.width / 3) - 20, height: (imagePreviewContainer.frame.size.width / 3) - 20))
         imagePreview.contentMode = .scaleAspectFit // OR .scaleAspectFill
         imagePreview.clipsToBounds = true
         imagePreview.layer.borderWidth = 0.5
         imagePreview.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
         imagePreview.layer.cornerRadius = 5
         imagePreview.image = selectedImage
         imagePreview.tag = imagePreviewTag
         imagePreviewContainer.addSubview(imagePreview)
         }*/
        dismiss(animated: true, completion: nil)
        
        let cropViewController = CropViewController(image: (info[.originalImage] as? UIImage)!)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        
        let pickedImageCount = PickedImageCountShared.pickedImageCountShared.count
        var imagePreviewXCord = CGFloat()
        var imagePreviewTag = Int(0)
        
        if(pickedImageCount == 0)
        {
            imagePreviewXCord = 0
            PickedImageCountShared.pickedImageCountShared.count = 1
            imagePreviewTag = 11
        }
        if(pickedImageCount == 1)
        {
            imagePreviewXCord = CGFloat((imagePreviewContainer.frame.size.width / 3))
            PickedImageCountShared.pickedImageCountShared.count = 2
            imagePreviewTag = 12
        }
        if(pickedImageCount == 2)
        {
            imagePreviewXCord = CGFloat((imagePreviewContainer.frame.size.width / 3) + ((imagePreviewContainer.frame.size.width / 3)))
            PickedImageCountShared.pickedImageCountShared.count = 3
            imagePreviewTag = 13
        }
        if(pickedImageCount! > 2)
        {
            imagePreviewXCord = 0
        }
        
        let imagePreview = UIImageView(frame: CGRect(x: imagePreviewXCord, y: 0, width: (imagePreviewContainer.frame.size.width / 3) - 20, height: (imagePreviewContainer.frame.size.width / 3) - 20))
        imagePreview.contentMode = .scaleAspectFit // OR .scaleAspectFill
        imagePreview.clipsToBounds = true
        imagePreview.layer.borderWidth = 0.5
        imagePreview.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        imagePreview.layer.cornerRadius = 5
        imagePreview.image = image
        imagePreview.tag = imagePreviewTag
        
        var image = UIImage.init(named: "close");
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
        
        let removeButton = UIButton(frame: CGRect(x: imagePreviewXCord + (imagePreview.frame.size.width - 30), y: 0, width: 30, height: 30))
        removeButton.backgroundColor = colorWithHexString(hex: "#FFFFFF")
        removeButton.tintColor = colorWithHexString(hex: "#00CCFF")
        removeButton.layer.cornerRadius = 15
        removeButton.tintColor = colorWithHexString(hex: "#00CCFF")
        removeButton.layer.masksToBounds = true
        
        removeButton.tag = imagePreviewTag * 100
        removeButton.setImage(image, for: UIControl.State.normal)
        removeButton.addTarget(self, action:#selector(removeImage), for:.touchUpInside)
        removeButton.addTarget(self, action:#selector(removeImage), for:.touchUpOutside)
        
        imagePreviewContainer.addSubview(imagePreview)
        imagePreviewContainer.addSubview(removeButton)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func removeImage(sender: UIButton)
    {
        let pickedImageCount = PickedImageCountShared.pickedImageCountShared.count
        
        if(pickedImageCount == 3)
        {
            PickedImageCountShared.pickedImageCountShared.count = 2
        }
        if(pickedImageCount == 2)
        {
            PickedImageCountShared.pickedImageCountShared.count = 1
        }
        if(pickedImageCount == 1)
        {
            PickedImageCountShared.pickedImageCountShared.count = 0
        }
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
