//
//  MyAd.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 10/12/2018.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit

class MyAd: UITableViewCell {

    @IBOutlet weak var adName: UILabel!
    @IBOutlet weak var adIcon: UIImageView!
    @IBOutlet weak var adDescription: UILabel!
    @IBOutlet weak var adType: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
