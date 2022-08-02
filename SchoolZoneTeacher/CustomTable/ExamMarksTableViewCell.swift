//
//  ExamMarksTableViewCell.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 01/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit

class ExamMarksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textStudentName: UILabel!
    @IBOutlet weak var labelMarksObtained: UILabel!
    @IBOutlet weak var textTotalMarks: UITextField!
    @IBOutlet weak var textMarksObtained: UITextField!
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
        textStudentName.text = nil
        labelMarksObtained.text = nil
        textTotalMarks.text = nil
        textMarksObtained.text = nil
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
