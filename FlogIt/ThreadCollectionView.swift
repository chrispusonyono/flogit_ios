//
//  ProductCollectionView.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 28/11/2018.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit

class ThreadCollectionView: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.layer.cornerRadius = icon.frame.size.width / 2;
        icon.layer.masksToBounds = true;
    }
}
