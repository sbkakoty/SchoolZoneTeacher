//
//  EduForumTableViewCell.swift
//  vZons
//
//  Created by Apple on 11/08/19.
//

import UIKit
import ReadMoreTextView

class EduForumTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var IsLocked: UIImageView!
    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var textViewDesc: ReadMoreTextView!
    @IBOutlet weak var buttonComments: UIButton!
    @IBOutlet weak var buttonAttachment: UIButton!
    
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
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 0.0
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowOffset = CGSize(width:0, height: 2)
        containerView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).cgPath
        
        imageViewLogo.frame = CGRect(x: 5, y: 5, width: 45, height: 45)
        imageViewLogo.layer.cornerRadius = 22.5;
        imageViewLogo.layer.borderWidth = 1.0;
        imageViewLogo.layer.borderColor = UIColor.lightGray.cgColor
        imageViewLogo.layer.masksToBounds = true;
    }
}
