//
//  Message.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 29/01/2019.
//  Copyright © 2019 wizag. All rights reserved.
//

import UIKit
class Chat: UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var background: CardAds!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var timeBack: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
