//
//  SettingsViewController.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 16/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaultLocalizer = AMPLocalizeUtils.defaultLocalizer
    var popoverVC: UIViewController!
    var menuItems = [MenuItem]()
    var tableView = UITableView()
    
    var buttonActionSheet = UIButton()
    
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
        
        menuItems.append(MenuItem(menuIcon: "faq", menuText: self.defaultLocalizer.stringForKey(key: "menuTitleFAQ")))
        menuItems.append(MenuItem(menuIcon: "feedback", menuText: self.defaultLocalizer.stringForKey(key: "menuTitleFeedback")))
        menuItems.append(MenuItem(menuIcon: "query-home", menuText: self.defaultLocalizer.stringForKey(key: "menuTitleQuery")))
        
        self.setNavigationBar()
        self.loadSettingsView()
        
        self.buttonActionSheet = UIButton(frame: CGRect(x: 0, y: self.calculateTopDistance() + 225, width: self.view.frame.size.width, height: 50))
        self.buttonActionSheet.setTitle("", for: .normal)
        
        self.view.addSubview(buttonActionSheet)
    }
    
    func loadSettingsView() {
        //Set wanted position and size (frame)
        let tabbarHeight = getTabbarHeight()
        let scroolHeight = self.view.frame.size.height - (self.calculateTopDistance() + tabbarHeight)
        
        let settingsView = UIView(frame: CGRect(x: 0, y: self.calculateTopDistance() + 5, width: self.view.frame.size.width, height: scroolHeight))
        settingsView.tag = 100
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: scroolHeight), style: UITableView.Style.plain)
        self.tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "settingsCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = true
        self.tableView.rowHeight = 85.0
        self.tableView.estimatedRowHeight = 85.0
        self.tableView.separatorStyle = .none
        settingsView.addSubview(tableView)
        
        //Add the view
        self.view.addSubview(settingsView)
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
        titleLabel.text = self.defaultLocalizer.stringForKey(key: "menuTitleHelp")
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
        
        let menuItem = menuItems[indexPath.row]
        
        cell.menuIcon.image = UIImage(named: menuItem.menuIcon)
        cell.menuIcon.tintColor = colorWithHexString(hex: "#00CCFF")
        cell.menuOption.text = menuItem.menuText
        
        cell.contentView.isUserInteractionEnabled = true
        cell.containerView.isUserInteractionEnabled = true
        cell.menuOption.isUserInteractionEnabled = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 0){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "vcFAQ") as! FAQViewController
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
        
        if(indexPath.row == 1){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "vcFeedback") as! FeedbackViewController
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
        
        if(indexPath.row == 2){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "vcQuery") as! QueryViewController
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: false)
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
