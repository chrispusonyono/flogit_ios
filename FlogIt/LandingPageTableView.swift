//
//  LandingPageTableView.swift
//  FlogIt
//
//  Created by apple on 10/31/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit

class LandingPageTableView: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension LandingPageTableView{
    func setCollectionViewDataSourceDelagete
        <D: UICollectionViewDelegate & UICollectionViewDataSource >(_ datasorceDelegate:D ,forRow row:Int ){
        categoryCollectionView.delegate = datasorceDelegate
        categoryCollectionView.dataSource = datasorceDelegate
        categoryCollectionView.reloadData()
    }
}
