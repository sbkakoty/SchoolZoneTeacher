//
//  TabItemCollectionViewCell.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 20/09/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit

class TabItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var tabButton: UIButton!
    @IBOutlet var tabLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //Set containerView drop shadow
    }

}
