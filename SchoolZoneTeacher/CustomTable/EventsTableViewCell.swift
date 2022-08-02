//
//  EventsTableViewCell.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 19/02/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var labelEvents: UILabel!
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var EventThumbnail: UIImageView!
    
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
        labelEvents.text = nil
        labelStartDate.text = nil
        labelEndDate.text = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //Set containerView drop shadow
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 0.0
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowOffset = CGSize(width:0, height: 2)
        containerView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).cgPath
    }
}
