//
//  HomeCollectionViewCell.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 11/10/19.
//  Copyright © 2019 ClearWin Technologies. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet var tabButton: UIImageView!
    @IBOutlet var tabLabel: UILabel!
    
    @IBOutlet var badgeView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //self.badgeView.frame = CGRect(x: tabButton.bounds.maxX + 10, y: tabButton.bounds.minY + 5, width: 20, height: 20)
        self.badgeView.layer.cornerRadius = 10
        self.badgeView.clipsToBounds = false
    }

}
