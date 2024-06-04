//
//  AdView.swift
//  FlogIt
//
//  Created by apple on 10/16/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit
import ImageSlideshow
import Kingfisher
import Alamofire
import Toast_Swift
class AdView: UIViewController {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var productOwner: UILabel!
    @IBOutlet weak var productLocation: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet var adSlides: ImageSlideshow!
    @IBOutlet weak var startChat: UIButton!
    private var stay = true
    
    let session = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func initialize() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        productName.text = Constant.DATA.clickedAdProduct?.name
        productDescription.text = Constant.DATA.clickedAdProduct?.description
        productLocation.text = Constant.DATA.clickedAdProduct?.location
        
        var price = ""
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_KE")
        formatter.numberStyle = .currency
        let formattedTipAmount = formatter.string(from: NumberFormatter().number(from: (Constant.DATA.clickedAdProduct?.price)!)!)
        switch(Constant.DATA.clickedAdProduct?.type){
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
        productPrice.text = price
        fetchAd()
    }
    

    func loadSlides() {
        adSlides.slideshowInterval = 5.0
        adSlides.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        adSlides.contentScaleMode = UIView.ContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        adSlides.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        adSlides.activityIndicator = DefaultActivityIndicator()
        adSlides.currentPageChanged = { page in
            
        }
        var slides = [InputSource]()
        for slideUrl in Constant.DATA.adSlidesUrls {
            slides.append(KingfisherSource(urlString: slideUrl)!)
        }
        
        adSlides.setImageInputs(slides)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AdView.didTap))
        adSlides.addGestureRecognizer(recognizer)
        
        
    }
    @IBAction func startChat(_ sender: UIButton) {
        if stay {
            let token = UserDefaults(suiteName:"app")!.string(forKey: "deviceToken") ?? "0"
            print("Token =>>>>\(token)")
            return
        }
        
        print("Starting Chat with")
    }
    @objc func didTap() {
        let fullScreenController = adSlides.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    func fetchAd() {
        self.view.makeToastActivity(.center)
        let parameters: Parameters=[
            "action":"fetchProduct",
            "productId":Constant.DATA.clickedAdProduct?.id ?? "000000",
            "token":session.string(forKey: "token") ?? "000000"
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
            print(response)
            self.view.hideToastActivity()
            switch response.result {
            case .success:
                let responseReceived = response.result.value as! NSDictionary
                if((responseReceived.value(forKey: "status") as! Bool)){
                    print(responseReceived)
                    let product = responseReceived.value(forKey: "product") as! NSDictionary
                    Constant.DATA.OneToOneId = product.value(forKey: "userId") as! String
                    self.productOwner.text = product.value(forKey: "owner") as? String
                    self.startChat.isHidden = (product.value(forKey: "myProduct") as! Bool)
                    let slides = product.value(forKey: "icons") as! NSArray
                    Constant.DATA.adSlidesUrls = [String]()
                    for slide in slides {
                        let slideUrl = slide as! String
                        Constant.DATA.adSlidesUrls += [String(slideUrl)]
                        print(slideUrl)
                    }
                    self.loadSlides()
                } else {
                    print (responseReceived.value(forKey: "message") as! String)
                }
                
                
                
            case .failure( _):
                let alert = UIAlertController(title: "Error", message: "Server is unreachable", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }

}
