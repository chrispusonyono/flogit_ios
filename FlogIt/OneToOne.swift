//
//  OneToOne.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 26/01/2019.
//  Copyright © 2019 wizag. All rights reserved.
//

import UIKit
import Alamofire
import ImageLoader
import Toast_Swift
import SwiftHEXColors
class OneToOne: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate  {

    @IBOutlet weak var messageArea: UITextField!
    @IBOutlet weak var messageList: UITableView!
    let session = UserDefaults.standard
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
    
        // Do any additional setup after loading the view.
    }
    
    func initializeView() -> Void {
        //self.hideKeyboardWhenTappedAround()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        messageArea.delegate = self
        messageList.refreshControl = refreshControl
        messageList.separatorStyle = .none
        //messageList.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag
        messageList.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        //messageList.rowHeight = UITableView.automaticDimension
        //messageList.estimatedRowHeight = 100
        scrollToBottomMessage()
        
    }
    private func scrollToBottomMessage(){
        if(Constant.DATA.OneToOneMessages.count < 1 ){
            return
        }
        let lastRowIndex = self.messageList!.numberOfRows(inSection: 0) - 1
        let pathToLastRow = IndexPath.init(row: lastRowIndex, section: 0)
        self.messageList.scrollToRow(at: pathToLastRow, at: .none, animated: false)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @objc private func refreshData(_ sender: Any) {
        self.view.makeToast("Refreshing Data")
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if messageArea.text!.isEmpty{
            return
        }
        let messageInput = messageArea.text ?? ""
        messageArea.text = ""
        Constant.DATA.OneToOneMessages += [Message(id: "0", message: messageInput, myMessage: true, time: OneToOne.currentTime(), status: -1)]
        messageList.reloadData()
        let parameters: Parameters=[
            "action":"sendMessage",
            "receiverUserId":Constant.DATA.OneToOneId,
            "description":messageInput,
            "token":session.string(forKey: "token") ?? "000000"
        ]
        Alamofire.request(Constant.URLS.PROJECT, method: .post, parameters: parameters).validate().responseJSON {
            response in
           
            switch response.result {
            case .success:
                
                let responseReceived = response.result.value as! NSDictionary
                
                if((responseReceived.value(forKey: "status") as! Bool)){
                    print(responseReceived)
                    let id = responseReceived.value(forKey: "id") as! String
                    Constant.DATA.OneToOneMessages.remove(at: Constant.DATA.OneToOneMessages.count-1)
                    Constant.DATA.OneToOneMessages += [Message(id: id, message: messageInput, myMessage: true, time: OneToOne.currentTime(), status: 0)]
                    self.messageList.reloadData()
                    self.scrollToBottomMessage()
                }else{
                    print (responseReceived.value(forKey: "message") as! String)
                }
                
                
                
            case .failure( _):
                // just show an error on message
                let alert = UIAlertController(title: "Error", message: "Server is unreachable", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    static func currentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return "\(hour):\(minutes)"
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
extension OneToOne:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Constant.DATA.OneToOneMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Message", for: indexPath) as? Chat
        let messageData = Constant.DATA.OneToOneMessages[indexPath.row]
    
        cell?.message.text=messageData.message
        cell?.time.text=messageData.time
        cell?.background.frame.size.height = (cell?.message.frame.height)!
        if(messageData.myMessage)
        {
            cell?.timeBack.backgroundColor = UIColor(hexString: "#42b3f4")
            cell?.background.backgroundColor = UIColor(hexString: "#42b3f4")
        }else{
            cell?.timeBack.backgroundColor = UIColor(hexString: "#41f47d")
            cell?.background.backgroundColor = UIColor(hexString: "#41f47d")
        }
        switch messageData.status {
        case -1:
            cell?.status.image = UIImage(named: "baseline_access_time_black_48pt")
            break;
        case 0:
            cell?.status.image = UIImage(named: "baseline_done_black_48pt")
            break;
        case 1:
            cell?.status.image = UIImage(named: "baseline_done_all_black_48pt")
            break;
        case 2:
            cell?.status.image = UIImage(named: "baseline_error_black_48pt")
        default:
            cell?.status.image = UIImage(named: "baseline_access_time_black_48pt")
        }
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none;
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
