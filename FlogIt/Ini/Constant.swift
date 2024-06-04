//
//  Constant.swift
//  FlogIt
//
//  Created by apple on 10/7/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import Foundation
import ImageSlideshow
class Constant {
    
    struct URLS {
        static let PROJECT = "https://www.flogit.co.ke/app/ios/"
    }
    struct DATA {
        static var session = UserDefaults.standard
        static var Categories = [Category]()
        static var Products = [Product]()
        static var MyAds = [Product]()
        
        static var OneToOneId = ""
        static var OneToOneMessages = [Message]()
        static var threads = [Thread]()
        static var data:String?
        static var adSlidesUrls = [String]()
        static var clickedAdProduct:Product?
        static var terms = ""
    }
    struct FUNCTIONS {
        static func fetchCategories() -> Void{
            //
        }
        static func setUserProfile(profile : Profile) -> Void {
            Constant.DATA.session.set(profile.token, forKey: "token")
            Constant.DATA.session.set(profile.loggedIn, forKey: "loggedIn")
            Constant.DATA.session.set(profile.email, forKey: "email")
            Constant.DATA.session.set(profile.profilePicture, forKey: "profilePicture")
            Constant.DATA.session.set(profile.fullName, forKey: "fullName")
        }
        static func setThreads(threads:NSArray){
            let email = Constant.DATA.session.string(forKey: "email")!
            let data = UserDefaults(suiteName:"data_\(email)")!
            data.set(threads, forKey: "threads")
            print(threads)
        }
        static func setMyAds(ads:NSArray){
            let email = Constant.DATA.session.string(forKey: "email")!
            let data = UserDefaults(suiteName:"data_\(email)")!
            data.set(ads, forKey: "ads")
        }
        
        
        
        
        static func getMyAds() -> [Product] {
            var dataBack  =  [Product]()
            let email = Constant.DATA.session.string(forKey: "email")!
            let data = UserDefaults(suiteName:"data_\(email)")!
            if(data.object(forKey: "ads") == nil){
                return  dataBack
            }
            let ads = data.object(forKey: "ads") as! NSArray
            
            for product in ads{
                let data = product as! NSDictionary
                dataBack += [Product( id: data.value(forKey: "id") as! String, icon: data.value(forKey: "icon") as! String,name: data.value(forKey: "name") as! String, description: data.value(forKey: "description") as! String ,location: data.value(forKey: "location") as! String, price: data.value(forKey: "price") as! String, type: data.value(forKey: "type") as! String )]
            }
            return dataBack
        }
        static func getThreads() -> [Thread] {
            let email = Constant.DATA.session.string(forKey: "email")!
            let data = UserDefaults(suiteName:"data_\(email)")!
            if(data.object(forKey: "threads") == nil){
                return  [Thread]()
            }
            let threads = data.object(forKey: "threads") as! NSArray
            var dataBack  =  [Thread]()
            for thread in threads{
                let data = thread as! NSDictionary
                let messages = data.value(forKey: "messages") as! NSArray
                var messagesObject = [Message]()
                for message in messages{
                    let meso = message as! NSDictionary
                    messagesObject += [Message(
                        id: meso.value(forKey: "id") as! String,
                        message: meso.value(forKey: "description") as! String,
                        myMessage: meso.value(forKey: "myMessage") as! Bool,
                        time: meso.value(forKey: "createdAt") as! String,
                        status: meso.value(forKey: "status") as! Int)]
                }
                dataBack += [Thread(
                    userId: data.value(forKey: "userId") as! String,
                    name: data.value(forKey: "name") as! String,
                    icon: data.value(forKey: "icon") as! String,
                    lastMessage: data.value(forKey: "lastMessage") as! String,
                    time: data.value(forKey: "time") as! String,
                    messages: messagesObject)]
            }
            return dataBack
        }
    }
    
}
