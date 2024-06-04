//
//  LandingPage.swift
//  FlogIt
//
//  Created by apple on 10/27/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit
import ImageLoader
import Alamofire
class LandingPage: UIViewController {
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var addAd: UIButton!
    private var currentPage = 0
    let refreshControl = UIRefreshControl()
    let session = UserDefaults.standard
    private var displayAds = Constant.DATA.Products
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        fetchData()
        self.setTitle("FLOGIT", subtitle: "Your neighbourhood soko")
        // Do any additional setup after loading the view.
        
    }

    func initializeView() -> Void {
        self.addAd.layer.cornerRadius = 25
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        productsCollectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData()
    }
    func fetchData() -> Void {
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching products ...")
        let parameters: Parameters=[
            "action":"fetchProducts",
            "token":session.string(forKey: "token") ?? "000000"
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
            if (self.refreshControl.isRefreshing){
                self.refreshControl.endRefreshing()
            }
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            switch response.result {
            case .success:
                
                let responseReceived = response.result.value as! NSDictionary
                
                    if((responseReceived.value(forKey: "status") as! Bool)){
                        print(responseReceived)
                        let categories = responseReceived.value(forKey: "products") as! NSArray
                        Constant.DATA.Products = [Product]()
                        for product in categories{
                            let data = product as! NSDictionary
                            Constant.DATA.Products += [Product( id: data.value(forKey: "id") as! String, icon: data.value(forKey: "icon") as! String,name: data.value(forKey: "name") as! String, description: data.value(forKey: "description") as! String , location: data.value(forKey: "location") as! String , price: data.value(forKey: "price") as! String, type: data.value(forKey: "type") as! String )]
                        }
                        self.loadAds(page: self.currentPage)
                        
                    }else{
                        print (responseReceived.value(forKey: "message") as! String)
                    }
              
                
                
            case .failure( _):
                let alert = UIAlertController(title: "Error", message: "Server is unreachable", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func loadAds(page:Int){
        currentPage=page
        switch page {
        case 0:
            displayAds=Constant.DATA.Products
            productsCollectionView.reloadData()
            break
        case 1:
            // new
            displayAds = [Product]()
            for ad in Constant.DATA.Products{
                if (ad.type == "0"){
                    displayAds += [ad]
                }
            }
            productsCollectionView.reloadData()
            break
        case 2:
            // used
            displayAds = [Product]()
            for ad in Constant.DATA.Products{
                if (ad.type == "1"){
                    displayAds += [ad]
                }
                
            }
            productsCollectionView.reloadData()
            break
        case 3:
            // exchange
            displayAds = [Product]()
            for ad in Constant.DATA.Products{
                if (ad.type == "2"){
                    displayAds += [ad]
                }
            }
            productsCollectionView.reloadData()
            break
        default:
            break
            
        }
    }
    @IBAction func viewFor(_ sender: UISegmentedControl) {
        // sender.selectedSegmentIndex
        loadAds(page: sender.selectedSegmentIndex)

    }
}
extension LandingPage:UICollectionViewDelegate,UICollectionViewDataSource{
  
        
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayAds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Constant.DATA.clickedAdProduct = displayAds[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productsCollectionView.dequeueReusableCell(withReuseIdentifier: "product", for: indexPath) as? ProductCollectionView
        let product = displayAds[indexPath.row]
        
        cell?.productImage.load.request(with: product.icon)
        cell?.productImage.contentMode = .scaleAspectFill
         cell?.productImage.clipsToBounds = true
        
        cell?.productName.text=product.name
        var price = ""
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_KE")
        formatter.numberStyle = .currency
        let formattedTipAmount = formatter.string(from: NumberFormatter().number(from: product.price)!)
        switch(product.type){
        case "0":
            price = "New ~" + formattedTipAmount!
            break
        case "1":
            price = "Used ~" + formattedTipAmount!
            break
        case "2":
            price = "For Exchange"
            break
        default:
            break
        }
        
        
        cell?.productType.text = price
        return cell!
    }
}
