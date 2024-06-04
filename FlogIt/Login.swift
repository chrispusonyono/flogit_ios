//
//  Login.swift
//  FlogIt
//
//  Created by apple on 10/7/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit
import Alamofire
class Login: UIViewController {
let session = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
    }
    
    
    
    
    @IBOutlet weak var username_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet weak var error_message_pane: UILabel!
    @IBOutlet weak var loading_login: UIActivityIndicatorView!
    @IBOutlet weak var login_btn: UIButton!
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func loginClicked(_ sender: UIButton) ->Void{
        let username = username_field.text ?? ""
        let password = password_field.text ?? ""
        
        if username.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Username can not be blank", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if password.isEmpty  {
            let alert = UIAlertController(title: "Error", message: "Password can not be blank", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        showLoading(load: true)
        
        let parameters: Parameters=[
            "action":"login",
            "username":username,
            "deviceToken":UserDefaults(suiteName:"app")!.string(forKey: "deviceToken") ?? "0",
            "password":password
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
            self.showLoading(load: false)
            switch response.result {
            case .success:
                
                  let dataIn = response.result.value as! NSDictionary
                    if((dataIn.value(forKey: "status") as! Bool)){
                        let profileData = dataIn.value(forKey: "profile") as! NSDictionary
                        let token = profileData.value(forKey: "token") as! String
                        let fullName = profileData.value(forKey: "fullName") as! String
                        let email = profileData.value(forKey: "email") as! String
                        let profilePicture = profileData.value(forKey: "profilePicture") as! String
                        let profile = Profile(loggedIn: true, token: token, fullName: fullName, email: email, profilePicture: profilePicture)
                        Constant.FUNCTIONS.setUserProfile(profile: profile)
                        self.goHome()
                    }else{
                        self.error_message_pane.text = "Invalid password or username"
                    }
                
            case .failure(let error):
                self.error_message_pane.text = "Unable to reach server"
                print(error)
            }
        }
        
    }
    func initializeView() -> Void {
        self.hideKeyboardWhenTappedAround()
        self.login_btn.layer.cornerRadius = 15
    }
    func loginUser() -> Void {
//        Alamofire.
       // self.dismiss(animated: true)
    }
    
    func showLoading(load:Bool) -> Void {
        loading_login.isHidden = !load
        login_btn.isEnabled = !load
        username_field.isEnabled = !load
        password_field.isEnabled = !load
    }
    private func goHome() ->Void{
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let login = storyboard.instantiateViewController(withIdentifier: "Homepage") as! Homepage
        self.present(login, animated:true, completion:nil)
    }
    @IBAction func goToSignup(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let signup = storyboard.instantiateViewController(withIdentifier: "Signup") as! Signup
        self.present(signup, animated:true, completion:nil)
        
    }
}

