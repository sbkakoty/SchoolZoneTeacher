//
//  RemarksTableViewCell.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 29/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import UIKit

class RemarksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var labelClass: UILabel!
    @IBOutlet weak var textClass: UILabel!
    @IBOutlet weak var textDate: UILabel!
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var textSubject: UILabel!
    @IBOutlet weak var textRemarks: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textSubject.text = nil
        textClass.text = nil
        textDate.text = nil
        textRemarks.text = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //Set containerView drop shadow
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 0.0
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowRadius = 4.0
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowOffset = CGSize(width:0, height: 4)
        containerView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).cgPath
    }
}
