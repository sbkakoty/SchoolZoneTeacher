//
//  ExamSubjectWiseMarksTableViewCell.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 04/03/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit

class ExamSubjectWiseMarksTableViewCell: UITableViewCell {

    @IBOutlet weak var textSubjectName: UILabel!
    @IBOutlet weak var textTotalMarks: UILabel!
    @IBOutlet weak var textSubjectMarks: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
