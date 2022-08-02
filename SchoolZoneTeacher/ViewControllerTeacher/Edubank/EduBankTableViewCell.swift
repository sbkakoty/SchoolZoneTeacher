//
//  EduBankTableViewCell.swift
//  vZons
//
//  Created by Apple on 09/08/19.
//

import UIKit

class EduBankTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelAuthor: UILabel!
    @IBOutlet weak var NewsThumbnail: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    
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
        labelTitle.text = nil
        labelAuthor.text = nil
        NewsThumbnail.image = nil
        labelDate.text = nil
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
        
        NewsThumbnail.frame = CGRect(x: 5, y: 7.5, width: 50, height: 50)
        NewsThumbnail.backgroundColor = UIColor.lightGray
        NewsThumbnail.layer.cornerRadius = 25;
        NewsThumbnail.layer.borderWidth = 1.0;
        NewsThumbnail.layer.borderColor = UIColor.lightGray.cgColor
        NewsThumbnail.layer.masksToBounds = true;
    }
}
