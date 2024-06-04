//
//  ViewController.swift
//  FlogIt
//
//  Created by apple on 10/3/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit
import Alamofire
class ViewController: UIViewController {
    private let session = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    private func initialize()->Void{
        fetchData()
        
    }
    func fetchData() -> Void {
        let parameters: Parameters=[
            "action":"initialize",
            "type":"ios"
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
            
            switch response.result {
            case .success:
                
            
                let dataIn = response.result.value as! NSDictionary
                if((dataIn.value(forKey: "status") as! Bool)){
                    Constant.DATA.terms = dataIn.value(forKey: "terms") as! String
                }else{
                   
                }
                
                
                
                print("request Successful")
            case .failure(let error):
                print(error)
            }
            if(self.session.bool(forKey: "acceptedTerms")){
                if (self.session.bool(forKey: "loggedIn")){
                    self.goHome()
                }
                else{
                    self.goLogin()
                }
                
            }else{
                self.goTerms()
            }
        }
 
    }
    func goLogin() -> Void {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let login = storyboard.instantiateViewController(withIdentifier: "Login") as! Login
        self.present(login, animated:true, completion:nil)
    }
    func goHome() -> Void {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let login = storyboard.instantiateViewController(withIdentifier: "Homepage") as! Homepage
        self.present(login, animated:true, completion:nil)
    }
    func goTerms() -> Void {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let login = storyboard.instantiateViewController(withIdentifier: "Terms") as! Terms
        self.present(login, animated:true, completion:nil)
    }
}
extension UIViewController {
    
    func setTitle(_ title: String, subtitle: String) {
        let appearance = UINavigationBar.appearance()
        let textColor = appearance.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor ?? .black
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.headline)
        titleLabel.textColor = textColor
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        subtitleLabel.textColor = textColor.withAlphaComponent(0.75)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical
        self.navigationItem.titleView = stackView
        let logo = UIImage(named: "logo_flat.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
}
