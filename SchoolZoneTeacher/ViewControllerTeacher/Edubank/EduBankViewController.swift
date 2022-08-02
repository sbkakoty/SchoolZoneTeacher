//
//  EduBankViewController.swift
//  vZons
//
//  Created by Apple on 31/07/19.
//

import UIKit
import MaterialComponents
import SCLAlertView
import Alamofire

class EduBankViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    let activityIndicator = MDCActivityIndicator()
    var result:Result?
    var eduBankList:[EduBank]?
    var response:Response?
    
    var tableView = UITableView()
    var refreshControl = UIRefreshControl()
    
    var dataCache = NSCache<AnyObject, AnyObject>()
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!
    )
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getEduBank()
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
        self.loadEduBankView()
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
        titleLabel.text = self.defaultLocalizer.stringForKey(key: "menuTitleEduBank")
        titleLabel.textAlignment = .center
        titleLabel.font = navigationFont
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
    
    @objc func back() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func calculateTopDistance () -> CGFloat{
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 45
    }
    
    func loadEduBankView() {
        
        let tabbarHeight = getTabbarHeight()
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + tabbarHeight)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: scroolHeight))
        containerView.tag = 100
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: scroolHeight), style: UITableView.Style.plain)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "EduBankTableViewCell", bundle: nil), forCellReuseIdentifier: "eduBankCell")
        self.tableView.rowHeight = 90.0// UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 90.0
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
        self.view.addSubview(containerView)
        
        self.activityIndicator.sizeToFit()
        self.activityIndicator.center.x = super.view.center.x
        self.activityIndicator.center.y = (super.view.center.y - 50)
        self.view.addSubview(activityIndicator)
    }
    
    func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @objc func getEduBank()
    {
        self.activityIndicator.startAnimating()
        
        if let viewWithTag = self.view.viewWithTag(7575) {
            viewWithTag.removeFromSuperview()
        }
        
        let alertView = SCLAlertView(appearance: self.appearance)
        
        if var urlComponents = URLComponents(string: Constants.baseUrl + "GetGKList") {
            urlComponents.query = ""
            // 3
            guard let url = urlComponents.url else { return }
            
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
                    let eduBandData = try JSONDecoder().decode(Result.self, from: data)
                    //dump(eduBandDataData)
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        
                        self.eduBankList = eduBandData.GKList
                        
                        self.response = eduBandData.Response
                        
                        self.activityIndicator.stopAnimating()
                        
                        //print(self.eduBankList!)
                        
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
        if let viewWithTag = self.view.viewWithTag(7575) {
            viewWithTag.removeFromSuperview()
        }
        
        self.getEduBank()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "vcEduBankDetails") as! EduBankDetailsViewController
        vc.modalPresentationStyle = .fullScreen
        let eduBandDataModel = self.eduBankList?[indexPath.row]
        
        vc.ID = eduBandDataModel?.id
        vc.Title = eduBandDataModel?.title
        vc.Author = eduBandDataModel?.author
        vc.Desc = eduBandDataModel?.description
        vc.imagePath = eduBandDataModel?.image
        vc.PublishDate = eduBandDataModel?.publishdate
        vc.eduBankURL = eduBandDataModel?.url
        
        self.present(vc, animated: false, completion: nil)
        CFRunLoopWakeUp(CFRunLoopGetCurrent())
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eduBankCell") as! EduBankTableViewCell
        
        var eduBandDataModel:EduBank?
        eduBandDataModel = self.eduBankList?[indexPath.row]
        
        cell.labelTitle?.text = eduBandDataModel?.title
        cell.labelAuthor?.text = eduBandDataModel?.author
        cell.labelDate?.text = eduBandDataModel?.publishdate
        cell.NewsThumbnail.image = nil
        let id = eduBandDataModel?.id
        
        cell.tag = indexPath.row
            
        if((eduBandDataModel?.image)!.count > 0){
            if(cell.tag == indexPath.row) {
                if let dataFromCache = dataCache.object(forKey: id as AnyObject) as? Data{
                    cell.NewsThumbnail.image = UIImage(data: dataFromCache)
                }
                else
                {
                    Alamofire.request((eduBandDataModel?.image)!, method: .get).response { (responseData) in
                        if let data = responseData.data {
                            DispatchQueue.main.async {
                                self.dataCache.setObject(data as AnyObject, forKey: id as AnyObject)
                                cell.NewsThumbnail.image = UIImage(data: data)
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eduBankList?.count ?? 0
    }
    
    func formateDateFromString(dateString: String, withFormat format: String) -> String? {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            
            return outputFormatter.string(from: date)
        }
        
        return nil
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

