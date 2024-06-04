//
//  Signup.swift
//  FlogIt
//
//  Created by apple on 10/15/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit
import Alamofire
class Signup: UIViewController {
    let session = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    @IBAction func goToLogin(_ sender: UIButton) {
        self.dismiss(animated: true)
        
    }
    func initializeView() -> Void {
        self.signupBtn.layer.cornerRadius = 15
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func createUser(_ sender: UIButton) {
        let username = email_input.text ?? ""
        let password = password_input.text ?? ""
        let passwordc = confirm_input.text ?? ""
        let fullName = full_name_input.text ?? ""
        
        if fullName.isEmpty {
            let alert = UIAlertController(title: "Error", message: "full name can not be blank", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if username.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Email can not be blank", preferredStyle: UIAlertController.Style.alert)
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
        if passwordc.isEmpty  {
            let alert = UIAlertController(title: "Error", message: "Confirm Password can not be blank", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (password != passwordc) {
            let alert = UIAlertController(title: "Error", message: "Password do not match", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        showLoading(load: true)
        let parameters: Parameters=[
            "action":"sign_up",
            "username":username,
            "deviceToken":UserDefaults(suiteName:"app")!.string(forKey: "deviceToken") ?? "0",
            "email":username,
            "fullName":fullName,
            "password":password
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
            self.showLoading(load: false)
            switch response.result {
            case .success:
                if  let dataIn = try?response.result.value as! NSDictionary{
                    if((dataIn.value(forKey: "status") as! Bool)){
                        let profileData = dataIn.value(forKey: "profile") as! NSDictionary
                        let token = profileData.value(forKey: "token") as! String
                        let fullName = profileData.value(forKey: "fullName") as! String
                        let email = profileData.value(forKey: "email") as! String
                        let profilePicture = profileData.value(forKey: "profilePicture") as! String
                        let profile = Profile(loggedIn: true, token: token, fullName: fullName, email: email, profilePicture: profilePicture)
                        self.setProfile(profile: profile)
                        self.goHome()
                    }else{
                        self.errorMessage.text = dataIn.value(forKey: "message") as? String
                    }
                }else{
                    self.errorMessage.text = "Unable to reach server"
                }
                
                
                
                
                
            case .failure(let error):
                print(error)
                self.errorMessage.text = "Server is unreachable"
            }
            
            
            
        }
        
        
        
        
    }
    func showLoading(load:Bool) -> Void {
        loading.isHidden = !load
        signupBtn.isEnabled = !load
        email_input.isEnabled = !load
        password_input.isEnabled = !load
        confirm_input.isEnabled = !load
    }
    private func goHome() ->Void{
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let login = storyboard.instantiateViewController(withIdentifier: "Homepage") as! Homepage
        self.present(login, animated:true, completion:nil)
    }
    func setProfile(profile : Profile) -> Void {
        self.session.set(profile.token, forKey: "token")
        self.session.set(profile.loggedIn, forKey: "loggedIn")
        self.session.set(profile.profilePicture, forKey: "profilePicture")
        self.session.set(profile.email, forKey: "email")
        self.session.set(profile.fullName, forKey: "fullName")
    }
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var password_input: UITextField!
    @IBOutlet weak var confirm_input: UITextField!
    @IBOutlet weak var email_input: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var full_name_input: UITextField!
    
}
