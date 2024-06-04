//
//  SearchView.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 06/01/2019.
//  Copyright © 2019 wizag. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire

class SearchView: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var displayAds = Constant.DATA.Products
    let refreshControl = UIRefreshControl()
    let session = UserDefaults.standard
    var searchKey = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        initializeView()
        self.setTitle("FLOGIT", subtitle: "Your neighbourhood soko")
        // Do any additional setup after loading the view.
    }
    func searchBarSearchButtonClicked( _ search: UISearchBar){
       self.view.endEditing(true)
        let searchKey = search.text!
        if searchKey.isEmpty{
            let alert = UIAlertController(title: "Error", message: "Enter Search word", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        fetchData(searchKey :searchKey)
    }
    func fetchData(searchKey :String) -> Void {
        self.view.makeToastActivity(.center)
        let parameters: Parameters=[
            "action":"searchProducts",
            "searchKey":searchKey,
            "token":session.string(forKey: "token") ?? "000000"
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
            if (self.refreshControl.isRefreshing){
                self.refreshControl.endRefreshing()
            }
            self.view.hideToastActivity()
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
                    self.displayAds = Constant.DATA.Products
                    self.searchCollectionView.reloadData()
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
    
    func initializeView() -> Void {
        self.hideKeyboardWhenTappedAround()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        searchCollectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData(searchKey: searchKey)
    }
}
extension SearchView:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayAds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Constant.DATA.clickedAdProduct = displayAds[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "product", for: indexPath) as? SearchCollectionView
        let product = displayAds[indexPath.row]
        cell?.productImage.load.request(with: product.icon)
        cell?.productImage.contentMode = .scaleAspectFit
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
