//
//  EduForumViewController.swift
//  vZons
//
//  Created by Apple on 31/07/19.
//

import UIKit
import Lightbox
import ReadMoreTextView
import MaterialComponents
import SCLAlertView
import Alamofire


class TopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LightboxControllerPageDelegate, LightboxControllerDismissalDelegate {
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator()
    
    var result:Result?
    var topicList:[EduForum]?
    var response:Response?
    
    var tableView = UITableView()
    var refreshControl = UIRefreshControl()
    
    var dataCache = NSCache<AnyObject, AnyObject>()
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!
    )
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getTopics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(getLanguage().count > 0)
        {
            defaultLocalizer.setSelectedLanguage(lang: getLanguage())
        }
        else
        {
            defaultLocalizer.setSelectedLanguage(lang: "en")
        }
        
        self.setNavigationBar()
        
        self.loadEduForumView()
    }
    
    func loadEduForumView() {
        
        let tabbarHeight = getTabbarHeight()
        
        var scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + tabbarHeight) - 65
        
        if(tabbarHeight == 83){
            scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + tabbarHeight) - 92
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: scroolHeight))
        containerView.tag = 100
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: scroolHeight), style: UITableView.Style.plain)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "EduForumTableViewCell", bundle: nil), forCellReuseIdentifier: "TopicCell")
        self.tableView.rowHeight = 132//UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 132
        self.tableView.separatorStyle = .none
        
        self.refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        //Setup pull to refresh
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            self.tableView.addSubview(refreshControl)
        }
        
        self.removeSubView()
        
        containerView.addSubview(tableView)
        
        let btn = UIButton(type: .custom)
        self.setFABAppearence(btn: btn)
        btn.addTarget(self, action:#selector(addTopicTap), for:.touchUpInside)
        
        containerView.addSubview(btn)
        self.view.addSubview(containerView)
        
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
        titleLabel.text = self.defaultLocalizer.stringForKey(key: "menuTitleEduForum")
        titleLabel.textAlignment = .center
        titleLabel.font = navigationFont
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
    
    @objc func back() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func getxBound()-> CGFloat{
        var xbounds = 0.00
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                xbounds = Double((view.bounds.width - window.safeAreaInsets.right))
            }
        }
        else
        {
            xbounds = Double(view.bounds.width)
        }
        
        return CGFloat(xbounds)
    }
    
    func getyBound()-> CGFloat{
        
        var xbounds = 0.00
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                xbounds = Double((view.bounds.height -  window.safeAreaInsets.bottom))
            }
        }
        else
        {
            xbounds = Double(view.bounds.height)
        }
        
        let preferences = UserDefaults.standard
        
        let yboundKey = "yBound"
        if preferences.object(forKey: yboundKey) == nil {
            //  Doesn't exist
            preferences.set(Double(xbounds), forKey: yboundKey)
            
            preferences.synchronize()
        } else {
            xbounds = preferences.double(forKey: yboundKey)
        }
        
        return CGFloat(xbounds)
    }
    
    func setFABAppearence(btn: UIButton)
    {
        let tabBarHeight = getTabbarHeight()
        if(tabBarHeight == 83){
            btn.frame = CGRect(x: (getxBound() - 90), y: (getyBound() - 230), width: 80, height: 80)
        }
        else
        {
            btn.frame = CGRect(x: (getxBound() - 90), y: (getyBound() - 205), width: 80, height: 80)
        }
        
        btn.setImage(UIImage(named: "plus"), for: .normal)
        btn.tintColor = UIColor.white
        btn.backgroundColor = UIColor.clear
        btn.backgroundColor = colorWithHexString(hex: "#00FFCC")
        btn.layer.cornerRadius = 40
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.layer.borderWidth = 0.0
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 2.0, height: 5.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 5.0
        btn.layer.masksToBounds = false
    }
    
    func setCommentButtonAppearence(buttonComment: UIButton)
    {
        buttonComment.tintColor = colorWithHexString(hex: "#999999")
        buttonComment.backgroundColor = UIColor.clear
        buttonComment.layer.masksToBounds = false
        buttonComment.isMultipleTouchEnabled = false
    }
    
    @objc func addTopicTap() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "vcAddTopic") as! AddTopicViewController
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: false)
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
    
    func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getTopics()
    {
        self.activityIndicator.startAnimating()
        
        if let viewWithTag = self.view.viewWithTag(7575) {
            viewWithTag.removeFromSuperview()
        }
        
        let alertView = SCLAlertView(appearance: self.appearance)
        
        //let schoolid = getSchoolId()
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "GetEduForumTopics") {
            urlComponents.query = "school_id="
            // 3
            guard let url = urlComponents.url else { return }
            
            //print("GetEduForumTopics: \(url)")
            
            getData(from: url) { data, response, error in
                if error != nil {
                    DispatchQueue.main.async {
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
                        self.refreshControl.endRefreshing()
                        
                        self.topicList = topicData.topicsList
                        
                        self.response = topicData.Response
                        
                        self.activityIndicator.stopAnimating()
                        
                        if(self.response?.ResponseVal == 0)
                        {
                            self.displayAlertMessage()
                        }
                        else{

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
        //self.getTopics()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showAnswers(sender: UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "vcAnswers") as! AnswersViewController
        vc.modalPresentationStyle = .fullScreen
        let EduForumDataModel = self.topicList?[sender.tag]
        
        vc.topicId = EduForumDataModel?.id
        vc.topic = EduForumDataModel?.description
        
        if((EduForumDataModel?.parent_id.count)! > 0){
            vc.createdBy = EduForumDataModel?.parent_name
        }
        else if((EduForumDataModel?.teacher_id.count)! > 0)
        {
            vc.createdBy = EduForumDataModel?.teacher_name
        }
        else
        {
            vc.createdBy = EduForumDataModel?.school_name
        }
        vc.imagePath = EduForumDataModel?.image
        vc.isLocked = EduForumDataModel?.islocked
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "vcAnswers") as! AnswersViewController
        vc.modalPresentationStyle = .fullScreen
        let EduForumDataModel = self.topicList?[indexPath.row]
        
        vc.topicId = EduForumDataModel?.id
        vc.topic = EduForumDataModel?.description
        
        if((EduForumDataModel?.parent_id.count)! > 0){
            vc.createdBy = EduForumDataModel?.parent_name
        }
        else if((EduForumDataModel?.teacher_id.count)! > 0)
        {
            vc.createdBy = EduForumDataModel?.teacher_name
        }
        else
        {
            vc.createdBy = EduForumDataModel?.school_name
        }
        vc.imagePath = EduForumDataModel?.image
        vc.isLocked = EduForumDataModel?.islocked
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell") as! EduForumTableViewCell
        
        var topicModel:EduForum?
        topicModel = self.topicList?[indexPath.row]
        
        cell.containerView.updateConstraints()
        cell.containerView.layoutIfNeeded()
        
        cell.imageViewLogo.image = UIImage(named: "noimage")
        let id = topicModel?.id
        
        cell.tag = indexPath.row
            
        if((topicModel?.profile_image)!.count > 0){
            if(cell.tag == indexPath.row) {
                if let dataFromCache = dataCache.object(forKey: id as AnyObject) as? Data{
                    
                    cell.imageViewLogo.image = UIImage(data: dataFromCache)
                }
                else
                {
                    Alamofire.request((topicModel?.profile_image)!, method: .get).response { (responseData) in
                        if let data = responseData.data {
                            DispatchQueue.main.async {
                                self.dataCache.setObject(data as AnyObject, forKey: id as AnyObject)
                                cell.imageViewLogo.image = UIImage(data: data)
                            }
                        }
                    }
                }
            }
        }
        
        if((topicModel?.image.count)! > 0){
            cell.buttonAttachment.isHidden = false
        }
        else
        {
            cell.buttonAttachment.isHidden = true
        }
        
        cell.buttonAttachment.tag = indexPath.row
        cell.buttonAttachment.addTarget(self, action:#selector(showAttachemt), for:.touchUpInside)
        cell.buttonAttachment.addTarget(self, action:#selector(showAttachemt), for:.touchUpOutside)
        
        if((topicModel?.parent_id.count)! > 0){
            cell.labelUser.text = topicModel?.parent_name
        }
        else if((topicModel?.teacher_id.count)! > 0)
        {
            cell.labelUser.text = topicModel?.teacher_name
        }
        else
        {
            cell.labelUser.text = topicModel?.school_name
        }
        cell.labelDate.text = topicModel?.publishdate
        
        let titleFont: UIFont = UIFont(name: "Helvetica", size: 14.0)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        
        let data = topicModel?.description.data(using: String.Encoding.unicode)! // mind "!"
        let attrStr = try? NSMutableAttributedString( // do catch
            data: data!,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        attrStr!.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrStr!.length))
        attrStr!.addAttribute(NSAttributedString.Key.font, value: titleFont, range: NSMakeRange(0, attrStr!.length))
        cell.textViewDesc.attributedText = attrStr
        cell.textViewDesc.textAlignment = .justified
        cell.textViewDesc.shouldTrim = true
        cell.textViewDesc.maximumNumberOfLines = 6
        
        let attributes = [NSAttributedString.Key.font:
            UIFont(name: "Helvetica-Bold", size: 14.0)!,
                          NSAttributedString.Key.foregroundColor: UIColor.gray] as [NSAttributedString.Key: Any]
        let readMoreText = NSAttributedString(string: " Continue reading...", attributes: attributes)
        cell.textViewDesc.attributedReadMoreText = readMoreText
        
        cell.buttonComments.setTitle("  " + self.defaultLocalizer.stringForKey(key: "EduForumDiscussion"), for: .normal)
        cell.buttonComments.tag = indexPath.row
        cell.buttonComments.isUserInteractionEnabled = true
        cell.buttonComments.addTarget(self, action:#selector(showAnswers), for:.touchUpInside)
        cell.buttonComments.addTarget(self, action:#selector(showAnswers), for:.touchUpOutside)
        
        if(topicModel?.islocked == "1")
        {
            cell.IsLocked.tintColor = colorWithHexString(hex: "#999999")
            let lockImage = UIImage(named: "disabled")
            let templateImage = lockImage?.withRenderingMode(.alwaysTemplate)
            cell.IsLocked.image = templateImage
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicList?.count ?? 0
    }
    
    private func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 132
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x:5, y: 5, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        
        return label.frame.height
    }
    
    @objc func showAttachemt(sender: UIButton)
    {
        var topicModel:EduForum?
        topicModel = self.topicList?[sender.tag]
        let imagePath = topicModel?.image
        
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
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
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
        let imageview = UIImageView(frame: CGRect(x: ((self.view.frame.size.width / 2) - 50), y: ((self.view.frame.size.height / 2) - 74), width: 100, height: 100))
        imageview.image = UIImage(named: "norecordfound")
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
        imageview.layer.masksToBounds = true
        imageview.tag = 7575
        self.view.addSubview(imageview)
    }
    
    /*func textWidth(text: String) -> CGFloat {
        let font = UIFont(name: "Helvetica", size: 14.0)
        //let fontAttributes = [NSAttributedStringKey.font: font]
        let myText = text
        let size = (myText as NSString).size(withAttributes: fontAttributes as [NSAttributedStringKey : Any])
        return size.width
    }*/
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}


