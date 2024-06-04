//
//  Profle.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 01/12/2018.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit
import ImageLoader
import Alamofire
import PopupDialog
import Toast_Swift
class Profle: UIViewController {
    let session = UserDefaults.standard
    var clikedId=0
    @IBOutlet weak var myAdsTableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var chats: UICollectionView!
    
    let refreshControl = UIRefreshControl()
    let refreshChats = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        self.setTitle("FLOGIT", subtitle: "Your neighbourhood soko")
        // Do any additional setup after loading the view.
    }
    func initializeView() -> Void {
        Constant.DATA.threads = Constant.FUNCTIONS.getThreads()
        Constant.DATA.MyAds = Constant.FUNCTIONS.getMyAds()
        myAdsTableView.isHidden=false
        chats.isHidden=true
        email.text=session.string(forKey: "email")
        fullName.text=session.string(forKey: "fullName")
        profilePicture.load.request(with: session.string(forKey: "profilePicture") ?? "")
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.clipsToBounds = true
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        myAdsTableView.refreshControl = refreshControl
        // chats
        refreshChats.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshChats.addTarget(self, action: #selector(refreshChats(_:)), for: .valueChanged)
        chats.refreshControl = refreshChats
        
        myAdsTableView.separatorStyle = .none
        fetchData()
        fetchThreadsData()
        
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData()
    }
    @objc private func refreshChats(_ sender: Any) {
        fetchThreadsData()
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        editProfile()
    }
    func editProfile() {
        let profileEdit = ProfileEditView(nibName: "ProfileEditView", bundle: nil)
        
    
        
        
        let popup = PopupDialog(viewController: profileEdit,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                preferredWidth: 580,
                                tapGestureDismissal: false,
                                panGestureDismissal: false,
                                hideStatusBar: true,
                                completion:  nil)
        
        let buttonOne = CancelButton(title: "CANCEL", height: 60) {
        }
        let buttonTwo = DefaultButton(title: "SAVE", height: 60) {
            self.fullName.text = profileEdit.fullName.text
            self.profilePicture.image = profileEdit.profilePicture.image
            self.view.makeToastActivity(.center)
            let parameters = [
                "action": "changeProfile",
                "token": UserDefaults.standard.string(forKey: "token") ?? "",
                "fullName": self.fullName.text ?? ""
            ]
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                multipartFormData.append(self.profilePicture.image!.jpegData(compressionQuality: 0.75)!, withName: "icon",fileName: "file.jpg", mimeType: "image/jpg")
                
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            },
                             to:Constant.URLS.PROJECT)
            { (result) in
                
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        self.view.hideToastActivity()
                        print(response)
                        let dataIn = response.result.value as! NSDictionary
                        if((dataIn.value(forKey: "status") as! Bool)){
                            print(dataIn)
                            let profileData = dataIn.value(forKey: "profile") as! NSDictionary
                            let token = profileData.value(forKey: "token") as! String
                            let fullName = profileData.value(forKey: "fullName") as! String
                            let email = profileData.value(forKey: "email") as! String
                            let profilePicture = profileData.value(forKey: "profilePicture") as! String
                            let profile = Profile(loggedIn: true, token: token, fullName: fullName, email: email, profilePicture: profilePicture)
                            Constant.FUNCTIONS.setUserProfile(profile: profile)
                            self.view.makeToast("Profile Updated successfully")
                            
                        }else{
                            self.fullName.text=self.session.string(forKey: "fullName")
                            self.profilePicture.load.request(with: self.session.string(forKey: "profilePicture") ?? "")
                            let alert = UIAlertController(title: "Error", message: dataIn.value(forKey: "message") as? String, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
            
            
            
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    func showAdInfo(adClicked : Product ){
        let adInfo = MyAdInfo(nibName: "MyAdInfo", bundle: nil)
        let popup = PopupDialog(viewController: adInfo,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                preferredWidth: 580,
                                tapGestureDismissal: false,
                                panGestureDismissal: false,
                                hideStatusBar: true,
                                completion:  nil)
        let buttonOne = CancelButton(title: "Edit", height: 60) {
            
        }
        let buttonTwo = DefaultButton(title: "Delete", height: 60) {
            self.deleteAd(adId: adClicked.id)
        }
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    func deleteAd(adId: String) -> Void {
        self.view.makeToastActivity(.center)
        let parameters: Parameters=[
            "action":"deleteAd",
            "id":adId,
            "token":self.session.string(forKey: "token") ?? "000000"
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
            self.view.hideToastActivity()
            switch response.result {
            case .success:
                
                let responseReceived = response.result.value as! NSDictionary
                
                if((responseReceived.value(forKey: "status") as! Bool)){
                    print(responseReceived)
                    Constant.DATA.MyAds.remove(at: self.clikedId)
                    self.myAdsTableView.reloadData()
                }else{
                    let popupError = PopupDialog(title: "Error", message: (responseReceived.value(forKey: "message") as! String), buttonAlignment: .horizontal)
                    let buttonOk = CancelButton(title: "Ok", height: 60) {
                        
                    }
                    let buttonRetry = DefaultButton(title: "Retry", height: 60) {
                        self.deleteAd(adId: adId)
                    }
                    popupError.addButtons([buttonOk, buttonRetry])
                    self.present(popupError, animated: true, completion: nil)
                    
                    
                    print (responseReceived.value(forKey: "message") as! String)
                }
                
                
                
            case .failure( _):
                // just show an error on message
                let popupError = PopupDialog(title: "Error", message: "Server is unreachable", buttonAlignment: .horizontal)
                let buttonOk = CancelButton(title: "Ok", height: 60) {
                    
                }
                let buttonRetry = DefaultButton(title: "Retry", height: 60) {
                    self.deleteAd(adId: adId)
                }
                popupError.addButtons([buttonOk, buttonRetry])
                self.present(popupError, animated: true, completion: nil)
                
                
            }
        }
    }
    @IBAction func logout(_ sender: UIButton) {
        
        let title = "Log Out"
        let message = "Are You Sure to Log Out ? "
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                preferredWidth: 580)
        let buttonOne = CancelButton(title: "Cancel", height: 60) {
        }
        let buttonTwo = DefaultButton(title: "Logout", height: 60) {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            Constant.DATA.MyAds=[Product]()
            self.goLogin()
        }
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    func goLogin() -> Void {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let login = storyboard.instantiateViewController(withIdentifier: "Login") as! Login
        self.present(login, animated:true, completion:nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func viewFor(_ sender: UISegmentedControl) {
        // sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0:
            myAdsTableView.isHidden=false
            chats.isHidden=true
            break
        case 1:
            myAdsTableView.isHidden=true
            chats.isHidden=false
            break
        default:
            break
            
            
        }
    }
    
    func fetchData() -> Void {
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching your products ...")
        let parameters: Parameters=[
            "action":"myAds",
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
                    Constant.FUNCTIONS.setMyAds(ads: responseReceived.value(forKey: "products") as! NSArray)
                    Constant.DATA.MyAds = Constant.FUNCTIONS.getMyAds()
                    self.myAdsTableView.reloadData()
                    
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
    func fetchThreadsData() -> Void {
        print(session.string(forKey: "token") ?? "000000")
        refreshChats.attributedTitle = NSAttributedString(string: "Fetching your messages ...")
        let parameters: Parameters=[
            "action":"getMyThreads",
            "token":session.string(forKey: "token") ?? "000000"
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
            if (self.refreshChats.isRefreshing){
                self.refreshChats.endRefreshing()
            }
            self.refreshChats.attributedTitle = NSAttributedString(string: "Pull to refresh")
            switch response.result {
            case .success:
                
                let responseReceived = response.result.value as! NSDictionary        
                if((responseReceived.value(forKey: "status") as! Bool)){
                    print(responseReceived)
                    Constant.FUNCTIONS.setThreads(threads: responseReceived.value(forKey: "threads") as! NSArray)
                    Constant.DATA.threads = Constant.FUNCTIONS.getThreads()
                    self.chats.reloadData()
                    
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
}

extension Profle:UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    /*=============== start of collection view ====================*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.DATA.threads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Constant.DATA.OneToOneId = Constant.DATA.threads[indexPath.row].userId
        Constant.DATA.OneToOneMessages = Constant.DATA.threads[indexPath.row].messages
        //let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        //let chat = storyboard.instantiateViewController(withIdentifier: "OneToOne") as! OneToOne
        //self.present(chat, animated:true, completion:nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = chats.dequeueReusableCell(withReuseIdentifier: "thread", for: indexPath) as? ThreadCollectionView
        let thread = Constant.DATA.threads[indexPath.row]
        cell?.icon.load.request(with: thread.icon)
        //cell?.icon.contentMode = .scaleToFill //squizing everything in given ratio
        cell?.icon.contentMode = .scaleAspectFill //just fit in given ratio
        cell?.icon.clipsToBounds = true
        cell?.name.text = thread.name
        cell?.lastMessage.text = thread.lastMessage
        cell?.time.text = thread.time
        return cell!
    }
    
    
    
    /*=============== start of table view ====================*/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Constant.DATA.MyAds.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAd", for: indexPath) as? MyAd
        let product = Constant.DATA.MyAds[indexPath.row]
        cell?.adIcon.load.request(with: product.icon)
        cell?.adIcon.contentMode = .scaleAspectFill
        cell?.adIcon.clipsToBounds = true
        cell?.adName.text=product.name
        cell?.adDescription.text=product.description
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
        cell?.adType.text = price
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none;
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        clikedId=indexPath.row
        showAdInfo(adClicked: Constant.DATA.MyAds[indexPath.row])
        
            
            
        }
    }
