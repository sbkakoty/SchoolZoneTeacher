//
//  AnnouncementDetailsViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 23/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit
import MaterialComponents
import iOSDropDown
import SCLAlertView
import Lightbox

class AnnouncementDetailsViewController: UIViewController, LightboxControllerPageDelegate, LightboxControllerDismissalDelegate {
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textTeacher: UILabel!
    @IBOutlet weak var textClass: UILabel!
    @IBOutlet weak var textSubject: UILabel!
    @IBOutlet weak var textDate: UILabel!
    @IBOutlet weak var textRemarks: UITextView!
    
    @IBOutlet weak var labelClass: UILabel!
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var labelTeacher: UILabel!
    @IBOutlet var buttonAttachment: UIButton!
    @IBOutlet var labelDesc: UILabel!
    
    var varClassName: String!
    var varSubjectName: String!
    var varTeacherName: String!
    var varDate: String!
    var varRemarks: String!
    var image_path1: String!
    var image_path2: String!
    var image_path3: String!
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.textRemarks.scrollRangeToVisible(NSMakeRange(0, 0))
        }
        //let desiredOffset = CGPoint(x: 0, y: -self.textRemarks.contentInset.top)
        //self.textRemarks.setContentOffset(desiredOffset, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setNavigationBar()
        
        containerView.layer.borderWidth = 0.5
        containerView.layer.cornerRadius = 3.0
        containerView.layer.borderColor = colorWithHexString(hex: "#DDDDDD").cgColor
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        containerView.layer.shadowOpacity = 0.5
        
        labelClass.text = defaultLocalizer.stringForKey(key: "labelClass")
        labelSubject.text = defaultLocalizer.stringForKey(key: "labelTitle")
        labelTeacher.text = defaultLocalizer.stringForKey(key: "labelUserType")
        self.labelDesc.text = self.defaultLocalizer.stringForKey(key: "labelDesc")
        
        buttonAttachment.setTitle(defaultLocalizer.stringForKey(key: "buttonLabelViewAttachment"), for: .normal)
        textClass?.text = varClassName
        textSubject?.text = varSubjectName
        textTeacher?.text = varTeacherName
        textDate?.text = varDate
        textRemarks?.text = varRemarks
        buttonAttachment.isHidden = true
        
        if(image_path1.count > 0 || image_path2.count > 0 || image_path3.count > 0)
        {
            buttonAttachment.isHidden = false
            buttonAttachment.addTarget(self, action:#selector(buttonAttachmentTap), for:.touchUpInside)
        }
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
        titleLabel.text = self.defaultLocalizer.stringForKey(key: "navBarTitleAnnouncementDetails")
        titleLabel.textAlignment = .center
        titleLabel.font = navigationFont
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func buttonAttachmentTap(sender: UIButton)
    {
        
        var images = [LightboxImage(imageURL: URL(string: image_path1!)!)]
        
        if(image_path2!.count > 0)
        {
            images.append(LightboxImage(imageURL: URL(string: image_path2!)!))
        }
        
        if(image_path3!.count > 0)
        {
            images.append(LightboxImage(imageURL: URL(string: image_path3!)!))
        }
        
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
