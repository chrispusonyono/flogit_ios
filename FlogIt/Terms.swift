//
//  Terms.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 05/12/2018.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit

class Terms: UIViewController {

    let session = UserDefaults.standard
    @IBOutlet weak var termsText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
termsText.text=Constant.DATA.terms
        // Do any additional setup after loading the view.
    }
    

    @IBAction func acceptTerms(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "acceptedTerms")
        if (self.session.bool(forKey: "loggedIn")){
            self.goHome()
        }
        else{
            self.goLogin()
        }
    }
    @IBAction func decline(_ sender: Any) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
}
