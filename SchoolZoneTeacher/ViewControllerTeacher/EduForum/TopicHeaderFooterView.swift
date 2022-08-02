//
//  TopicHeaderFooterView.swift
//  vZons
//
//  Created by Apple on 20/08/19.
//

import UIKit

class TopicHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var descContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        containerView.isUserInteractionEnabled = true
        
        self.imageViewLogo.layer.cornerRadius = 22.5
        self.imageViewLogo.layer.borderWidth = 0
        self.imageViewLogo.clipsToBounds = true
    }
}
